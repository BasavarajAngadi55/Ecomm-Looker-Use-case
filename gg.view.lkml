
  view: add_a_unique_name_1760022136 {
    derived_table: {
      explore_source: order_items {
        column: sale_price {}
        column: creatd_month {}
      }
    }
    dimension: sale_price {
      description: ""
      type: number
    }
    dimension: creatd_month {
      description: ""
      type: date_month
    }
  }
