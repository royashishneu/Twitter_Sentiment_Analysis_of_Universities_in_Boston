class SearchController < ApplicationController
    def index
    end
    
    def search
        @token = Time.now.utc.strftime('%m/%d/%Y %H:%M %p')
    end

    def result
        result_num    =  Array.new(5, 0)
        like_count    =  Array.new(5, 0)
        forward_count =  Array.new(5, 0)
        records = Record.where(keyword: params[:query], token: params[:token])
        records.each { |record|
            index                  = record.sentiment_res.to_i + 2
            result_num[index]     += 1
            like_count[index]     += record.like_num
            forward_count[index]  += record.retweet_num
        }
        if params[:type] == "result"
            render status: 200, json: result_num
            return
        end
        if params[:type] == "like"
            render status: 200, json: like_count
            return
        end
        if params[:type] == "forward"
            render status: 200, json: forward_count
            return
        end

        render status: 200, json: Record.where(keyword: params[:query], token: params[:token])
    end

    def show_result
        @result_num    =  Array.new(5, 0)
        @like_count    =  Array.new(5, 0)
        @forward_count =  Array.new(5, 0)
        records = Record.where(keyword: params[:query], token: params[:token])
        records.each { |record|
            index                  = record.sentiment_res.to_i + 2
            @result_num[index]     += 1
            @like_count[index]     += record.like_num
            @forward_count[index]  += record.retweet_num
        }
    end
end
