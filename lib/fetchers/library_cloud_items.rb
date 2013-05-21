class LibraryCloudItems
    include HTTParty
    base_uri 'librarylab.law.harvard.edu/bib_inv/api'
    format :json

    def all_items(hollis_id)
        self.class.get("/#{hollis_id}")['items']
    end

    def items_by_library_code(library_code, hollis_id)
        all_items(hollis_id).find{|loc| loc['location'] == library_code}
    end

    def count(library_code, hollis_id)
        items = items_by_library_code(library_code, hollis_id)
        items ? items['location_count'] : nil
    end
end
