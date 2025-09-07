# ============================================================================
# CUSTOMER LIFETIME ANALYSIS VIEW
# ============================================================================

# First, create a derived table to aggregate customer lifetime metrics
view: customer_lifetime_stats {
  derived_table: {
    sql:
      SELECT
        u.id as user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.age,
        u.city,
        u.state,
        u.country,
        u.gender,
        u.created_at as user_created_at,

        -- Lifetime order metrics
        COUNT(DISTINCT oi.order_id) as lifetime_orders,
        SUM(oi.sale_price) as lifetime_revenue,

        -- Date metrics
        MIN(oi.created_at) as first_order_date,
        MAX(oi.created_at) as latest_order_date,

        -- Days since latest order
        DATE_DIFF(CURRENT_DATE(), DATE(MAX(oi.created_at)), DAY) as days_since_latest_order,

        -- Active status (purchased within last 90 days)
        CASE
          WHEN DATE_DIFF(CURRENT_DATE(), DATE(MAX(oi.created_at)), DAY) <= 90 THEN true
          ELSE false
        END as is_active,

        -- Repeat customer flag
        CASE
          WHEN COUNT(DISTINCT oi.order_id) > 1 THEN true
          ELSE false
        END as is_repeat_customer

      FROM ${users.SQL_TABLE_NAME} u
      LEFT JOIN ${order_items.SQL_TABLE_NAME} oi ON u.id = oi.user_id
      WHERE oi.user_id IS NOT NULL  -- Only include customers who have made purchases
      GROUP BY 1,2,3,4,5,6,7,8,9,10
    ;;
  }
  }
