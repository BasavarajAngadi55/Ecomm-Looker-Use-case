# user_order_facts.view.lkml

view: user_order_facts {
  derived_table: {
    sql:
      SELECT
        user_id,
        MIN(created_at) AS first_order_date,
        MAX(created_at) AS latest_order_date,
        COUNT(DISTINCT order_id) AS lifetime_orders,
        SUM(sale_price) AS lifetime_revenue
      FROM
        `your_project.your_dataset.order_items` # Replace with your order_items table
      GROUP BY 1
      ;;
    datagroup_trigger: ecomm_daily_etl # Optional: Set a refresh schedule
  }

  dimension: user_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: first_order {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}.first_order_date ;;
  }

  dimension_group: latest_order {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}.latest_order_date ;;
  }

  dimension: lifetime_orders {
    type: number
    description: "Total count of orders placed by a user in their lifetime."
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: lifetime_revenue {
    type: number
    description: "Total revenue from a user in their lifetime."
    sql: ${TABLE}.lifetime_revenue ;;
    value_format_name: usd
  }
}
