# Define the database connection to be used for this model.
connection: "looker_partner_demo"

# include all the views
include: "/views/**/*.view.lkml"

# Datagroups define a caching policy for an Explore. To learn more,
# use the Quick Help panel on the right to see documentation.

datagroup: fashionly_case_study_default_datagroup {
  max_cache_age: "1 hour"
}

persist_with: fashionly_case_study_default_datagroup

# The "Order Items" Explore is for detailed order analysis.
explore: order_items {
  label: "Order Items"
  description: "Detailed order and item-level analysis, including product, user, and inventory information."

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${order_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}

# The "Customers" Explore is for user behavior analysis.
explore: users {
  label: "Customers"
  description: "User-centric analysis focusing on demographics and behavior."

  # This new join connects all customer lifetime metrics to the user data.
  join: customer_lifetime_stats {
    type: left_outer
    sql_on: ${users.id} = ${customer_lifetime_stats.user_id} ;;
    relationship: one_to_one
  }
}

# Add a new explore for the customer lifetime analysis view.
explore: customer_lifetime_stats {
  label: "Customer Lifetime Analysis"
  description: "Comprehensive analysis of customer behavior, lifetime value, and retention patterns."
}

# Add a new explore for brand and category repeat purchase analysis.
explore: brand_category_repeat_analysis {
  label: "Brand & Category Repeat Purchase Analysis"
  description: "Analysis of repeat purchase rates by brand and category to identify products driving customer retention."
}
