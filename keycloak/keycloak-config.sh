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
jq=/opt/keycloak/bin/jq

# Setup Client
$kcadm config credentials \
    --server http://keycloak:8080 \
    --realm master \
    --user ${KEYCLOAK_ADMIN} \
    --password ${KEYCLOAK_ADMIN_PASSWORD}

# Check if realm already exists
REALM_ID=$(
    $kcadm get realms --fields realm,id | 
    $jq -r '.[] | select(.realm == "werkstatt-hub") | .id'
)

if [ ! -z "$REALM_ID" ]
then
    echo "Realm already exists. Skipping initialization."
    exit 0
fi

# Add Realms
$kcadm create realms \
    -s realm=werkstatt-hub \
    -s enabled=true

# Add Roles
$kcadm create roles \
	-r werkstatt-hub \
	-s name=${WERKSTATT_ANALYST_ROLE} \
	-s 'description=Role for Data Analysts'

$kcadm create roles \
	-r werkstatt-hub \
	-s name=${WERKSTATT_MECHANIC_ROLE} \
	-s 'description=Role for Machanics'

$kcadm create roles \
	-r werkstatt-hub \
	-s name=workshop \
	-s 'description=Role for basic API Access'

$kcadm create roles \
	-r werkstatt-hub \
	-s name=shared \
	-s 'description=Role for API shared Endpoint'

# Add Client Scopes
$kcadm create -x "client-scopes" \
    -r werkstatt-hub \
    -s name=minio-policy-scope \
    -s protocol=openid-connect \
    -s 'attributes."include.in.token.scope"=true'

# Get Scope ID
SCOPE_ID=$(
    $kcadm get -x "client-scopes" -r werkstatt-hub |
    $jq -r '.[] | select(.name == "minio-policy-scope") | .id'
)

# Add Mappings
$kcadm create client-scopes/${SCOPE_ID}/protocol-mappers/models \
    -r werkstatt-hub \
    -s name=minio-policy-mapper \
    -s protocol=openid-connect \
    -s protocolMapper=oidc-usermodel-attribute-mapper \
    -s 'config."aggregate.attrs"=true' \
    -s 'config."multivalued"=true' \
    -s 'config."userinfo.token.claim"=true' \
    -s 'config."user.attribute"="policy"' \
    -s 'config."id.token.claim"=true' \
    -s 'config."access.token.claim"=true' \
    -s 'config."claim.name"="policy"'

# Add Users
$kcadm create users \
    -r werkstatt-hub \
    -s username=${MINIO_ADMIN_WERKSTATTHUB} \
    -s enabled=true \
    -s attributes.policy=consoleAdmin \
    -s credentials='[{"type":"password","value":"'${MINIO_ADMIN_WERKSTATTHUB_PASSWORD}'"}]'

$kcadm create users \
    -r werkstatt-hub \
    -s username=${WERKSTATT_ANALYST} \
    -s enabled=true \
    -s attributes.policy=readwrite \
    -s credentials='[{"type":"password","value":"'${WERKSTATT_ANALYST_PASSWORD}'"}]'

$kcadm create users \
    -r werkstatt-hub \
    -s username=${WERKSTATT_MECHANIC} \
    -s enabled=true \
    -s attributes.policy=readwrite \
    -s credentials='[{"type":"password","value":"'${WERKSTATT_MECHANIC_PASSWORD}'"}]'

$kcadm create users \
    -r werkstatt-hub \
    -s username="aw40hub-dev-workshop" \
    -s credentials='[{"type": "password", "value": "dev"}]' \
    -s enabled=true

# Assign Roles
$kcadm add-roles \
    -r werkstatt-hub \
    --uusername ${WERKSTATT_ANALYST} \
    --rolename ${WERKSTATT_ANALYST_ROLE}

$kcadm add-roles \
    -r werkstatt-hub \
    --uusername ${WERKSTATT_MECHANIC} \
    --rolename ${WERKSTATT_MECHANIC_ROLE}

$kcadm add-roles \
    -r werkstatt-hub \
    --uusername aw40hub-dev-workshop \
    --rolename workshop

$kcadm add-roles \
    -r werkstatt-hub \
    --uusername aw40hub-dev-workshop \
    --rolename shared

# Add Clients
$kcadm create clients \
    -r werkstatt-hub \
    -s clientId=aw40hub-dev-client \
    -s enabled=true \
    -s 'description=Client für Developer' \
    -s secret=N5iImyRP1bzbzXoEYJ6zZMJx0XWiqhCw \
    -s publicClient=false \
    -s directAccessGrantsEnabled=true

$kcadm create clients \
    -r werkstatt-hub \
    -s clientId=aw40hub-frontend \
    -s enabled=true \
    -s 'description=Client for Frontend' \
    -s publicClient=true \
    -s 'clientAuthenticatorType=client-secret' \
    -s 'webOrigins=["*"]' \
    -s redirectUris=$(var_to_kc_array "$FRONTEND_REDIRECT_URIS") \
    -s directAccessGrantsEnabled=true \
    -s 'attributes."post.logout.redirect.uris"="+"'

$kcadm create clients \
    -r werkstatt-hub \
    -s clientId=minio \
    -s enabled=true \
    -s 'description=Client for MinIO' \
    -s directAccessGrantsEnabled=true \
    -s 'clientAuthenticatorType=client-secret' \
    -s 'webOrigins=["*"]' \
    -s 'redirectUris=["*"]' \
    -s directAccessGrantsEnabled=true \
    -s secret=${MINIO_CLIENT_SECRET}

# Add Client Scopes
SCOPE_ID=$(
    $kcadm get -x "client-scopes" -r werkstatt-hub |
    $jq -r '.[] | select(.name == "minio-policy-scope") | .id'
)
ID=$(
    $kcadm get clients -r werkstatt-hub --fields id,clientId |
    $jq -r '.[] | select(.clientId == "minio") | .id'
)

$kcadm update clients/${ID}/default-client-scopes/${SCOPE_ID} \
    -r werkstatt-hub

exit 0