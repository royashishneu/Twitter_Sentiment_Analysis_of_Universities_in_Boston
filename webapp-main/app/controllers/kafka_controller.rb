class KafkaController < ApplicationController
    def testsend
        KAFKA.deliver_message("Hello, World!", topic: "twitterdata")
    end

    def testget
    end
end
