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
        results = records_in_range(library_code, collection_code, start_call_num, end_call_num, nil)
        result.total_records = results['docs'].count
        result.records_without_pages = 0
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
        result
    end

    def total_records(library_code, start_call_num, end_call_num)
        records_by_page(library_code, start_call_num, end_call_num, 0, 1)['num_found']
    end

    def records_by_page(library_code, start_call_num, end_call_num, start_index = 0, limit = LIMIT)
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
        #puts response.request.uri
        response
    end

    def records_in_range(library_code, collection_code, start_call_num, end_call_num, limit = LIMIT)
        start_index = 0
        total_records = total_records(library_code, start_call_num, end_call_num)
        output = {}
        if total_records > MAX_RETURNED_RECORDS && limit == nil
            puts 'Range too large'
            return
        end
        if limit && limit < LIMIT
            output = records_by_page(library_code, start_call_num, end_call_num, start_index, limit)
            return filter_by_library_collection(start_call_num, end_call_num, output, library_code, collection_code)
        end
        loop do
            if output.empty?
                output = records_by_page(library_code, start_call_num, end_call_num, start_index)
                output = filter_by_library_collection(start_call_num, end_call_num, output, library_code, collection_code)
            else
                temp = records_by_page(library_code, start_call_num, end_call_num, start_index)
                output['docs'] += filter_by_library_collection(start_call_num, end_call_num, temp, library_code, collection_code)['docs']
            end
            start_index += LIMIT
            break if start_index > total_records || (limit && output['docs'].count >= limit)
        end
        output
    end

    def add_item_data(records)
        records['docs'].each do |record|
            record['items'] = @item_api.everything_for(record['id_inst'])
        end
        records
    end

    def filter_by_library_collection(start_num, end_num, records, library_code, collection_code)
        unless records['docs'].first['items']
            records = add_item_data(records)
        end
        records['docs'].each do |doc|
            if doc['items']
                doc['items'] = doc['items'].select do |i|
                    @item_api.part_of_library_collection?(i, library_code, collection_code)
                end
            else
                doc['items'] = []
            end
        end
        records['docs'].delete_if do |doc|
            doc['items'].empty? || doc_call_numbers(doc).none?{|c| call_number_in_range?(c, start_num, end_num)}
        end
        records
    end

    def call_number_in_range?(call_number, start_num, end_num)
        normed_range = (normalize_call_num(start_num)..normalize_call_num(end_num))
        normed_range.cover?(normalize_call_num(call_number))
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

    def doc_call_numbers(doc)
        doc['items'].map{|i| i['details'].map{|d| d['call_number']}}.flatten
    end

    def normalize_call_num(call_num)
        `perl #{Rails.root.join('lib', 'lc_norm.pm')} "#{call_num}"`
    end

    def has_call_number?(call_num)
        !self.class.get('/item', { :query => { :filter => "call_num:#{call_num}" }})['docs'].empty?
    end

    def call_num_to_sort_num(call_num)
        self.class.get('/item', { :query => { :filter => "call_num:#{call_num}" }})['docs'].first['loc_call_num_sort_order'].first
    end
end
