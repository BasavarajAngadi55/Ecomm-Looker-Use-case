view: order_patterns_frequency {
  derived_table: {
    sql: select user_id,
      ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) as order_sequence,
      LAG(DATE(created_at)) OVER (PARTITION BY user_id ORDER BY DATE(created_at)) as previous_order_date,
      LEAD(DATE(created_at), 1) OVER (PARTITION BY user_id ORDER BY DATE(created_at)) as next_order_date
      from ${order_items.SQL_TABLE_NAME} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: order_sequence {
    type: number
    sql: ${TABLE}.order_sequence ;;
    description: "Sequence number of the order for each user."
  }
  dimension: previous_order_date {
    type: date
    datatype: date
    sql: ${TABLE}.previous_order_date ;;
    description: "Date of the previous order for each user."
  }
  dimension_group: between_orders {
    type: duration
    intervals: [day, week, month, year]
    sql_start: ${previous_order_date} ;;
    sql_end: ${order_items.created_date} ;;
    description: "Measures the duration between consecutive orders for each user."
  }
  dimension: days_between_orders_tiers {
    type: tier
    tiers: [1, 11, 21, 31, 41, 51, 61, 71, 81, 91, 100]
    sql: ${days_between_orders};;
    style: integer
    drill_fields: [products.brand, products.category]
    description: "Categorizes the duration between orders into tiers."
  }

  measure: average_days_between_orders {
    type: average
    sql: ${days_between_orders} ;;
    description: "Calculates the average number of days between consecutive orders for all users."
  }
  dimension: is_first_purchase {
    type: yesno
    sql: ${order_sequence} = 1 ;;
    description: "Indicates whether the order is the user's first purchase."
  }
  dimension: next_order_date {
    type: date
    datatype: date
    sql: ${TABLE}.next_order_date ;;
    description: "Date of the next order for each user."
  }

  dimension: has_subsequent_order {
    type: yesno
    sql: ${next_order_date} IS NOT NULL ;;
    description: "Indicates whether the user has made subsequent orders."
  }
  dimension: is_60_day_repeat_purchase {
    type: yesno
    sql: ${days_between_orders} <= 60 ;;
    description: "Indicates whether the duration between orders is less than or equal to 60 days."
  }
  measure: 60_day_repeat_users_count {
    type: count_distinct
    sql: ${user_id} ;;
    filters: [is_60_day_repeat_purchase: "yes"]
    description: "Counts the number of users who made a repeat purchase within 60 days."
  }

  measure: 60_days_repeat_purchase_rate {
    type: number
    sql: ${60_day_repeat_users_count} / NULLIF(${users.count}, 0);;
    value_format_name: percent_2
    drill_fields: [user_id]
    description: "Calculates the percentage of customers who made a repeat purchase within 60 days."
  }


  set: detail {
    fields: [
      user_id,
      order_sequence,
      previous_order_date,
      has_subsequent_order
    ]
  }
}
