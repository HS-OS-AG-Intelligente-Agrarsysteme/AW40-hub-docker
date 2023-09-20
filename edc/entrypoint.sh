#!/bin/sh

# Make a copy of the mounted file
cp /configs/$EDC_FS_CONFIG $EDC_FS_CONFIG

# Replace the placeholders in the copied properties file with the values of the environment variables
sed -i "s/\${EDC_ADDRESS}/$EDC_ADDRESS/g" $EDC_FS_CONFIG
sed -i "s/\${AWS_ADDRESS}/$AWS_ADDRESS/g" $EDC_FS_CONFIG
sed -i "s/\${POSTGRES_USER}/$POSTGRES_USER/g" $EDC_FS_CONFIG
sed -i "s/\${POSTGRES_PASSWORD}/$POSTGRES_PASSWORD/g" $EDC_FS_CONFIG

java -jar connector.jar