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
          Thread.new { ransmit(env) }
        end
      end

      [@status, @headers, @response]
    end

  private

    def transmit(env)
      begin
        ApiTranscriptAgent::Sender.instance.send_data(env)
      rescue => e
        Rails.logger.debug "Could not send transaction data: #{e}"
      end
    end

  end
end
