namespace :collshift do
    desc 'Pull call numbers from range'
    task :call_nums, [:start_num, :end_num] => [:environment] do |task, args|
        l = LibraryCloud.new
        library_code = args[:library_code] || 'MUS'
        collection_code = args[:library_code] || 'GEN'
        start_num = args[:start_num] || 'ML410.M377 A88 2002'
        end_num = args[:end_num] || 'ML410.M595 D57 2013'
        records = l.records_in_range(library_code, start_num, end_num, nil)
        filtered_records = l.filter_by_library_collection(start_num, end_num, records, 'MUS', 'GEN')
        puts filtered_records['docs'].map{|doc| l.doc_call_numbers(doc)}.flatten.join("\n")
    end

    desc 'Pull records and item info'
    task :pull_records_and_items, [:library_code, :collection_code, :start_num, :end_num] => [:environment] do |task, args|
        require 'pp'
        l = LibraryCloud.new
        library_code = args[:library_code] || 'MUS'
        collection_code = args[:library_code] || 'GEN'
        start_num = args[:start_num] || 'ML410.M377 A88 2002'
        end_num = args[:end_num] || 'ML410.M595 D57 2013'
        records = l.records_in_range(library_code, start_num, end_num, nil)
        filtered_records = l.filter_by_library_collection(start_num, end_num, records, 'MUS', 'GEN')
        pp filtered_records
    end

    desc 'Get number of pages for range'
    task :pages_in_range, [:library_code, :collection_code, :start_num, :end_num] => [:environment] do |task, args|
        require 'pp'
        l = LibraryCloud.new
        library_code = args[:library_code] || 'MUS'
        collection_code = args[:library_code] || 'GEN'
        start_num = args[:start_num] || 'ML410.M377 A88 2002'
        start_num = args[:start_num] || 'ML410.B244 A5 2009'
        end_num = args[:end_num] || 'ML410.M595 D57 2013'
        end_num = args[:end_num] || 'ML410.B4968 A4 2002'
        result = l.pages_in_range(library_code, collection_code, start_num, end_num)
        pp result
    end
end
