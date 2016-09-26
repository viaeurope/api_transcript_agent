module ApiTranscriptAgent
  module Transcribe
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def transcribe(*actions)
        options = {}
        options[:only] = actions if actions.present?

        prepend_before_action(options) do
          request.env['api_transcript.transcribe_action'] = true
        end
      end
    end
  end
end
