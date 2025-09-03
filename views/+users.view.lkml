include: "/views/users.view"

view: +users {
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
         WHEN DATE_DIFF(CURRENT_DATE(), DATE(${created_date}), DAY) <= 90
           THEN 'New Customer'
         ELSE 'Longer-Term Customer'
       END ;;
  }

# Add these dimensions and measures to your users.view file

  dimension: days_since_signup {
    type: number
    description: "The number of days since a customer has signed up on the website."
    label: "Days Since Signup"
    sql: DATE_DIFF(CURRENT_DATE(), DATE(${created_date}), DAY) ;;
  }

  dimension: months_since_signup {
    type: number
    description: "The number of months since a customer has signed up on the website."
    label: "Months Since Signup"
    sql: DATE_DIFF(CURRENT_DATE(), DATE(${created_date}), MONTH) ;;
  }

  measure: average_days_since_signup {
    type: average
    description: "Average number of days between a customer initially registering and now."
    label: "Average Number of Days Since Signup"
    sql: ${days_since_signup} ;;
    value_format_name: decimal_1
  }

  measure: average_months_since_signup {
    type: average
    description: "Average number of months between a customer initially registering and now."
    label: "Average Number of Months Since Signup"
    sql: ${months_since_signup} ;;
    value_format_name: decimal_1
  }
  }
