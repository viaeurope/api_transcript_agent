require 'net/http'

module ApiTranscriptAgent
  class Sender

    API_REFEREE_RECEIVE_URL =
      if Rails.env.development? || Rails.env.test?
        'http://api-transcript.dev/api/v1/transactions'
      else
        'http://api-transcript.herokuapp.com/api/v1/transactions'
      end

    attr_accessor :last_sent_transaction_data if Rails.env.test?

    def self.instance
      @instance ||= new
    end

    def delta_since(start_time)
      return Time.now - start_time
    end

    def send_data(env, response, headers, status)
      start_time = Time.now

      uri = URI(API_REFEREE_RECEIVE_URL)

      Rails.logger.debug "Sending transaction data to #{uri}…"

      request_headers = env.select {|k,v| k.start_with? 'HTTP_'}
        .transform_keys {|key| key.sub(/^HTTP_/, '').capitalize }

      request_headers['Content-Type'] = env['CONTENT_TYPE']
      request_headers['Content-Length'] = env['CONTENT_LENGTH']

      request_info = {
        body: env['RAW_POST_DATA'],
        headers: request_headers,
        method: env['REQUEST_METHOD'],
        host: env['HTTP_HOST'],
        path: env['ORIGINAL_FULLPATH'],
        protocol: env['SERVER_PROTOCOL'],
        rack_id: env['action_dispatch.request_id'],
        remote_ip: env['action_dispatch.remote_ip'].calculate_ip,
        handled_by: env['action_dispatch.request.path_parameters'],
      }

      response_body = ""

      if response.respond_to? :join
        response_body = response.join('')
      end

      response_info = {
        body: response_body,
        headers: headers,
        status: status
      }

      collection_time = delta_since(start_time)

      controller = env['action_controller.instance']
      additional_data = controller.instance_exec(&env['api_transcript.additional_data_proc'])

      @last_sent_transaction_data = {
        request: request_info,
        response: response_info,
        collection_time: collection_time,
        additional_data: additional_data
      }

      post_request = Net::HTTP::Post.new(uri, {'Content-Type' =>'application/json'})
      post_request.body = { transaction: @last_sent_transaction_data }.to_json

      result = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(post_request) }

      transmission_time = delta_since(start_time)

      Rails.logger.debug "Sent transaction data (#{post_request.body.size} bytes) for request #{env['action_dispatch.request_id']} to api referee with status #{result.code}. Collection time: #{collection_time}, sending time: #{transmission_time}"
      Rails.logger.debug "-------------------\n\n"

      return @last_sent_transaction_data
    end
  end
end
