class Calculation < ActiveRecord::Base
    has_one :result
    attr_accessible :call_num_end, :call_num_start, :collection_code, :library_code, :travel_time, :avg_feet_moved_per_trip, :load_time, :unload_time, :email_to_notify
    after_initialize :setup_defaults
    validates :call_num_start, :call_num_end, :library_code, :collection_code, :travel_time, :avg_feet_moved_per_trip, :load_time, :unload_time, :presence => true
    validate :call_numbers_in_library_cloud
    validate :library_records_in_library_cloud
    include MathUtils

    def calculate
        self.result = LibraryCloud.new.build_result(library_code, collection_code, call_num_start, call_num_end)
    end

    private

    def setup_defaults
        self.avg_feet_moved_per_trip ||= 4.0
        self.load_time ||= 5.0
        self.unload_time ||= 5.0
    end

    def library_records_in_library_cloud
        lc = LibraryCloud.new
        unless lc.has_library_records?(library_code)
            errors.add(:library_code, "isn't present in LibraryCloud.")
        end
    end

    def call_numbers_in_library_cloud
        lc = LibraryCloud.new
        unless lc.has_call_number?(call_num_start)
            errors.add(:call_num_start, "isn't present in LibraryCloud.")
        end
        unless lc.has_call_number?(call_num_end)
            errors.add(:call_num_end, "isn't present in LibraryCloud")
        end
    end
end
