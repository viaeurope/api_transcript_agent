module ApiTranscriptAgent
  class Railtie < Rails::Railtie
    initializer "api_transcript_agent.configure_rails_initialization" do |app|
      app.middleware.insert_after Rails::Rack::Logger, ApiTranscriptAgent::Middleware
    end

    initializer "api_transcript_agent.setup_action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        include ApiTranscriptAgent::Transcribe
      end
    end

  end
end
