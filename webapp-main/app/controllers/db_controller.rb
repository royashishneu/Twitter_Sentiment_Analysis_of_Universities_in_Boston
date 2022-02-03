class DbController < ApplicationController
    def test
        r = Record.new
        r.key_name = "test"
        r.result   = "positive"
        r.save
    end

end
