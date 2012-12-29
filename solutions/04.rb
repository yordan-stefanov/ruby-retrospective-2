class Validations
  REG_EXP_HOSTNAME = /(([[:alnum:]][[:alnum:]\-]{,60})?[[:alnum:]]\.)+(?<tld>[[:alpha:]]{2,3}(\.[[:alpha:]]{2})?)/i
  REG_EXP_EMAIL = /(?<username>[[:alnum:]][[:word:]\.\+\-]{,200})@(?<hostname>#{REG_EXP_HOSTNAME})/i
  REG_EXP_PHONE = /(?:(?<local_prefix>0)|(?<inter_prefix>(00|\+)[1-9]\d{,2}))(([ \-()]{,2}\d){6,11})/
  REG_EXP_IP_ADDRESS = /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/
  REG_EXP_INTEGER = /-?\d+/
  REG_EXP_NUMBER = /#{REG_EXP_INTEGER}(\.\d+)?/
  REG_EXP_DATE = /(\d{4})-(\d{2})-(\d{2})/
  REG_EXP_TIME = /(\d{2}):(\d{2}):(\d{2})/
  REG_EXP_DATE_TIME = /(?<date>#{REG_EXP_DATE})[ T](?<time>#{REG_EXP_TIME})/

  def self.hostname? value
    !/^#{REG_EXP_HOSTNAME}$/.match(value).nil?
  end

  def self.email? value
    !/^#{REG_EXP_EMAIL}$/.match(value).nil?
  end

  def self.integer? value
    !/^#{REG_EXP_INTEGER}$/.match(value).nil?
  end

  def self.number? value
    !/^#{REG_EXP_NUMBER}$/.match(value).nil?
  end

  def self.phone? value
    !/^#{REG_EXP_PHONE}$/.match(value).nil?
  end

  def self.ip_address? value
    return false if /^#{REG_EXP_IP_ADDRESS}$/.match(value).nil?
    [$1, $2, $3, $4].each do |ip_octet|
      return false if ip_octet.to_i > 255
    end
    true
  end

  def self.date? value
    return false if /^#{REG_EXP_DATE}$/.match(value).nil?
    return true if $2.to_i.between?( 1, 12 ) and $3.to_i.between?( 1, 31 )
    false
  end

  def self.time? value
    return false if /^#{REG_EXP_TIME}$/.match(value).nil?
    return true if $1.to_i.between?( 0, 23 ) and $2.to_i.between?( 0, 59 ) and $3.to_i.between?( 0, 59 )
    false
  end

  def self.date_time? value
    p value
    match_data = REG_EXP_DATE_TIME.match( value )
    return false if not match_data
    return ( self.date?( match_data['date'] ) and self.time?( match_data['time'] ) )
  end
end


class PrivacyFilter
  attr_reader :private_data
  attr_accessor :preserve_phone_country_code, :preserve_email_hostname, :partially_preserve_email_username

  def initialize text
    @private_data = text
    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @partially_preserve_email_username = false
  end

  def filter_email username, hostname
    return username.gsub( /(.{3}).+/, '\1[FILTERED]@' + hostname ) if partially_preserve_email_username
    return '[FILTERED]@' + hostname if preserve_email_hostname
    '[EMAIL]'
  end

  def filter_next_email text
    text.gsub!( Validations::REG_EXP_EMAIL ) { |_| Validations.email?( _ ) ? filter_email( $1, $2 ) : _ }
  end

  def filter_phone inter_prefix
    if preserve_phone_country_code and inter_prefix
      return inter_prefix + ' [FILTERED]'
    end
    '[PHONE]'
  end

  def filter_next_phone text
    text.gsub!( Validations::REG_EXP_PHONE ) { |_| Validations.phone?( _ ) ? filter_phone( $2 ) : _ }
  end

  def filtered
    private_data_copy = String.new @private_data
    while filter_next_email private_data_copy
    end
    while filter_next_phone private_data_copy
    end
    private_data_copy
  end
end