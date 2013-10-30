class Calculation < ActiveRecord::Base
    has_one :result
    attr_accessible :call_num_end, :call_num_start, :collection_code, :library_code, :travel_time, :avg_feet_moved_per_trip, :load_time, :unload_time
    after_initialize :setup_defaults
    include MathUtils

    def calculate
        self.result = LibraryCloud.new.pages_in_range(library_code, collection_code, call_num_start, call_num_end)
    end

    private

    def setup_defaults
        self.avg_feet_moved_per_trip ||= 4.0
        self.load_time ||= 5.0
        self.unload_time ||= 5.0
    end
end
