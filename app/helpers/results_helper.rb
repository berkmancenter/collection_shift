module ResultsHelper
    def distribution(array, classes)
        output = {}
        classes.each_with_index do |c, i|
            output[c.to_s] = array.select{ |pg|
                pg <= c && (i == 0 || pg > classes[i-1])
            }.count
        end
        output[">#{classes.last}"] = array.select{|pg| pg > classes.last}.count
        output
    end

    def format_breakdown(result)
        {
            'Book' => result.pages.count,
            'Multi-volume' => result.multi_volumes.count,
            'Serial' => result.serials.count,
            'Unknown' => result.total_records - result.pages.count - result.multi_volumes.count - result.serials.count
        }
    end
end
