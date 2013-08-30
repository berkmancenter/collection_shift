# encoding: UTF-8

class LibraryCloud
    include HTTParty
    base_uri 'librarycloud.harvard.edu/v1/api'
    format :json
    disable_rails_query_string_format

    LIMIT = 250
    MAX_RETURNED_RECORDS = 20000

    def initialize
        @item_api = LibraryCloudItems.new
    end

    def pages_in_range(library_code, collection_code, start_call_num, end_call_num)
        result = Result.new(:serials => [], :pages => [], :multi_volumes => [])
        start_index = 0
        result.total_records = total_records(library_code, start_call_num, end_call_num)
        result.records_without_pages = 0
        if result.total_records > MAX_RETURNED_RECORDS
            puts 'Range too large'
            return
        end
        loop do
            results = records_in_range(library_code, start_call_num, end_call_num, start_index)
            results['docs'].each do |doc|
                pages = pages_to_int(doc['pages'])
                # "Notated Music"
                if doc['format'] == 'Serial'
                    count = @item_api.count(library_code, collection_code, doc['id_inst'])
                    if count
                        result.serials << count
                    end
                elsif doc['format'] == 'Book' && pages.nil?
                    count = @item_api.count(library_code, collection_code, doc['id_inst'])
                    if count
                        result.multi_volumes << count
                    else
                        Rails.logger.warn("Fetcher - Book without pages or items: #{doc['id_inst']}")
                    end
                elsif pages
                    result.pages << pages
                else
                    Rails.logger.warn("Fetcher - Something else: #{doc['id_inst']}")
                    result.records_without_pages += 1
                end
            end
            start_index += LIMIT
            break if start_index > result.total_records
        end
        result
    end

    def total_records(library_code, start_call_num, end_call_num)
        records_in_range(library_code, start_call_num, end_call_num, 0, 1)['num_found']
    end

    def records_in_range(library_code, start_call_num, end_call_num, start_index = 0, limit = LIMIT)
        num_a = call_num_to_sort_num(start_call_num)
        num_b = call_num_to_sort_num(end_call_num)
        start_number, end_number = [num_a, num_b].minmax
        response = self.class.get('/item',
            :query => {
                :filter => [
                    "loc_call_num_sort_order:[#{start_number} TO #{end_number}]",
                    "holding_libs:#{library_code}"
                ],
                :start => "#{start_index}",
                :limit => "#{limit}"
            }
        )
        puts response.request.uri
        response
    end

    def pages_to_int(pages)
        return unless pages
        roman_numeral = /(\b|^)[ivxlcmIVXLCM]+\b/
        unwanted_chars = /\W[lvℓ]/
        number_in_brackets = /\[\d\]/
        all_words = /^[-_a-zA-Z ]+$/
        segments = pages.split(',')
        segments.delete_if{|segment| segment.match(all_words) || segment.match(roman_numeral) || segment.match(unwanted_chars) || segment.match(number_in_brackets) || segment.empty?}
        return if segments.empty?
        output = segments.first.split('-').last.strip.gsub(/(\[|\])/,'').to_i
        return if output == 0
        output
    end

    def call_num_to_sort_num(call_num)
        self.class.get('/item', { :query => { :filter => "call_num:#{call_num}" }})['docs'].first['loc_call_num_sort_order'].first
    end
end
