#!/bin/bash
#ssh -i canvas-ubuntu.pem root@47.75.190.40
#ssh -i id_rsa_aliyun_pu chengma@47.75.190.40
echo "Start Copying Temp File."
ssh -t -i id_rsa_aliyun_pu chengma@47.75.190.40 "docker cp a646f00fb65e:/opt/canvas/canvas-lms/tmp ~/workspace"
echo "Fetch temp file from 40 finished"
scp -i id_rsa_aliyun_pu -r chengma@47.75.190.40:~/workspace/tmp .
scp -i id_rsa_aliyun_pu -r tmp/ chengma@47.75.159.169:~/workspace/
ssh -t -i id_rsa_aliyun_pu chengma@47.75.159.169 "docker cp ~/workspace/tmp 42f860bc4ba3:/opt/canvas/canvas-lms/tmp" 
