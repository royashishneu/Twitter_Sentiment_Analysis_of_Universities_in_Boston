#! /bin/bash

cp -r /home/ubuntu/webapp-install/* /home/ubuntu/webapp

cd /home/ubuntu/webapp || exit

bundle install

yarn add chartkick chart.js

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/home/ubuntu/webapp/infrastracture/cloudwatch_config.json