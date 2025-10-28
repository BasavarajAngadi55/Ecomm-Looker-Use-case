# /views/products.view.lkml (Ensure this is the ONLY file defining this view)
view: +products {
  # The sql_table_name parameter indicates the underlying database table
  sql_table_name: `thelook.products` ;;

  # 1. CORE DIMENSIONS (Required for joins and basic filtering)
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: distribution_center_id {
    type: number
    sql: ${TABLE}.distribution_center_id ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  # Base drill field for the view
  drill_fields: [id]

  # 2. FILTERS (For user input on the dashboard)

  filter: select_category {
    type: string
    # The suggest_dimension uses the unqualified dimension name from this view
    suggest_explore: order_items
    suggest_dimension: category
  }

  filter: select_brand {
    type: string
    suggest_explore: order_items
    suggest_dimension: brand
  }

  # 3. DYNAMIC COMPARISON DIMENSIONS (The core of the Brand Comparison Use Case)

  dimension: category_comparison {
    label: "Selected Category vs. All Others"
    type: string
    sql:
      CASE
      # Liquid check: Is the row's category the one the user selected in the filter?
      WHEN {% condition select_category %}
        ${category}
        {% endcondition %}
      THEN ${category}
      ELSE 'All Other Categories'
      END
      ;;
    drill_fields: [brand]
  }

  dimension: brand_comparison {
    label: "Selected Brand vs. All Others"
    type: string
    sql:
      CASE
      # Liquid check: Is the row's brand the one the user selected in the filter?
      WHEN {% condition select_brand %}
        ${brand}
        {% endcondition %}
      THEN ${brand}
      ELSE ${brand} || ' - Other Brands'
      END
      ;;
    drill_fields: [category]
  }
}
