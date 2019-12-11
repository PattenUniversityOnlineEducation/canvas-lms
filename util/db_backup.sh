#!/bin/bash

export TIME=`date "+%Y%m%d-%H%M%S"`
export SOURCE_IP=47.75.190.40
export SOURCE_DOCKER=a646f00fb65e
export TARGET_IP=47.75.159.169
export TARGET_DOCKER=d48fd120ae5f

echo ">>Start database transfering."
echo ">>At time $TIME"

echo ">>Source: $SOURCE_IP : $SOUECE_DOCKER"
echo ">>Destination: $TARGET_IP: $TARGET_DOCKER"

ssh -t -i id_rsa_aliyun_pu chengma@$SOURCE_IP "
docker exec -it $SOURCE_DOCKER pg_dump -U postgres -Fc canvas_development > /tmp/dump_$TIME.db"
echo "\n>>Source exporting completed"

scp -i id_rsa_aliyun_pu -r chengma@$SOURCE_IP:/tmp/dump_$TIME.db ~/
echo "\n>>Downloading completed"

scp -i id_rsa_aliyun_pu -r ~/dump_$TIME.db chengma@$TARGET_IP:/tmp/
echo "\n>>Uploading completed"

ssh -t -i id_rsa_aliyun_pu chengma@$TARGET_IP "
docker exec -it $TARGET_DOCKER pg_restore -U postgres -n public -c -1 -d canvas_development /tmp/dump_$TIME.db"
echo "\nRestoring completed"
