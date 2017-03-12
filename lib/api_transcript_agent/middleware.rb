module ApiTranscriptAgent
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      triplet = @app.call(env)
      if env['api_transcript.transcribe_action'] == true
        ApiTranscriptAgent::Sender.instance.submit(env, *triplet)
      end
      triplet
    end

  end
end
