#!/bin/bash

kcadm=/opt/keycloak/bin/kcadm.sh

# Create a dev workshop user ...
$kcadm create users \
  -r werkstatt-hub \
  -s username="aw40hub-dev-workshop" \
  -s credentials='[{"type": "password", "value": "dev"}]' \
  -s enabled=true

# ... and assign the appropriate workshop role
$kcadm add-roles \
  -r werkstatt-hub \
  --uusername aw40hub-dev-workshop \
  --rolename workshop

# Also assign the role 'shared' to enable access to /shared/... API endpoints
$kcadm add-roles \
  -r werkstatt-hub \
  --uusername aw40hub-dev-workshop \
  --rolename shared

# Create a dev client
$kcadm create clients \
  -r werkstatt-hub \
  -s clientId=aw40hub-dev-client \
  -s secret=N5iImyRP1bzbzXoEYJ6zZMJx0XWiqhCw \
  -s publicClient=false \
  -s directAccessGrantsEnabled=true

exit 0
