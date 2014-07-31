class LibraryCloudItems
    include HTTParty
    include LibraryCloudUtils
    base_uri 'hlslwebtest.law.harvard.edu/v2/api/barcode'
    format :json
    MAX_ITEMS_PER_QUERY = 100

    def everything_for(hollis_ids)
        items = []
        if hollis_ids.is_a?(Array) && hollis_ids.count > MAX_ITEMS_PER_QUERY
            hollis_ids.each_slice(MAX_ITEMS_PER_QUERY) do |ids|
                filter = hollis_id_filter(ids)
                items += all_items(filter)
            end
        else
            filter = hollis_id_filter(hollis_ids)
            items += all_items(filter)
        end
        items
    end

    def items_by_library_code(library_code, hollis_id)
        filter = library_hollis_id_filter(library_code, hollis_id)
        all_items(filter)
    end

    def items_by_library_code_and_collection_code(library_code, collection_code, hollis_id)
        filter = library_collection_hollis_id_filter(library_code, collection_code, hollis_id)
        all_items(filter)
    end

    def count(library_code, collection_code, hollis_id)
        item_count(library_collection_hollis_id_filter(library_code, collection_code, hollis_id))
    end

    def part_of_library_collection?(item, library_code, collection_code)
        item['z30_sub_library'] == library_code && item['z30_collection'] == collection_code
    end

    # Generate different filters
    def hollis_id_filter(hollis_ids)
        if hollis_ids.is_a? Array
            filter = "bib_doc_id:(#{hollis_ids.join(' OR ')})"
        else
            filter = "bib_doc_id:#{hollis_ids}"
        end
        filter
    end

    def library_filter(library_code)
        "z30_sub_library:#{library_code}"
    end

    def collection_filter(collection_code)
        "z30_collection:#{collection_code}"
    end

    def library_collection_filter(library_code, collection_code)
        "#{library_filter(library_code)} AND #{collection_filter(collection_code)}"
    end

    def library_collection_hollis_id_filter(library_code, collection_code, hollis_id)
        "#{library_collection_filter(library_code, collection_code)} AND #{hollis_id_filter(hollis_id)}"
    end

    def library_hollis_id_filter(library_code, hollis_id)
        "#{library_filter(library_code)} AND #{hollis_id_filter(hollis_id)}"
    end

    alias_method :all_items, :all_docs
    alias_method :item_count, :doc_count
end
