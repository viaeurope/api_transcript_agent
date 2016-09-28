module ApiTranscriptAgent
  module Transcribe
    extend ActiveSupport::Concern

    included do
      def _api_transcript_set_additional_data
        additional_data = instance_exec(&options[:additional_data])
        Rails.logger.error("additional_data is not a hash") and return unless additional_data.is_a?(Hash)
        request.env['api_transcript.additional_data'] = additional_data
      end
    end

    module ClassMethods
      def transcribe(options = {})
        before_action_options = {only: options[:only]} if options[:only].present?

        prepend_before_action(before_action_options) do
          request.env['api_transcript.transcribe_action'] = true
          request.env['api_transcript.additional_data_proc'] = options[:additional_data]
        end
      end
    end
  end
end
