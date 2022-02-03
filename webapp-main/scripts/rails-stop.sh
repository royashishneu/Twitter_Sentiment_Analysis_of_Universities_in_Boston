#! /bin/bash
aws elbv2 deregister-targets --target-group-arn $(cat /home/ubuntu/lb_arn) --targets  Id=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id),Port=80
kill -9 $(cat /home/ubuntu/webapp/tmp/pids/server.pid) || echo "No rails run"