#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Display Services list
SERVICE_MENU(){
  # Display menu
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo -e "\nThese are the services we offer\n"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  # Make menu selection
  echo -e "\nPlease select a service\n"
  read SERVICE_ID_SELECTED

  # Get the service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | xargs)

  # Get the maximum service ID
  MAX_SERVICE_ID=$($PSQL "SELECT MAX(service_id) FROM services" | xargs)

  # Debugging: Print values
  echo "Selected Service: $SERVICE_ID_SELECTED"
  echo "Max Service ID: $MAX_SERVICE_ID"

  # If input isn't a number in list
  if [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    echo "\"$SERVICE_ID_SELECTED\" is not a valid selection."
    SERVICE_MENU
  elif [[ "$SERVICE_ID_SELECTED" -gt "$MAX_SERVICE_ID" ]]; then
    echo "\"$SERVICE_ID_SELECTED\" is not a valid selection."
    SERVICE_MENU
  else
    echo -e "\nCan I take your phone number?"
    read CUSTOMER_PHONE

    # Does customer already exist?
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs)
    if [[ -z "$CUSTOMER_NAME" ]]; then
      # Add customer to db
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # Get customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs)

    # Get appointment time
    echo -e "\nWhat time would you like to schedule your $SERVICE_NAME for, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Insert appointment into db
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

SERVICE_MENU