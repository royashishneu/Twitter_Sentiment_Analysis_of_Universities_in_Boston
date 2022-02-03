require "kafka"

KAFKA = Kafka.new([ENV['KAFKA_IP0'] + ":9092", ENV['KAFKA_IP1'] + ":9092", ENV['KAFKA_IP2'] + ":9092"], client_id: "twitter")