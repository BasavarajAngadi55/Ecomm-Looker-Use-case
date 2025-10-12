include: "/views/products.view"
view: +products{
  sql_table_name: `thelook.products` ;;
  drill_fields: [id]

  filter: select_category {
    type: string
    suggest_explore: order_items
    suggest_dimension: products.category
  }
}
