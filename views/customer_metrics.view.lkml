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
        COALESCE(COUNT(DISTINCT oi.order_id), 0) as lifetime_orders,
        COALESCE(SUM(oi.sale_price), 0) as lifetime_revenue,

        -- Date metrics
        MIN(oi.created_at) as first_order_date,
        MAX(oi.created_at) as latest_order_date,

        -- Days since latest order (only for customers with orders)
        CASE
          WHEN MAX(oi.created_at) IS NOT NULL
          THEN DATE_DIFF(CURRENT_DATE(), DATE(MAX(oi.created_at)), DAY)
          ELSE NULL
        END as days_since_latest_order,

        -- Active status (purchased within last 90 days)
        CASE
          WHEN MAX(oi.created_at) IS NOT NULL
            AND DATE_DIFF(CURRENT_DATE(), DATE(MAX(oi.created_at)), DAY) <= 90
          THEN true
          ELSE false
        END as is_active,

        -- Repeat customer flag
        CASE
          WHEN COUNT(DISTINCT oi.order_id) > 1 THEN true
          ELSE false
        END as is_repeat_customer

      FROM ${users.SQL_TABLE_NAME} u
      LEFT JOIN ${order_items.SQL_TABLE_NAME} oi ON u.id = oi.user_id
      GROUP BY 1,2,3,4,5,6,7,8,9,10
    ;;
  }

  # ============================================================================
  # DIMENSIONS
  # ============================================================================

  dimension: user_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: full_name {
    type: string
    sql: CONCAT(${first_name}, ' ', ${last_name}) ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  # ============================================================================
  # CUSTOMER LIFETIME ORDERS - WITH GROUPINGS
  # ============================================================================

  dimension: lifetime_orders {
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: customer_lifetime_orders_tier {
    type: tier
    tiers: [1, 2, 3, 6, 10]
    style: integer
    sql: ${lifetime_orders} ;;
    description: "Customer groupings based on total lifetime orders"
  }

  dimension: customer_lifetime_orders_group {
    type: string
    sql:
      CASE
        WHEN ${lifetime_orders} = 1 THEN '1 Order'
        WHEN ${lifetime_orders} = 2 THEN '2 Orders'
        WHEN ${lifetime_orders} BETWEEN 3 AND 5 THEN '3-5 Orders'
        WHEN ${lifetime_orders} BETWEEN 6 AND 9 THEN '6-9 Orders'
        WHEN ${lifetime_orders} >= 10 THEN '10+ Orders'
        WHEN ${lifetime_orders} = 0 THEN '0 Orders'
        ELSE 'Unknown'
      END ;;
    order_by_field: customer_lifetime_orders_sort
  }

  dimension: customer_lifetime_orders_sort {
    type: number
    sql:
      CASE
        WHEN ${lifetime_orders} = 0 THEN 0
        WHEN ${lifetime_orders} = 1 THEN 1
        WHEN ${lifetime_orders} = 2 THEN 2
        WHEN ${lifetime_orders} BETWEEN 3 AND 5 THEN 3
        WHEN ${lifetime_orders} BETWEEN 6 AND 9 THEN 4
        WHEN ${lifetime_orders} >= 10 THEN 5
        ELSE 999
      END ;;
    hidden: yes
  }

  # ============================================================================
  # CUSTOMER LIFETIME REVENUE - WITH GROUPINGS
  # ============================================================================

  dimension: lifetime_revenue {
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_revenue ;;
  }

  dimension: customer_lifetime_revenue_tier {
    type: tier
    tiers: [5, 20, 50, 100, 500, 1000]
    style: relational
    sql: ${lifetime_revenue} ;;
    value_format_name: usd
    description: "Customer groupings based on total lifetime revenue"
  }

  dimension: customer_lifetime_revenue_group {
    type: string
    sql:
      CASE
        WHEN ${lifetime_revenue} < 5 THEN '$0.00 - $4.99'
        WHEN ${lifetime_revenue} < 20 THEN '$5.00 - $19.99'
        WHEN ${lifetime_revenue} < 50 THEN '$20.00 - $49.99'
        WHEN ${lifetime_revenue} < 100 THEN '$50.00 - $99.99'
        WHEN ${lifetime_revenue} < 500 THEN '$100.00 - $499.99'
        WHEN ${lifetime_revenue} < 1000 THEN '$500.00 - $999.99'
        WHEN ${lifetime_revenue} >= 1000 THEN '$1000.00+'
        ELSE 'Unknown'
      END ;;
    order_by_field: customer_lifetime_revenue_sort
  }

  dimension: customer_lifetime_revenue_sort {
    type: number
    sql:
      CASE
        WHEN ${lifetime_revenue} < 5 THEN 1
        WHEN ${lifetime_revenue} < 20 THEN 2
        WHEN ${lifetime_revenue} < 50 THEN 3
        WHEN ${lifetime_revenue} < 100 THEN 4
        WHEN ${lifetime_revenue} < 500 THEN 5
        WHEN ${lifetime_revenue} < 1000 THEN 6
        WHEN ${lifetime_revenue} >= 1000 THEN 7
        ELSE 999
      END ;;
    hidden: yes
  }

  # ============================================================================
  # DATE DIMENSIONS
  # ============================================================================

  dimension_group: first_order {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.first_order_date ;;
  }

  dimension_group: latest_order {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.latest_order_date ;;
  }

  dimension_group: user_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.user_created_at ;;
  }

  # ============================================================================
  # ACTIVITY AND RETENTION DIMENSIONS
  # ============================================================================

  dimension: days_since_latest_order {
    type: number
    sql: ${TABLE}.days_since_latest_order ;;
  }

  dimension: days_since_latest_order_tier {
    type: tier
    tiers: [1, 7, 30, 90, 180, 365]
    style: integer
    sql: ${days_since_latest_order} ;;
  }

  dimension: is_active {
    type: yesno
    sql: ${TABLE}.is_active ;;
    description: "Has purchased within the last 90 days"
  }

  dimension: is_repeat_customer {
    type: yesno
    sql: ${TABLE}.is_repeat_customer ;;
    description: "Has placed more than one order"
  }

  dimension: customer_status {
    type: string
    sql:
      CASE
        WHEN ${is_active} AND ${is_repeat_customer} THEN 'Active Repeat'
        WHEN ${is_active} AND NOT ${is_repeat_customer} THEN 'Active New'
        WHEN NOT ${is_active} AND ${is_repeat_customer} THEN 'Inactive Repeat'
        WHEN NOT ${is_active} AND NOT ${is_repeat_customer} THEN 'Inactive New'
        ELSE 'Unknown'
      END ;;
  }

  # ============================================================================
  # MEASURES
  # ============================================================================

  measure: total_customers {
    type: count
    drill_fields: [user_id, full_name, email, customer_lifetime_orders_group, customer_lifetime_revenue_group]
  }

  measure: customers_with_orders {
    type: count
    filters: [lifetime_orders: ">0"]
    description: "Number of customers who have placed at least one order"
  }

  measure: total_lifetime_orders {
    type: sum
    sql: ${lifetime_orders} ;;
    description: "Total number of orders placed over the course of customers' lifetimes"
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${lifetime_orders} ;;
    value_format_name: decimal_2
    description: "Average number of orders that a customer places over their lifetime"
  }

  measure: average_lifetime_orders_customers_with_orders {
    type: number
    sql: ${total_lifetime_orders} / NULLIF(${customers_with_orders}, 0) ;;
    value_format_name: decimal_2
    description: "Average number of orders among customers who have made purchases"
  }

  measure: total_lifetime_revenue {
    type: sum
    sql: ${lifetime_revenue} ;;
    value_format_name: usd
    description: "Total amount of revenue brought in over the course of customers' lifetimes"
  }

  measure: average_lifetime_revenue {
    type: average
    sql: ${lifetime_revenue} ;;
    value_format_name: usd
    description: "Average amount of revenue that a customer brings in over their lifetime"
  }

  measure: average_lifetime_revenue_customers_with_orders {
    type: number
    sql: ${total_lifetime_revenue} / NULLIF(${customers_with_orders}, 0) ;;
    value_format_name: usd
    description: "Average lifetime revenue among customers who have made purchases"
  }

  measure: average_days_since_latest_order {
    type: average
    sql: ${days_since_latest_order} ;;
    value_format_name: decimal_0
    description: "Average number of days since customers have placed their most recent orders"
  }

  measure: active_customers {
    type: count
    filters: [is_active: "yes"]
    description: "Number of customers who have purchased within the last 90 days"
  }

  measure: repeat_customers {
    type: count
    filters: [is_repeat_customer: "yes"]
    description: "Number of customers who have placed more than one order"
  }

  measure: repeat_customer_rate {
    type: number
    sql: ${repeat_customers} / NULLIF(${customers_with_orders}, 0) ;;
    value_format_name: percent_2
    description: "Percentage of purchasing customers who are repeat customers"
  }

  measure: active_customer_rate {
    type: number
    sql: ${active_customers} / NULLIF(${customers_with_orders}, 0) ;;
    value_format_name: percent_2
    description: "Percentage of purchasing customers who are currently active"
  }
}
