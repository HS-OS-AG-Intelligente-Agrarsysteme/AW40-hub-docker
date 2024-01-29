#!/bin/bash

# Function to convert enviroment variable to kc array
function var_to_kc_array() {
  local ENV_VAR="$(echo -e "$1" | tr -d '[:space:]')"
  IFS=',' read -ra redir_arr <<< "$ENV_VAR"
  local KC_ARR=$(printf "\"%s\"," "${redir_arr[@]}")
  KC_ARR=${KC_ARR%,}
  echo "[$KC_ARR]"
}

kcadm=/opt/keycloak/bin/kcadm.sh

# Authenticate in order to use the Keycloak Admin CLI
$kcadm config credentials \
    --server http://keycloak:8080 \
    --realm master \
    --user ${KEYCLOAK_ADMIN} \
    --password ${KEYCLOAK_ADMIN_PASSWORD}

$kcadm create roles \
    -r werkstatt-hub \
    -s name=${WERKSTATT_ANALYST_ROLE}

$kcadm create roles \
    -r werkstatt-hub \
    -s name=${WERKSTATT_MECHANIC_ROLE}

# Create a user role 'workshop'
# This role is intended for access to the Hub API's workshop router
$kcadm create roles \
  -r werkstatt-hub \
  -s name=workshop

# Create a user role 'shared'
# This role is intended for access to the Hub API's shared router
$kcadm create roles \
  -r werkstatt-hub \
  -s name=shared

# Create MinIO administrator
$kcadm create users \
    -r werkstatt-hub \
    -s username=${MINIO_ADMIN_WERKSTATTHUB} \
    -s enabled=true \
    -s attributes.policy=consoleAdmin \
    -s credentials='[{"type":"password","value":"'${MINIO_ADMIN_WERKSTATTHUB_PASSWORD}'"}]'

# Create MinIO user with r/w access
$kcadm create users \
    -r werkstatt-hub \
    -s username=${WERKSTATT_ANALYST} \
    -s enabled=true \
    -s attributes.policy=readwrite \
    -s credentials='[{"type":"password","value":"'${WERKSTATT_ANALYST_PASSWORD}'"}]'

# Assign Analyst role
$kcadm add-roles \
    -r werkstatt-hub \
    --uusername ${WERKSTATT_ANALYST} \
    --rolename ${WERKSTATT_ANALYST_ROLE}

# Create MinIO user with r/w access
$kcadm create users \
    -r werkstatt-hub \
    -s username=${WERKSTATT_MECHANIC} \
    -s enabled=true \
    -s attributes.policy=readwrite \
    -s credentials='[{"type":"password","value":"'${WERKSTATT_MECHANIC_PASSWORD}'"}]'

# Assign Mechanic role
$kcadm add-roles \
    -r werkstatt-hub \
    --uusername ${WERKSTATT_MECHANIC} \
    --rolename ${WERKSTATT_MECHANIC_ROLE}

# Get the ID of the 'minio' client in the 'werkstatt-hub' realm
CLIENT_ID=$($kcadm get clients -r werkstatt-hub -q clientId=minio -F id | grep -oP '\w{8}-(\w{4}-){3}\w{12}' | cut -f1)

echo "The client ID of 'minio' in the 'werkstatt-hub' realm is: $CLIENT_ID"

# Update the client secret for the 'minio' client in the 'werkstatt-hub' realm
$kcadm update clients/$CLIENT_ID \
    -r werkstatt-hub \
    -s secret=${MINIO_CLIENT_SECRET}


# Get the ID of the 'aw40hub-frontend' client in the 'werkstatt-hub' realm
CLIENT_ID=$($kcadm get clients -r werkstatt-hub -q clientId=aw40hub-frontend -F id | grep -oP '\w{8}-(\w{4}-){3}\w{12}' | cut -f1)

echo "The client ID of 'aw40hub-frontend' in the 'werkstatt-hub' realm is: $CLIENT_ID"

# Update redirect uris for the 'aw40hub-frontend' client in the 'werkstatt-hub' realm
$kcadm update clients/$CLIENT_ID \
    -r werkstatt-hub \
    -s redirectUris=$(var_to_kc_array "$FRONTEND_REDIRECT_URIS")

exit 0
