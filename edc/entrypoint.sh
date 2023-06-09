#!/bin/sh

# Replace the placeholder in the properties file with the value of the environment variable
sed -i "s/\${HOST_IP_ADDRESS}/$HOST_IP_ADDRESS/g" config.properties
java -Dedc.fs.config=config.properties -Daws.accessKeyId=${S3_ROOT_USER} -Daws.secretAccessKey=${S3_ROOT_PASSWORD} -jar connector.jar
