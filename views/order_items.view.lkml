view: order_items {
  sql_table_name: `looker-partners.thelook.order_items` ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month,day_of_month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
  dimension_group: delivered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.delivered_at ;;
  }
  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }
  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }
  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }
  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.returned_at ;;
  }
  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }
  dimension_group: shipped {
    type: time
    timeframes: [raw, time, date, week, month, day_of_month,quarter, year]
    sql: ${TABLE}.shipped_at ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }
  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }
  dimension: creatd_month {
    type: date_month
    sql: ${created_date} ;; # Or whatever your date field is named
  }
  dimension: is_mtd {
    type: yesno
    sql:
    EXTRACT(MONTH FROM ${created_date}) = EXTRACT(MONTH FROM CURRENT_DATE())
    AND EXTRACT(YEAR FROM ${created_date}) = EXTRACT(YEAR FROM CURRENT_DATE())
    AND EXTRACT(DAY FROM ${created_date}) <= EXTRACT(DAY FROM CURRENT_DATE()) ;;
  }
  dimension: is_previous_mtd {
    type: yesno
    sql:
    EXTRACT(MONTH FROM ${created_date}) = EXTRACT(MONTH FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND EXTRACT(YEAR FROM ${created_date}) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND EXTRACT(DAY FROM ${created_date}) <= EXTRACT(DAY FROM CURRENT_DATE()) ;;
  }
  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  id,
  users.last_name,
  users.id,
  users.first_name,
  inventory_items.id,
  inventory_items.product_name,
  products.name,
  products.id
  ]
  }

}
