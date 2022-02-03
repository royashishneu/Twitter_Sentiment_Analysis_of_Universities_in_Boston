#! /bin/bash

cd /home/ubuntu/webapp || exit

rails db:create || echo "db already exists"
rails db:migrate

nohup rails server -b 0.0.0.0 -p 80 > ~/application.log 2>&1 &