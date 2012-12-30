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