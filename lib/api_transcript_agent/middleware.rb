require 'net/http'

module ApiTranscriptAgent
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      # No need to #dup env here, because we do not mutate it.
      @status, @headers, @response = @app.call(env)

      if env['api_transcript.transcribe_action'] == true
        if Rails.env.test?
            transmit(env)
        else
          Thread.new { transmit(env) }
        end
      end

      [@status, @headers, @response]
    end

  private

    API_REFEREE_RECEIVE_URL = 'http://api-transcript.herokuapp.com/api/v1/transactions'

    def delta_since(start_time)
      return Time.now - start_time
    end

    def transmit(env)
      begin
        send_data(env)
      rescue => e
        Rails.logger.debug "Could not send transaction data: #{e}"
      end
    end

    def send_data(env)
      start_time = Time.now

      uri = URI(API_REFEREE_RECEIVE_URL)

      Rails.logger.debug "Sending transaction data to #{uri}…"

      request_headers = env.select {|k,v| k.start_with? 'HTTP_'}
        .collect {|key, val| [key.sub(/^HTTP_/, ''), val]}

      request_headers << ['Content-Type', env['CONTENT_TYPE']]
      request_headers << ['Content-Length', env['CONTENT_LENGTH']]

      request_info = {
        body: env['RAW_POST_DATA'],
        headers: request_headers.sort,
        method: env['REQUEST_METHOD'],
        host: env['HTTP_HOST'],
        path: env['ORIGINAL_FULLPATH'],
        protocol: env['SERVER_PROTOCOL'],
        rack_id: env['action_dispatch.request_id'],
        remote_ip: env['action_dispatch.remote_ip'].calculate_ip,
        handled_by: env['action_dispatch.request.path_parameters']
      }

      response_body = ""

      if @response.respond_to? :join
        response_body = @response.join('')
      end

      response_info = {
        body: response_body,
        headers: @headers,
        status: @status
      }

      collection_time = delta_since(start_time)

      post_request = Net::HTTP::Post.new(uri, {'Content-Type' =>'application/json'})
      post_request.body = { transaction: {
        request: request_info,
        response: response_info,
        collection_time: collection_time
      }}.to_json

      result = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(post_request) }

      transmission_time = delta_since(start_time)

      Rails.logger.debug "Sent transaction data (#{post_request.body.size} bytes) for request #{env['action_dispatch.request_id']} to api referee with status #{result.code}. Collection time: #{collection_time}, sending time: #{transmission_time}"
      Rails.logger.debug "-------------------\n\n"
    end
  end
end
