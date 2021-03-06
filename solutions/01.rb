class Integer
  def prime_divisors
    is_prime = ->( number ) do
      2.upto( number - 1 ).all? { |divisor| number % divisor != 0 }
    end
    number = abs
    2.upto( number - 1 ).each_with_object [] do | divisor, divisors |
      divisors << divisor if number % divisor == 0 and is_prime.call( divisor )
    end
    # or using one line solution:
    # abs.prime_division.map( &:first ).select { |number| number != abs }
    # but it requires "Prime"
  end
end

class Range
  def fizzbuzz
    map &->( element ) do
      return :fizzbuzz if element % 15 == 0
      return :fizz if element % 3 == 0
      return :buzz if element % 5 == 0
      element
    end
  end
end

class Hash
  def group_values
    each_with_object( {} ) do | (key, value), new_hash |
      new_hash[value] ||= []
      new_hash[value] << key
    end
  end
end

class Array
  def densities
    map { |element| count element }
  end
end