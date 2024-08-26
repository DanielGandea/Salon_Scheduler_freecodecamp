#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Welcome at Danny's Salon ~~"

MAIN_MENU()
{

  if [[ $1 ]]
  then
    echo $1
  fi

  echo -e "\nWhat service do you want?"
  echo -e "\n1) cut\n2) color\n3) extension\n4) trim\n5) style\n6) massage\n0) Exit"

  read SERVICE_ID_SELECTED


  # if input not number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]$ ]]
  then
    MAIN_MENU "Please enter a valid ID ..."

  else  
    # service selection
    case $SERVICE_ID_SELECTED in
    1|2|3|4|5|6) SCHEDULE_MENU ;;
    0) EXIT ;;
    *) MAIN_MENU "Sorry, can't find this one. Please choose a service from the list." ;;
    esac

  fi

}

SCHEDULE_MENU()
{
  echo "What's your phone number?"
  read CUSTOMER_PHONE

  # check inputted phone number
  if [[ ! $CUSTOMER_PHONE =~ [0-9] ]]
  then
    MAIN_MENU "Please enter a valid phone number..."
  fi


  # check if customer allready into database
  CUSTOMER_NAME=$($PSQL"SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo "$CUSTOMER_NAME"


  # if no such customer, add them
  if [[ -z $CUSTOMER_NAME ]]
  then

    echo -e "What's your name?"
    read CUSTOMER_NAME

    # insert the new customer
    INSERT_CUSTOMER_RESULT=$($PSQL"INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

  fi

  # ask the time for entry
  echo -e "When do you want to schedule your visit? (hour minutes meridiem)"
  read SERVICE_TIME
  
  # read input until its correct
  while [[ ! $SERVICE_TIME =~ [0-9] ]]
  do
    echo "Please enter a valid hour."
    read SERVICE_TIME
  done

  # format timing in subshell
  SERVICE_TIME=$( echo $SERVICE_TIME | sed 's/ /:/' )

  # insert the appointment
  CUSTOMER_ID=$($PSQL"SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT_RESULT=$($PSQL"INSERT INTO appointments(time, service_id, customer_id) VALUES('$SERVICE_TIME', $SERVICE_ID_SELECTED, $CUSTOMER_ID)")

  # display the final message
  SERVICE_NAME=$($PSQL"SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


EXIT()
{
  echo -e "\nThanks for coming here!"
}


MAIN_MENU