# The name of this view in Looker is "Users"
view: users {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `thelook.users` ;;
  drill_fields: [id]

  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Age" in Explore.

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
    description: "Represents the age of users."
  }
  dimension: age_group {
    type: tier
    tiers: [15, 26, 36, 51, 66]
    sql: ${users.age};;
    style: integer
    drill_fields: [gender]
    description: "Categorizes users based on their age into predefined groups."
  }


  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_age {
    type: sum
    sql: ${age} ;;
  }
  measure: average_age {
    type: average
    sql: ${age} ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
    description: "Represents the city of users."
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
    description: "Represents the country of users."
  }
  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: created {
    type: time
    timeframes: [raw, time, day_of_month, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
    description: "Represents the email addresses of users."
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
    description: "Represents the first names of users."
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
    description: "Represents the gender of users."
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
    description: "Represents the last names of users."
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
    description: "Represents the latitude coordinates of users' locations."
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
    description: "Represents the longitude coordinates of users' locations."
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}.postal_code ;;
    description: "Represents the postal codes of users."
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
    map_layer_name: us_states
    drill_fields: [zip, city]
    description: "Represents the states of users (for US users)."
  }
  dimension: zip {
    label: "Zip"
    type: zipcode
    sql: ${TABLE}.zip ;;
    description: "Represents the zip codes of users."
  }

  dimension: street_address {
    type: string
    sql: ${TABLE}.street_address ;;
    description: "Represents the street addresses of users."
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
    drill_fields: [products.brand, products.category]
    description: "Represents the traffic sources through which users accessed the platform."
  }
  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, events.count, order_items.count]
  }
  dimension: location {
    label: "Location"
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
    description: "Represents the exact location (latitude and longitude) of users."
  }

  dimension: approx_latitude {
    label: "Approx Latitude"
    type: number
    sql: round(${TABLE}.latitude,1) ;;
    description: "Represents the approximate latitude coordinates of users' locations."
  }

  dimension: approx_longitude {
    label: "Approx Longitude"
    type: number
    sql:round(${TABLE}.longitude,1) ;;
    description: "Represents the approximate longitude coordinates of users' locations."
  }

#   dimension: approx_location {
#     label: "Approx Location"
#     type: location
#     drill_fields: [location]
#     description: "Represents the approximate location (latitude and longitude) of users."
# }
}
