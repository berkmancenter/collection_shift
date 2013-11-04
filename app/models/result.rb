class Result < ActiveRecord::Base
    attr_accessible :cm_per_serial, :cm_per_volume, :multi_volumes, :pages, :records_without_pages, :serials, :total_records
    belongs_to :calculation
    serialize :multi_volumes
    serialize :pages
    serialize :serials
    before_create :setup_defaults
    include MathUtils

    def total_pages
        pages.empty? ? 0 : pages.reduce(:+)
    end

    def avg_pages_per_record
        return 0 if pages.empty?
        total_pages / pages.length
    end

    def pages_to_cm(page_count = nil)
        if page_count
        0.0052 * page_count + 0.75
        else
            pages.reduce(0){|sum, p| sum + (0.0052 * p + 0.75)}
        end
    end

    def mean_pages
        return 0 if pages.empty?
        total_pages / pages.count
    end

    def median_pages
        median(pages)
    end

    def mean_width 
        pages_to_cm(avg_pages_per_record)
    end

    def median_width 
        pages_to_cm(median(pages))
    end

    def serial_width 
        serials.empty? ? 0.0 : cm_per_serial * serials.reduce(:+)
    end

    def multi_mean_width 
        multi_volumes.empty? ? 0.0 : multi_volumes.reduce(:+) * mean_width
    end

    def multi_median_width 
        multi_volumes.empty? ? 0.0 : multi_volumes.reduce(:+) * median_width
    end

    def multi_constant_width
        multi_volumes.empty? ? 0.0 : multi_volumes.reduce(:+) * cm_per_volume
    end

    def pageless_mean_width
        records_without_pages * mean_width
    end

    def pageless_median_width
        records_without_pages * median_width
    end

    def total_width 
        pages_to_cm + serial_width + multi_constant_width + pageless_median_width
    end

    private
    def setup_defaults
        self.cm_per_serial ||= 0.2
        self.cm_per_volume ||= 3
        self.serials ||= []
        self.pages ||= []
        self.multi_volumes ||= []
        self.records_without_pages ||= 0
    end
end
