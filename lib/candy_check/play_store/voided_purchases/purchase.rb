module CandyCheck
  module PlayStore
    # Describes a successfully validated subscription
    class VoidedPurchases::Purchase
      include Utils::AttributeReader

      # @return [Google::Apis::AndroidpublisherV3::VoidedPurchase] the raw subscription purchase from google-api-client
      attr_reader :purchase

      # The reason why the purchase was voided (voidedReason)
      VOIDED_REASONS = %w[other remorse not_received defective accidental_purchase fraud friendly_fraud chargeback].freeze

      # The initiator of voided purchase (voidedSource)
      VOIDED_SOURCES = %w[user developer google].freeze

      # Initializes a new instance which bases on a JSON result
      # from Google's servers
      # @param subscription_purchase [Google::Apis::AndroidpublisherV3::SubscriptionPurchase]
      def initialize(purchase)
        @purchase = purchase
      end

      def inspect
        "<#{self.class}: #{vars}>"
      end

      def vars
        { kind: kind,
          voided_at: voided_at,
          purchased_at: purchased_at,
          order_id: order_id,
          purchase_token: purchase_token,
          voided_reason: voided_reason,
          voided_source: voided_source,
          voided_reason_name: voided_reason_name,
          voided_source_name: voided_source_name }.map do |key, value|
            "#{key}=#{value.to_json}"
          end.join(', ')
      end

      VOIDED_SOURCES.each_with_index do |source, index|
        define_method(:"voided_by_#{source}?") do
          voided_source == index
        end
      end

      # Get the kind of subscription as stored in the android publisher service
      # @return [String]
      def kind
        @purchase.kind
      end

      # The time at which the purchase was canceled/refunded/charged-back timestamp
      # @return [Integer]
      def voided_time_millis
        @purchase.voided_time_millis
      end

      # The time at which the purchase was made timestamp
      # @return [Integer]
      def purchase_time_millis
        @purchase.purchase_time_millis
      end

      # The time at which the purchase was canceled/refunded/charged-back UTC
      # @return [DateTime]
      def voided_at
        Time.at(voided_time_millis / 1000).utc.to_datetime
      end

      # Get purchase time in UTC
      # @return [DateTime]
      def purchased_at
        Time.at(purchase_time_millis / 1000).utc.to_datetime
      end

      # Get order id
      # @return [Integer]
      def order_id
        @purchase.order_id
      end

      # Get purchase token
      # @return [String]
      def purchase_token
        @purchase.purchase_token
      end

      def voided_reason
        @purchase.voided_reason
      end

      def voided_source
        @purchase.voided_source
      end

      def voided_reason_name
        VOIDED_REASONS[voided_reason]
      end

      def voided_source_name
        VOIDED_SOURCES[voided_source]
      end
    end
  end
end
