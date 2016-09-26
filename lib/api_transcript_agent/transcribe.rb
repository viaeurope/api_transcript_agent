module ApiTranscriptAgent
  module Transcribe
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def transcribe(*actions)
        before_action only: actions do
          env['api_transcript.transcribe_action'] = true
        end
      end
    end
  end
end
