require 'net/http'
require 'json'
require 'uri'

class HomeAssistant
	def initialize(url, token)
		@url = url
		@token = token
	end

	def people_home
		fetch_people.select  { |p| p['state'] == 'home' }
		            .collect { |p| p['attributes']['friendly_name'] }
	end

	private

	def fetch_people
	  uri = URI("#{@url}/api/states")
	  req = Net::HTTP::Get.new(uri)
	  req['Authorization'] = "Bearer #{@token}"
	  req['Content-Type'] = 'application/json'

	  res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

	  unless res.is_a?(Net::HTTPSuccess)
	    raise "Error: #{res.class} #{res.code} #{res.message} #{res.body}"
	  end

	  states = JSON.parse(res.body)
		states.select { |entity| entity['entity_id'].start_with?('person.') }
	end
end
