#! /bin/bash

aws elbv2 register-targets --target-group-arn $(cat /home/ubuntu/lb_arn) --targets Id=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id),Port=80
sleep 10
curl http://localhost:3000 || curl http://localhost:80