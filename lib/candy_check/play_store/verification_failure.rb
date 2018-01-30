module CandyCheck
  module PlayStore
    # Represents a failing call against the Google API server
    class VerificationFailure
      # @return [Google::Apis::Error] the raw attributes returned
      # from the server
      attr_reader :err

      # Initializes a new instance which bases on a api client exception
      # @param err [Google::Apis::Error]
      def initialize(err)
        @err = err
      end

      # The code of the failure
      # @return [Fixnum]
      def code
        (err && err.status_code) || -1
      end

      # The message of the failure
      # @return [String]
      def message
        (err && err.message) || 'Unknown error'
      end
    end
  end
end
