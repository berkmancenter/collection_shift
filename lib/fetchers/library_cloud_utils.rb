module LibraryCloudUtils
    def all_docs(filter, sort = nil)
        limit = 250
        debug = false
        max_returned_records = 20000
        start = 0
        items = []
        query = { filter: filter, start: start, limit: limit }
        query[:sort] = sort if sort
        #self.class.debug_output
        response = self.class.get("/", query: query)
        puts response.request.uri if debug
        total_items = response['num_found']
        items += response['docs']

        while start + limit < total_items && items.count <= max_returned_records
            start += limit
            query = { filter: filter, start: start, limit: limit }
            query[:sort] = sort if sort
            response = self.class.get("/", query: query)
            puts response.request.uri if debug
            items += response['docs']
        end
        items
    end

    def doc_count(filter)
        debug = false
        response = self.class.get("/", query: {
            filter: filter,
            start: 0,
            limit: 1
        })
        puts response.request.uri if debug
        response['num_found']
    end
end
