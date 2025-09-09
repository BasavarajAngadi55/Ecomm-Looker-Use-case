# ============================================================================
# BRAND AND CATEGORY REPEAT PURCHASE ANALYSIS VIEW
# ============================================================================

view: brand_category_repeat_analysis {
  derived_table: {
    sql:
      WITH customer_product_orders AS (
        SELECT
          oi.user_id,
          p.brand,
          p.category,
          COUNT(DISTINCT oi.order_id) as orders_for_brand_category,
          MIN(oi.created_at) as first_purchase_date,
          MAX(oi.created_at) as latest_purchase_date
        FROM ${order_items.SQL_TABLE_NAME} oi
        JOIN ${products.SQL_TABLE_NAME} p ON oi.product_id = p.id
        GROUP BY 1, 2, 3
      ),
      brand_category_stats AS (
        SELECT
          brand,
          category,
          COUNT(DISTINCT user_id) as total_customers,
          COUNT(DISTINCT CASE WHEN orders_for_brand_category > 1 THEN user_id END) as repeat_customers,
          AVG(orders_for_brand_category) as avg_orders_per_customer
        FROM customer_product_orders
        GROUP BY 1, 2
      )
      SELECT
        brand,
        category,
        total_customers,
        repeat_customers,
        avg_orders_per_customer,
        SAFE_DIVIDE(repeat_customers, total_customers) as repeat_customer_rate
      FROM brand_category_stats
    ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: total_customers {
    type: number
    sql: ${TABLE}.total_customers ;;
  }

  dimension: repeat_customers {
    type: number
    sql: ${TABLE}.repeat_customers ;;
  }

  dimension: repeat_customer_rate {
    type: number
    sql: ${TABLE}.repeat_customer_rate ;;
    value_format_name: percent_2
  }

  dimension: avg_orders_per_customer {
    type: number
    sql: ${TABLE}.avg_orders_per_customer ;;
    value_format_name: decimal_2
  }

  measure: count_brands_categories {
    type: count
    label: "Number of Brand/Category combinations"
  }

  measure: average_repeat_rate {
    type: average
    sql: ${repeat_customer_rate} ;;
    value_format_name: percent_2
    description: "Average repeat customer rate across brand/category combinations"
  }
}
