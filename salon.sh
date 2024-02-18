#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -c"
SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services")
NUM_OF_SERVICES=$(echo $($PSQL "SELECT COUNT(*) FROM services") | sed -E 's/count| |-+|\(1 row\)//g')

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  
  echo "$SERVICES_OFFERED" | while read ID BAR SERVICE
  do
    if [[ $ID =~ ^[0-9]+ ]]
    then
      echo "$ID) $SERVICE"
    fi
  done

  echo -e "\nSelect a service"
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    if [[ $NUM_OF_SERVICES -ge $SERVICE_ID_SELECTED ]]
    then
      GET_SERVICE_VALUES
    else
      MAIN_MENU "invalid service number"
    fi
  else
    MAIN_MENU "service must be a number"
  fi
}

GET_SERVICE_VALUES() {
  echo -e "\nPlease enter your phone number"
  read CUSTOMER_PHONE
  DOES_PHONE_EXIST=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ $DOES_PHONE_EXIST =~ "(0 rows)" ]]
  then
    echo -e "\n looks like you're a new customer, what is your name?"
    read CUSTOMER_NAME
    CUSTOMER_SAVED=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  else
    CUSTOMER_NAME=$(echo $($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'") | sed -E 's/name| |-+|\(1 row\)//g')
  fi
  echo -e "\nPlease enter your service time:"
  read SERVICE_TIME
  CUSTOMER_ID=$( echo $($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'") | sed -E 's/customer_id| |-+|\(1 row\)//g')
  APPOINTMENT_SAVED=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  SERVICE_RECEIVED=$( echo $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") | sed -E 's/name| |-+|\(1 row\)//g')
  echo -e "\nI have put you down for a $SERVICE_RECEIVED at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
