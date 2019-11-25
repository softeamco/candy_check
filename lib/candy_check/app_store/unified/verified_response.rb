module CandyCheck
  module AppStore
    module Unified
      # Wraps response from apple verification server
      class VerifiedResponse
        # @return [Unified::AppReceipt]
        attr_reader :receipt

        # @return [<Unified::InAppReceipt>] the collection containing all
        #   in-app purchase transactions. This excludes transactions for
        #   a consumable product that have been marked as finished by your app.
        #   Present only for auto-renewable subscription.
        attr_reader :latest_receipt_info

        # @return [<Unified::InAppReceipt>] the collection where each
        #   element contains the pending renewal information for each
        #   auto-renewable subscription.
        #   Present only for auto-renewable subscription.
        attr_reader :pending_renewal_info

        # @return [<Unified::InAppReceipt>] the collection containing all
        #   in-app purchase transactions. This excludes transactions for
        #   a consumable product that have been marked as finished by your app.
        #   Present only for auto-renewable, non-renewing, free subscriptions.
        #   and non-consumable products
        attr_reader :in_app

        # @return [String] Enviroment
        attr_reader :environment

        # @param response [Hash] parsed response from apple
        #   verification server
        def initialize(response)
          @receipt = AppReceipt.new(response['receipt'])
          @latest_receipt_info = fetch_latest_receipt_info(response)
          @pending_renewal_info = fetch_pending_renewal_info(response)
          @in_app = fetch_in_app_info(response)
          @environment = response['environment'].downcase
        end

        # Check if response includes subscription
        # @return [Boolean]
        def subscription?
          !latest_receipt_info.nil? && latest_receipt_info.size.positive?
        end

        # @return [<Unified::InAppReceipt>] the subscriptions latest
        #   transactions. Unique by original_transaction_id
        def subscriptions
          return [] unless subscription?

          latest_receipt_info.group_by(&:original_transaction_id)
                             .map do |_id, receipts|
            receipts.max_by(&:purchase_date)
          end
        end

        def subscription_receipts_by(original_transaction_id)
          grouped_receipts[original_transaction_id]
        end

        # group by subscription_group_identifier or by original_transaction_id or by product_id
        def grouped_receipts
          @grouped_receipts ||= raw_grouped_receipts.map do |id, receipts|
            { id => receipts.sort_by(&:purchase_date) }
          end.reduce({}, :merge)
        end
      
        def same_group?(r1, r2)
          return r1.subscription_group_identifier == r2.subscription_group_identifier if r1&.subscription_group_identifier.present?
      
          r1.original_transaction_id == r2.original_transaction_id || r1.product_id == r2.product_id
        end
      
        def raw_grouped_receipts
          groups = {}
          latest_receipt_info.each do |candy_receipt|
            added = false
            groups.each do |oti, receipts|
              if same_group?(receipts.first, candy_receipt)        
                receipts << candy_receipt
                added = true
                break
              end
            end
            groups[candy_receipt.original_transaction_id] = [candy_receipt] unless added
          end
      
          groups
        end

        def receipts_by(original_transaction_id)
          found_receipt = latest_receipts_by(original_transaction_id)
          found_receipt ||= in_app_receipts_by(original_transaction_id)

          found_receipt
        end

        def in_app_receipts_by(original_transaction_id)
          in_app.select do |receipt|
            receipt.original_transaction_id == original_transaction_id
          end
        end

        def latest_receipts_by(original_transaction_id)
          latest_receipt_info.select do |receipt|
            receipt.original_transaction_id == original_transaction_id
          end
        end

        # @return [Unified::InAppReceipt] by original_transaction_id
        def latest_subscription_info(original_transaction_id)
          subscriptions.find { |s| s.original_transaction_id == original_transaction_id }
        end

        # @return [Unified::InAppReceipt, nil] the pending renewal transaction
        #   for subscription identified by original_transaction_id
        #   Present only for auto-renewable subscription.
        def pending_renewal_transaction(original_transaction_id)
          return unless subscription?

          pending_renewal_info.find do |transaction|
            transaction.original_transaction_id == original_transaction_id
          end
        end

        def pending_renewal_transaction(oti, product_id)
          return unless subscription?

          pending_renewal_info.find do |t|
            t.original_transaction_id == oti || t.product_id == product_id
          end
        end

        private

        def fetch_in_app_info(response)
          in_app_array = response.dig('receipt', 'in_app')
          return [] if in_app_array.nil?

          in_app_array.map do |receipt|
            InAppReceipt.new(receipt)
          end
        end

        def fetch_latest_receipt_info(response)
          return [] unless response['latest_receipt_info']

          response['latest_receipt_info'].map do |receipt|
            InAppReceipt.new(receipt)
          end
        end

        def fetch_pending_renewal_info(response)
          return [] unless response['pending_renewal_info']

          response['pending_renewal_info'].map do |receipt|
            InAppReceipt.new(receipt)
          end
        end
      end
    end
  end
end
