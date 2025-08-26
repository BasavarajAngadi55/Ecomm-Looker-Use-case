include: "/views/order_items.view"
include: "/views/users.view"
view: +order_items{
  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name:usd_0
  }
  measure: average_sale_price {
    type: average
    sql: ${order_items.sale_price} ;;
    drill_fields: [inventory_items.product_brand, inventory_items.cost]
    description: "Calculates the average sale price of items."
  }
  measure: cumulative_total_sales {
    type: running_total
    sql: ${order_items.total_sale_price} ;;
    value_format_name: usd
    description: "Calculates the running total of sales revenue in USD."
  }
  measure: total_gross_revenue {
    type: sum
    sql: CASE WHEN ${order_items.status} NOT IN ('Cancelled', 'Returned') THEN ${order_items.sale_price} ELSE 0 END ;;
    value_format_name: usd_0
    drill_fields: [products.brand, products.category]
    description: "Calculates the total gross revenue by summing the sale prices of all items, excluding cancelled or returned items."
  }
  measure: revenue_percent_of_total {
    type: number
    sql: 100.0 * ${total_gross_revenue} / NULLIF(SUM(${total_gross_revenue}) OVER(), 0) ;;
    value_format: "0.0%"
    description: "Revenue as a % of total revenue across all brands."
  }

  measure: total_cost {
    type: sum
    sql: ${inventory_items.cost} ;;
    description: "Calculates the total cost of inventory items."
  }
  measure: average_cost {
    type: average
    sql: ${inventory_items.cost} ;;
    description: "Calculates the average cost of inventory items."
  }
  measure: total_gross_margin_amount {
    type: number
    sql:${total_gross_revenue} - ${total_cost}  ;;
    value_format_name: usd
    drill_fields: [products.category,products.brand]
    description: "Calculates the total gross margin amount by subtracting the total cost from the total gross revenue."
  }
  measure: average_gross_margin {
    type: number
    sql: CASE WHEN ${order_items.total_gross_revenue} IS NOT NULL THEN
         (${order_items.total_gross_revenue} - ${inventory_items.cost}) / NULLIF(${order_items.total_gross_revenue}, 0)
       ELSE NULL END ;;
    value_format_name: usd
    description: "Calculates the average gross margin as a percentage of total gross revenue."
  }
  measure: gross_margin_percentage {
    type: number
    sql: ${total_gross_margin_amount} / NULLIF(${total_gross_revenue}, 0) ;;
    value_format_name: percent_2
    drill_fields: [products.category, products.product_id]
    description: "Calculates the gross margin percentage."
  }
  measure: number_of_items_returned {
    type: count_distinct
    sql: ${status}='returned' ;;
    drill_fields: [products.brand]
    description: "Counts the number of items that have been returned."
  }
  measure: num_items_sold {
    type: count_distinct
    sql: CASE WHEN ${order_items.id} IS NOT NULL THEN ${order_items.id} ELSE NULL END ;;
    description: "Counts the number of distinct items sold."
  }
  measure: item_return_rate {
    type: number
    sql: ${order_items.number_of_items_returned} / NULLIF(${order_items.num_items_sold}, 0) ;;
    value_format_name: percent_2
    description: "Calculates the percentage of items returned out of the total items sold."
  }
  measure: number_of_customers_returning_items {
    type: count_distinct
    sql: CASE WHEN ${order_items.status} = 'returned' THEN ${order_items.user_id} ELSE NULL END ;;
    description: "Counts the number of customers who have returned items."
  }
  measure: percent_of_users_with_returns {
    type: percent_of_total
    sql: ${order_items.number_of_customers_returning_items} / ${users.count} ;;
    value_format_name: percent_2
    description: "Calculates the percentage of users who have returned items out of the total number of users."
  }
  measure: average_spend_per_customer {
    type: number
    sql: ${order_items.total_sale_price} / NULLIF(${users.count}, 0) ;;
    value_format_name: usd_0
    description: "Calculates the average spend per customer in USD."
    drill_fields: [products.brand, products.category]
  }
  measure: total_sales {
    type: sum
    sql: ${order_items.sale_price} ;;
    drill_fields: [order_items.order_id]
    description: "Total sales revenue."
    value_format: "$#,##0.00" # Changed to USD format with 2 decimals
  }
  measure: mtd_users_count {
    type: count_distinct
    sql: ${user_id} ;; # Count distinct users for MTD
    filters: [is_mtd: "yes"]
    drill_fields: [user_id, created_date] # Example drill fields
  }
  measure: prv_mtd_users_count {
    type: count_distinct
    sql: ${user_id} ;; # Count distinct users for MTD
    filters: [is_previous_mtd: "yes"]
    drill_fields: [user_id, created_date] # Example drill fields
  }
  dimension: age_group {
    type: tier
    tiers: [15,26,36,51,66]
    sql: ${users.age} ;;
    style: integer
    label: "Age Group" # User-friendly label for the UI
  }
  dimension: customer_type {
    type: string
    sql: CASE
         WHEN DATE_DIFF(CURRENT_DATE(), DATE(${created_date}), DAY) <= 90
           THEN 'New Customer'
         ELSE 'Longer-Term Customer'
       END ;;
  }


}
