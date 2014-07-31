# encoding: UTF-8

class LibraryCloud
    include HTTParty
    include LibraryCloudUtils
    base_uri 'librarycloud.harvard.edu/v1/api/item'
    format :json
    disable_rails_query_string_format
    MAX_RETURNED_RECORDS = 20000

    def initialize
        @item_api = LibraryCloudItems.new
    end

    def build_result(library_code, collection_code, start_call_num, end_call_num)
        result = Result.new(pages: [], serials: [], multi_volumes: [])

        records = records_in_range(library_code, collection_code, start_call_num, end_call_num)
        Rails.logger.warn('Got all records')

        result.total_records = records.count
        result.records_without_pages = 0

        records.each do |record|
            pages = pages_to_int(record['pages'])

            # TODO: Handle "Notated Music" format

            if record['format'] == 'Serial'
                count = @item_api.count(library_code, collection_code, record['id_inst'])
                result.serials << count if count
            elsif record['format'] == 'Book' && pages.nil?
                count = @item_api.count(library_code, collection_code, record['id_inst'])
                if count
                    result.multi_volumes << count
                else
                    Rails.logger.warn("Fetcher - Book without pages or items: #{record['id_inst']}")
                end
            elsif pages
                result.pages << pages
            else
                Rails.logger.warn("Fetcher - Something else: #{record['id_inst']}")
                result.records_without_pages += 1
            end
        end
        result
    end

    def total_records(library_code, start_call_num, end_call_num)
        filter = library_and_range_filter(library_code, start_call_num, end_call_num)
        record_count(filter)
    end

    def has_library_records?(library_code)
        record_count(library_filter(library_code)) >= 1
    end

    def records_in_range(library_code, collection_code, start_call_num, end_call_num)
        # First fetch all the records if there aren't too many, and then filter
        # them by collection based on what shows in each record's items

        total_records = total_records(library_code, start_call_num, end_call_num)

        if total_records > MAX_RETURNED_RECORDS
            raise ArgumentError('Selected range returns too many records')
        end

        filter = library_and_range_filter(library_code, start_call_num, end_call_num)
        records = all_records(filter)

        add_item_data!(records)
        filter_records_by_collection!(records, library_code, collection_code)
        filter_records_by_range!(records, start_call_num, end_call_num)

        records
    end

    def add_item_data!(records)
        hollis_ids = records.map{|d| d['id_inst']}
        items = @item_api.everything_for(hollis_ids)
        puts "Item count: #{items.count}"
        item_hash = {}
        items.each do |i|
            if item_hash[i['bib_doc_id']]
                item_hash[i['bib_doc_id']] << i
            else
                item_hash[i['bib_doc_id']] = [i]
            end
        end
        records.each do |record|
            record['items'] = item_hash[record['id_inst']]
            record['items'] = [] if record['items'].nil?
        end
    end

    def filter_records_by_collection!(records, library_code, collection_code)
        # Add item data if it doesn't already exist
        unless records.first['items']
            records = add_item_data!(records)
        end

        records.each do |record|
            record['items'].select! do |item|
                @item_api.part_of_library_collection?(item, library_code, collection_code)
            end
        end
        records.delete_if{ |record| record['items'].empty? }
    end

    def filter_records_by_range!(records, start_num, end_num)
        # Spinning up perl is really slow, so we've got to do everything at
        # once
        normed_range = normalized_range(start_num, end_num)

        # Create a hash of call nums pointing to record id_inst
        call_num_hash = records.map do |record|
            r_call_nums = record_call_numbers(record)
            r_call_nums.zip([record['id_inst']] * r_call_nums.count)
        end

        call_num_hash = call_num_hash.flatten(1).to_h
        call_nums = call_num_hash.keys

        # Normalize call nums
        normed_call_nums = normalize_call_num(call_nums)

        # For each normed call num in range, add record with id_inst
        record_ids_to_keep = []
        call_nums.each_with_index do |call_num, i|
            if normed_call_number_in_range?(normed_call_nums[i], normed_range)
                record_ids_to_keep << call_num_hash[call_num]
            end
        end

        records.keep_if do |record|
            record_ids_to_keep.include? record['id_inst']
        end
    end

    def normalized_range(start_num, end_num)
        normed_start_and_end = normalize_call_num([start_num, end_num])
        (normed_start_and_end.first..normed_start_and_end.last)
    end

    def normed_call_number_in_range?(normed_call_number, normed_range)
        normed_range.cover?(normed_call_number)
    end

    def pages_to_int(pages)
        return unless pages
        roman_numeral = /(\b|^)[ivxlcmIVXLCM]+\b/
        unwanted_chars = /\W[lvℓ]/
        number_in_brackets = /\[\d\]/
        all_words = /^[-_a-zA-Z ]+$/
        segments = pages.split(',')
        segments.delete_if do |segment|
            segment.match(all_words) ||
                segment.match(roman_numeral) ||
                segment.match(unwanted_chars) ||
                segment.match(number_in_brackets) ||
                segment.empty?
        end
        return if segments.empty?
        output = segments.first.split('-').last.strip.gsub(/(\[|\])/,'').to_i
        return if output == 0
        output
    end

    def record_call_numbers(record)
        record['items'].map{|i| i['z30_call_no'] ? i['z30_call_no'].gsub(/\$\$./,' ').strip : nil}.compact.uniq
    end

    def normalize_call_num(call_nums)
        if call_nums.is_a?(Array)
            call_nums_to_norm = call_nums.join(',')
        else
            call_nums_to_norm = call_nums
        end
        normed = ''
        Tempfile.create('call_nums') do |f|
            f.write(call_nums_to_norm)
            f.close
            normed = `cat #{f.path} | perl #{Rails.root.join('lib', 'lc_norm.pm')}`
        end
        return normed.split(',') if call_nums.is_a?(Array)
        normed
    end

    def has_call_number?(call_num)
        !self.class.get('/', { :query => { :filter => "call_num:#{call_num}" }})['docs'].empty?
    end

    def call_num_to_sort_num(call_num)
        all_records(call_num_filter(call_num), sort_order_sort).first['loc_call_num_sort_order'].first
    end

    def sort_order_sort
        'loc_call_num_sort_order asc'
    end

    def call_num_filter(call_num)
        "call_num:#{call_num}"
    end

    def library_filter(library_code)
        "holding_libs:#{library_code}"
    end

    def range_filter(start_call_num, end_call_num)
        num_a = call_num_to_sort_num(start_call_num)
        num_b = call_num_to_sort_num(end_call_num)
        start_number, end_number = [num_a, num_b].minmax
        "loc_call_num_sort_order:[#{start_number} TO #{end_number}]"
    end

    def library_and_range_filter(library_code, start_num, end_num)
        [library_filter(library_code), range_filter(start_num, end_num)]
    end

    alias_method :all_records, :all_docs
    alias_method :record_count, :doc_count
end
