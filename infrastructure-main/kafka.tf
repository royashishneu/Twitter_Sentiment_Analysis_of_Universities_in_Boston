resource "aws_security_group" "kafka_sg" {
  name        = "kafka_sg"
  description = "Only allow traffic from subnet"
  vpc_id      = aws_vpc.csye7200.id

  ingress = [
    {
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "kafka port"
      from_port        = 9092
      to_port          = 9092
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "kafka"
  }
}

data "aws_ami" "kafka_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.kafka_ami_name]
  }


  owners = [var.AMI_owner]
}

resource "aws_iam_role" "kafka_role" {
  name               = "kafka_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "kafka_profile" {
  name = "kafka_role"
  role = aws_iam_role.kafka_role.name
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy-kafka-attach" {
  role       = aws_iam_role.kafka_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


resource "aws_instance" "kafka" {
  for_each                = local.kafka_index
  ami                     = data.aws_ami.kafka_ami.id
  instance_type           = "t2.medium"
  disable_api_termination = false
  subnet_id               = aws_subnet.subnet["us-east-1a"].id
  vpc_security_group_ids  = [aws_security_group.kafka_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.kafka_profile.name
  key_name                = var.key_pair_name
  user_data               = <<EOF
#! /bin/bash
rm /home/ubuntu/kafka_2.13-2.5.0/config/server.properties
echo -e "{
    \"agent\": {
        \"metrics_collection_interval\": 10,
        \"logfile\": \"/var/logs/amazon-cloudwatch-agent.log\"
    },
    \"logs\": {
        \"logs_collected\": {
            \"files\": {
                \"collect_list\": [
                    {
                        \"file_path\": \"/var/log/cloud-init-output.log\",
                        \"log_group_name\": \"csye7200\",
                        \"log_stream_name\": \"kafka-${each.value}-init\"
                    }
                ]
            }
        },
        \"log_stream_name\": \"cloudwatch_log_stream\"
    }
}" >> /home/ubuntu/default_cw_config.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/home/ubuntu/default_cw_config.json
echo -e "broker.id=${each.value}
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=data/kafka-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=${aws_instance.zookeeper.private_ip}:2181
zookeeper.connection.timeout.ms=18000
group.initial.rebalance.delay.ms=0
" >> /home/ubuntu/kafka_2.13-2.5.0/config/server.properties
chmod 777 /home/ubuntu/kafka_2.13-2.5.0/config/server.properties
nohup /home/ubuntu/kafka_2.13-2.5.0/bin/kafka-server-start.sh /home/ubuntu/kafka_2.13-2.5.0/config/server.properties > ~/kafka.log 2>&1 &
sleep 60
/home/ubuntu/kafka_2.13-2.5.0/bin/kafka-topics.sh --create --zookeeper ${aws_instance.zookeeper.private_ip}:2181 --replication-factor 3 --partitions 3 --topic twitterdata

EOF

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
  tags = {
    Name = "kafka"
  }
}