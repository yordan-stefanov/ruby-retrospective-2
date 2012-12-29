class Integer
    def prime_divisors
        return (-self).prime_divisors if self < 0
        return nil if [0,1].include? self
        def prime? n
            not (2...n).map {|x| n % x}.include? 0
        end
        (2...self).to_a.delete_if { |x| not prime? x or not self % x == 0 }
    end
end

class Range
    def fizzbuzz
        def map_f n
            if n % 3 == 0 and n % 5 == 0
                :fizzbuzz
            elsif n % 3 == 0
                :fizz
            elsif n % 5 == 0
                :buzz
            else
                n
            end
        end
        self.map { |x| map_f x }
    end
end

class Hash
    def group_values
        ans = {}
        def insert_key ans, k, v
            if ans[v] == nil
                ans[v] = [k]
            else
                ans[v] << k
            end
        end
        self.each { |k, v| insert_key ans, k, v }
        ans
    end
end

class Array
    def densities
        self.map { |x| self.count x }
    end
end