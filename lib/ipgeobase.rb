# frozen_string_literal: true

require_relative 'ipgeobase/error'
require_relative 'ipgeobase/metadata'
require_relative 'ipgeobase/version'

# Get metadata from ip-api.com
module Ipgeobase
  # Return metadata by ip-address
  # @param [String] address ip-address
  # @return [Ipgeobase::Error|Ipgeobase::Metadata]
  def self.lookup(address)
    resp = Net::HTTP.get_response(URI("http://ip-api.com/xml/#{address}"))
    return Metadata.parse(resp.body) if resp.code == '200'

    message = resp.message == '' ? resp.class.to_s.split('::').last : resp.message
    Error.new("code: #{resp.code}, message: #{message}")
  rescue StandardError => e
    Error.new(e)
  end
end
