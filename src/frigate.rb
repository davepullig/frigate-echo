require 'net/http'
require 'json'
require 'uri'

class FrigateExport
	def initialize(url, api_key)
		@url = url
		@api_key = api_key
	end

	def list
		res = request("/api/exports", :get)

		exports = JSON.parse(res.body)
		exports.sort_by { |e| e['date'] }
	end

	def delete(id)
		request("/api/export/#{id}", :delete)
	end

	def create(camera, start_time, end_time)
		body = {
			playback: 'realtime',
			source: 'recordings'
		}

		res = request("/api/export/#{camera}/start/#{start_time}/end/#{end_time}", :post, body)

		unless [Net::HTTPSuccess, Net::HTTPCreated].any? { |i| res.kind_of?(i) }
			raise "Error: #{res.code} #{res.message}\nBody: #{res.body}"
		end

		JSON.parse(res.body)
	end

	private

	def request(uri, method, body = nil)
		url = URI("#{@url}#{uri}")
		
		req = case method
		when :get
			Net::HTTP::Get.new(url)
		when :delete
			Net::HTTP::Delete.new(url)
		when :post
			Net::HTTP::Post.new(url)
		else
			raise "\"#{method}\" is an unsupported method"
		end

		req['Authorization'] = "Bearer #{@api_key}" if @api_key

		if body
			req['Content-Type'] = 'application/json'
			req.body = JSON.dump(body)
		end

		res = Net::HTTP.start(url.hostname, url.port) { |http| http.request(req) }

		unless res.kind_of?(Net::HTTPSuccess)
			raise "Error: #{res.code} #{res.message}\nBody: #{res.body}"
		end

		res
	end
end
