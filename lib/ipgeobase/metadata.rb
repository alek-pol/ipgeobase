# frozen_string_literal: true

require 'happymapper'

module Ipgeobase
  class Metadata
    include HappyMapper

    tag 'query'

    element :city, String
    element :country, String
    element :countryCode, String
    element :lat, Float
    element :lon, Float
  end
end
