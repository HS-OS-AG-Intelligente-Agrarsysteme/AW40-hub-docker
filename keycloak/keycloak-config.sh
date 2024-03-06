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

# Setup Client
$kcadm config credentials \
    --server http://keycloak:8080 \
    --realm master \
    --user ${KEYCLOAK_ADMIN} \
    --password ${KEYCLOAK_ADMIN_PASSWORD}

# Check if Realm already exists
$kcadm get realms --fields realm | grep -q werkstatt-hub
if [ $? -eq 0 ]
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
	-s description="Role for Data Analysts"

$kcadm create roles \
	-r werkstatt-hub \
	-s name=${WERKSTATT_MECHANIC_ROLE} \
	-s description="Role for Mechanics"

$kcadm create roles \
	-r werkstatt-hub \
	-s name=workshop \
	-s description="Role for basic API Access"

$kcadm create roles \
	-r werkstatt-hub \
	-s name=shared \
	-s description="Role for API shared Endpoint"

# Add Groups
$kcadm create groups \
    -r werkstatt-hub \
    -s 'attributes."policy"=["readwrite"]' \
    -s name="Mechanics"

$kcadm add-roles \
    -r werkstatt-hub \
    --gname Mechanics \
    --rolename workshop \
    --rolename ${WERKSTATT_MECHANIC_ROLE}

$kcadm create groups \
    -r werkstatt-hub \
    -s 'attributes."policy"=["readwrite"]' \
    -s name="Analysts"

$kcadm add-roles \
    -r werkstatt-hub \
    --gname Analysts \
    --rolename workshop \
    --rolename shared \
    --rolename ${WERKSTATT_ANALYST_ROLE}

# Add Client Scopes
MINIO_SCOPE_ID=$(
    $kcadm create client-scopes \
        -i \
        -r werkstatt-hub \
        -s name=minio-policy-scope \
        -s protocol=openid-connect \
        -s 'attributes."include.in.token.scope"=true'
)

# Add Mappings
$kcadm create client-scopes/${MINIO_SCOPE_ID}/protocol-mappers/models \
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
    -s credentials='[{"type":"password","value":"'${MINIO_ADMIN_WERKSTATTHUB_PASSWORD}'"}]'

$kcadm create users \
    -r werkstatt-hub \
    -s username=${WERKSTATT_ANALYST} \
    -s enabled=true \
    -s groups='["Analysts"]' \
    -s credentials='[{"type":"password","value":"'${WERKSTATT_ANALYST_PASSWORD}'"}]'

$kcadm create users \
    -r werkstatt-hub \
    -s username=${WERKSTATT_MECHANIC} \
    -s enabled=true \
    -s groups='["Mechanics"]' \
    -s credentials='[{"type":"password","value":"'${WERKSTATT_MECHANIC_PASSWORD}'"}]'

$kcadm create users \
    -r werkstatt-hub \
    -s username="aw40hub-dev-workshop" \
    -s credentials='[{"type": "password", "value": "dev"}]' \
    -s enabled=true

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
    -s description="Client für Developer" \
    -s secret=N5iImyRP1bzbzXoEYJ6zZMJx0XWiqhCw \
    -s publicClient=false \
    -s directAccessGrantsEnabled=true

$kcadm create clients \
    -r werkstatt-hub \
    -s clientId=aw40hub-frontend \
    -s enabled=true \
    -s description="Client for Frontend" \
    -s publicClient=true \
    -s clientAuthenticatorType=client-secret \
    -s webOrigins='["*"]' \
    -s redirectUris=$(var_to_kc_array "$FRONTEND_REDIRECT_URIS") \
    -s directAccessGrantsEnabled=true \
    -s 'attributes."post.logout.redirect.uris"="+"'

MINIO_ID=$(
    $kcadm create clients \
        -i \
        -r werkstatt-hub \
        -s clientId=minio \
        -s enabled=true \
        -s description="Client for MinIO" \
        -s directAccessGrantsEnabled=true \
        -s clientAuthenticatorType=client-secret \
        -s webOrigins='["*"]' \
        -s redirectUris='["*"]' \
        -s directAccessGrantsEnabled=true \
        -s secret=${MINIO_CLIENT_SECRET}
)

$kcadm update clients/${MINIO_ID}/default-client-scopes/${MINIO_SCOPE_ID} \
    -r werkstatt-hub

exit 0