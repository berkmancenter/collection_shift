class Calculation < ActiveRecord::Base
    has_one :result
    attr_accessible :call_num_end, :call_num_start, :collection_code, :library_code, :travel_time

    def calculate
        self.result = LibraryCloud.new.pages_in_range(library_code, collection_code, call_num_start, call_num_end)
    end
end
