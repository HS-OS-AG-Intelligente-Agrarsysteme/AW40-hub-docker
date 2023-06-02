#!/bin/bash

/usr/bin/mc alias set myminio http://minio:9000 ${S3_ROOT_USER} ${S3_ROOT_PASSWORD};
/usr/bin/mc mb myminio/werkstatthub;
exit 0;
