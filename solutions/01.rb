class Integer
    def prime_divisors
        is_prime = ->( number ) do
            2.upto( number - 1 ).all? { |divisor| number % divisor != 0 }
        end
        number = abs
        2.upto( number - 1 ).each_with_object [] do | divisor, prime_divisors |
            prime_divisors << divisor if number % divisor == 0 and divisor.prime?
        end
        # or using one line solution: abs.prime_division.map( &:first ).select { |number| number != abs }
        # but it requires "Prime"
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