require 'digest/sha1'

module UnforgivenPL

 module Mathpcha
 
  VERSION = "0.1.20110202"
  AUTHOR  = "Unforgiven.pl"
  HOSTNAME= `hostname`.strip

  class I18nHelper
   def [](key)
    t(key)
   end
   
   def t(key, params={})
    I18n.t(key, params.merge(:scope=>"unforgivenpl.mathpcha"))
   end
   
  end
  
  class Captcha
   attr_reader :range
   attr_reader :question
   attr_reader :adding
  
   def initialize(num_range=20)
    @i18n = I18nHelper.new
    self.range=num_range
   end

   def range=(num)
    @range = num.to_i unless num.to_i <= 0
    flush
   end

   def Captcha.verification_for(text)
    Digest::SHA1.hexdigest([MathCaptcha::VERSION, text.to_s, HOSTNAME].join(":"))
   end

   def flush
    @adding = rand<0.5
    digits = [rand(@range)+1, rand(@range)+1]
    digits.reverse! if !@adding && digits[0]<digits[1]
    @digits = digits.collect {|n| rand<0.5 ? n.to_s : @i18n["numbers"][n]}
    @question = @i18n.t(@adding ? "plus" : "minus", :num1=>@digits[0], :num2=>@digits[1])
    @result = @adding ? digits[0]+digits[1] : digits[0]-digits[1]
    @verify = Captcha.verification_for(@result)
   end

   def first_digit
    @digits[0]
   end
   
   def last_digit
    @digits[1]
   end

   def html(field_prefix="unf_mathc_")
    result_field_name = field_prefix+"result"
    verify_field_name = field_prefix+"verify"
    remark = @i18n["remark"]
    "<p><label for=\"#{result_field_name}\">#{@question}</label> <input type=\"text\" name=\"#{result_field_name}\" id=\"#{result_field_name}\"/> <label for=\"#{result_field_name}\">#{remark}</label><input type=\"hidden\" name=\"#{verify_field_name}\" id=\"#{verify_field_name}\" value=\"#{@verify}\"/></p>"
   end

   def Captcha.valid?(params_or_result, verification=nil, field_prefix="unf_mathc_")
    result, verify = verification.nil? ? [params_or_result[field_prefix+"result"], params_or_result[field_prefix+"verify"]] : [params_or_result, verification]
    verify == Captcha.verification_for(result)
   end

  end
 
 end

end


