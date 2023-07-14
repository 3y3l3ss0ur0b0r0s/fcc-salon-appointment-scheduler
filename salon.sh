#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Gummy's Hair Salon ~~~~~\n"

MAIN_MENU() {
  # user can choose a service
  if [[ $1 ]]
    then echo -e "\n$1"
  fi

  # display prompt for user choice of service
  echo -e "\nHow can we help you?"

  # display list of services in format <service_id>) <service>
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services")

  if [[ -z $AVAILABLE_SERVICES ]]
    then
      # if no services availabe, send to main menu with message
      MAIN_MENU "Sorry, we do not have any services available right now."
    else
      # display available services
      echo -e "\nHere are the services we currently have available:"
      echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
      do
        echo "$SERVICE_ID) $SERVICE_NAME"
      done

      echo -e "\nEnter the number of the service you would like."
      read SERVICE_ID_SELECTED

      SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE $SERVICE_ID_SELECTED = service_id")

      if [[ -z $SERVICE_NAME_SELECTED ]]
        then
          # if input is not an existing service_id
          MAIN_MENU "Please enter a valid service number."
        else
          # otherwise, start scheduling the appointment
          SCHEDULE_APPOINTMENT $SERVICE_ID_SELECTED $SERVICE_NAME_SELECTED
      fi
  fi

  # read input
  read MAIN_MENU_SELECTION

  # if not valid service_id, send to MAIN_MENU with error message
}

# function for scheduling appointment will take service_id and name as arguments
SCHEDULE_APPOINTMENT() {
  SERVICE_ID=$1
  SERVICE_NAME=$2

  #echo You have requested service number $1, which is the $2 service.
  
  # prompt for phone number
  echo -e "\nPlease enter your phone number."
  read CUSTOMER_PHONE

  # check if customer already exists in table
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
    then
      # if customer doesn't exist in the table, 
      # get name
      echo -e "\nI see you are a new customer--what's your name?"
      read CUSTOMER_NAME

      # insert the new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi

  # get customer id for scheduling
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  echo -e "\nWhen would you like to schedule your appointment?"
  read SERVICE_TIME

  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")

  #SERVICE_FORMATTED=$(echo "$SERVICE_NAME" | sed -e 's/\(.*\)/\L\1/')

  #echo -e "\nI have put you down for a $SERVICE_FORMATTED appointment at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."

  exit 0
}

MAIN_MENU