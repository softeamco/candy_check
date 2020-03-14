module CandyCheck
  module AppStore
    module Unified
      # Describes a receipt for an in-app purchase.
      # It's part of ios 7 style unified receip format
      class InAppReceipt
        include Utils::AttributeReader
        # @return [Hash] the raw attributes returned from the server
        attr_reader :attributes

        # Initializes a new instance which bases on a JSON result
        # from Apple's verification server
        # @param attributes [Hash]
        def initialize(attributes)
          @attributes = attributes
        end

        # The number of items purchased
        # @return [Integer, nil]
        def quantity
          read_integer('quantity')
        end

        # The product identifier of the item that was purchased
        # @return [String, nil]
        def product_id
          read('product_id')
        end

        # The transaction identifier of the item that was purchased
        # @return [String, nil]
        def transaction_id
          read('transaction_id')
        end

        # For a transaction that restores a previous transaction,
        # the transaction identifier of the original transaction.
        # Otherwise, identical to the transaction identifier
        # @return [String, nil]
        def original_transaction_id
          read('original_transaction_id')
        end

        # A string that the App Store uses to uniquely identify the
        # promotional offer of a product
        # @return [String, nil]
        def promotional_offer_id
          read('promotional_offer_id')
        end

        def subscription_group_identifier
          read('subscription_group_identifier')
        end

        # The date and time that the item was purchased
        # @return [DateTime, nil]
        def purchase_date
          read_datetime_from_string('purchase_date')
        end

        # For a transaction that restores a previous transaction,
        # the date of the original transaction
        # @return [DateTime, nil]
        def original_purchase_date
          read_datetime_from_string('original_purchase_date')
        end

        # The expiration date for the subscription.
        # Present only for auto-renewable subscription receipts
        # @return [DateTime, nil]
        def expires_date
          read_datetime_from_string('expires_date')
        end

        # The grace date for the subscription.
        # Present only for auto-renewable subscription receipts
        # @return [DateTime, nil]
        def grace_period_expires_date
          read_datetime_from_string('grace_period_expires_date')
        end

        # For an expired subscription, the reason for the subscription
        # expiration
        # @return [Integer, nil]
        def expiration_intent
          read_integer('expiration_intent')
        end

        EXPIRATION_INTENTS = {
          1 => 'user_canceled',
          2 => 'billing_issue',
          3 => 'declined_price_increase',
          4 => 'unavailable_product',
          5 => 'unknown_error'
        }.freeze

        # For an expired subscription, the reason for the subscription
        # expiration
        # @return [String, nil]
        def expiration_intent_string
          EXPIRATION_INTENTS[expiration_intent]
        end

        # For an expired subscription, whether or not Apple is still
        # attempting to automatically renew the subscription
        # @return [Integer, nil]
        #   0 - App Store has stopped attempting to renew the subscription
        #   1 - App Store is still attempting to renew the subscription
        def is_in_billing_retry_period # rubocop:disable PredicateName
          read_integer('is_in_billing_retry_period')
        end

        # For an expired subscription, whether or not Apple is still
        # attempting to automatically renew the subscription
        # @return [Boolean]
        def in_billing_retry_period?
          is_in_billing_retry_period == 1
        end

        # For a subscription, whether or not it is in the free trial period
        # @return [Boolean, nil]
        def is_trial_period # rubocop:disable PredicateName
          read_bool('is_trial_period')
        end

        # For a subscription, whether or not it is upgrared
        # @return [Boolean, nil]
        def is_upgraded # rubocop:disable PredicateName
          read_bool('is_upgraded')
        end

        def upgraded?
          !is_upgraded.nil? && is_upgraded
        end

        # For a subscription, whether or not it is in the intro offer period
        # @return [Boolean, nil]
        def is_intro_period # rubocop:disable PredicateName
          read_bool('is_in_intro_offer_period')
        end

        # For a subscription, whether or not it is in the promotional offer
        # @return [Boolean]
        def promo_offer?
          promotional_offer_id.present?
        end

        # For a subscription, whether or not it is in the free trial period
        # @return [Boolean]
        def trial_period?
          !is_trial_period.nil? && is_trial_period
        end

        # For a subscription, whether or not it is in the intro offer period
        # @return [Boolean]
        def intro_period?
          !is_intro_period.nil? && is_intro_period
        end

        # Check if subscription was canceled by Apple customer support
        # It makes sense only for subscriptions.
        # @return [Boolean]
        def cancelled?
          !cancellation_date.nil? && cancellation_reason.present?
        end

        def upgrade_with_full_refund?
          return false unless cancelled? && upgraded?
          
          days_used = (cancellation_date.to_date - purchase_date.to_date).to_i

          days_used < 1
        end

        # Check if the {#expires_at} is passed.
        # It makes sense only for subscriptions.
        # @return [Boolean]
        def expired?
          expires_date.to_time <= Time.now.utc
        end

        # For a transaction that was canceled by Apple customer support,
        # the time and date of the cancellation
        # @return [DateTime, nil]
        def cancellation_date
          read_datetime_from_string('cancellation_date')
        end

        # For a transaction that was cancelled, the reason for cancellation
        # @return [Integer, nil]
        def cancellation_reason
          read_integer('cancellation_reason')
        end

        CANCELATION_REASONS = {
          1 => 'app_issue',
          0 => 'another_reason'
        }.freeze

        # For a transaction that was cancelled, the reason for cancellation
        # @return [String, nil]
        def cancellation_reason_string
          CANCELATION_REASONS[cancellation_reason]
        end

        # A string that the App Store uses to uniquely identify the
        # application that created the transaction
        # return [String, nil]
        def app_item_id
          read('app_item_id')
        end

        # An arbitrary number that uniquely identifies a revision
        # of your application
        # return [String, nil]
        def version_external_identifier
          read('version_external_identifier')
        end

        # The primary key for identifying subscription purchases
        # @return [String]
        def web_order_line_item_id
          read('web_order_line_item_id')
        end

        # The current renewal status for the auto-renewable subscription
        # @return [Integer, nil]
        #   0 - Customer has turned off automatic renewal for their subscription
        #   1 - Subscription will renew at the end of the current subscription
        #       period
        def auto_renew_status
          read_integer('auto_renew_status')
        end

        # The current renewal status for the auto-renewable subscription
        # @return [Boolean]
        def will_renew?
          auto_renew_status == 1
        end

        # The current renewal preference for the auto-renewable subscription
        # @return [String, nil]
        def auto_renew_product_id
          read('auto_renew_product_id')
        end

        # The current price consent status for a subscription price increase.
        # @return [Integer, nil]
        #   0 - Customer has not taken action regarding the increased price.
        #       Subscription expires if the customer takes no action before
        #       the renewal date.
        #   1 - Customer has agreed to the price increase.
        #       Subscription will renew at the higher price.
        def price_consent_status
          read_integer('price_consent_status')
        end

        PRICE_CONSENTS_STATUS = {
          1 => 'ignore_price_increase',
          0 => 'agreed_price_increase'
        }.freeze

        def price_consent_status_string
          PRICE_CONSENTS_STATUS[price_consent_status]
        end

        # The current price consent status for a subscription price increase.
        # @return [Boolean]
        def price_consented?
          price_consent_status == 1
        end
      end
    end
  end
end
