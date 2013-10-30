module MathUtils
    def cm_to_ft(cm)
        cm_to_in(cm) / 12.0
    end

    def ft_to_cm(ft)
        in_to_cm(ft * 12.0)
    end

    def cm_to_in(cm)
        cm / 2.54
    end

    def in_to_cm(inches)
        inches * 2.54
    end

    def median(array)
        sorted = array.sort
        len = sorted.length
        (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    end
end
