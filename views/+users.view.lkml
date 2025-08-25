include: "/views/users.view"

view: +users{
  # UPDATED dimension with MTD filtering
  dimension: signup_month_comparison {
    type: string
    sql:
    CASE
      WHEN DATE_TRUNC(DATE(${created_date}), MONTH) = DATE_TRUNC(CURRENT_DATE(), MONTH)
           AND EXTRACT(DAY FROM DATE(${created_date})) <= EXTRACT(DAY FROM CURRENT_DATE())
      THEN 'Current Month'
      WHEN DATE_TRUNC(DATE(${created_date}), MONTH) = DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)
           AND EXTRACT(DAY FROM DATE(${created_date})) <= EXTRACT(DAY FROM CURRENT_DATE())
      THEN 'Previous Month'
      ELSE 'Other'
    END
    ;;
  }

  dimension: signup_day_of_month {
    type: number
    sql: EXTRACT(DAY FROM DATE(${created_date})) ;;
  }

  # ADD this helper dimension to filter in your query
  dimension: is_valid_mtd_day {
    type: yesno
    sql: EXTRACT(DAY FROM DATE(${created_date})) <= EXTRACT(DAY FROM CURRENT_DATE()) ;;
    hidden: yes
  }

  dimension: customer_type {
    type: string
    sql: CASE
         WHEN DATEDIFF(CURRENT_DATE(), ${created_date}) <= 90
         THEN 'New Customer'
         ELSE 'Longer-Term Customer'
       END ;;
  }
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: _users {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
