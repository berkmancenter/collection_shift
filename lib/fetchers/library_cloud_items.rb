class LibraryCloudItems
    include HTTParty
    base_uri 'librarylab.law.harvard.edu/bib_inv/api'
    format :json

    def everything_for(hollis_id)
        self.class.get("/#{hollis_id}")['items']
    end

    def items_by_library_code(library_code, hollis_id)
        items = everything_for(hollis_id).find{|item| item['location'] == library_code}
        items ? items['details'] : []
    end

    def items_by_library_code_and_collection_code(library_code, collection_code, hollis_id)
        items_by_library_code(library_code, hollis_id).select do |item|
            item['collection'] == collection_code
        end
    end

    def count(library_code, collection_code, hollis_id)
        items = items_by_library_code_and_collection_code(library_code, collection_code, hollis_id)
        items ? items.count : nil
    end
end
