include: "/views/products.view"
view: +products{
  sql_table_name: `thelook.products` ;;
  drill_fields: [id]

  filter: select_brand {
    type: string
    suggest_explore: order_items
    suggest_dimension: products.brand
  }
  dimension: brand_comparison {
    type: string
    sql:
      CASE
      WHEN {% condition select_brand %}
        ${brand}
        {% endcondition %}
      THEN ${brand}
      ELSE 'All Other brands'
      END
      ;;
    drill_fields: [category]
  }
  }
