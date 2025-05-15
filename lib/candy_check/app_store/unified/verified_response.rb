module CandyCheck
  module AppStore
    module Unified
      # Wraps response from apple verification server
      class VerifiedResponse
        # @return [Unified::AppReceipt]
        attr_reader :receipt

        # @return [String] the base64 string with receipt
        attr_reader :latest_receipt

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

        attr_reader :response

        # @param response [Hash] parsed response from apple
        #   verification server
        def initialize(response)
          @response = response
          @receipt = AppReceipt.new(response['receipt'])
          @latest_receipt = response['latest_receipt']
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
            receipts.sort_by! do |receipt|
              if receipt.attributes['storefront'] # V2
                receipt.purchase_date || receipt.expires_date
              else
                # the cause of this sort is unknown, let's keep it for now
                receipt.expires_date || receipt.purchase_date
              end
            end
            fix_upgraded_receipts_order!(receipts) if receipts.last.upgraded?

            { id => receipts }
          end.reduce({}, :merge)
        end

        def fix_upgraded_receipts_order!(receipts)
          return if receipts.count < 2

          last_receipt = receipts.last
          should_be_last_receipt = receipts[receipts.count - 2]

          if (should_be_last_receipt.purchase_date - last_receipt.purchase_date).abs < 86_400
            receipts.delete(should_be_last_receipt)
            receipts << should_be_last_receipt
          end
        end

        def same_group?(r1, r2)
          # group by subscription_group_identifier if autorenewable
          if r1&.subscription_group_identifier.present? && r2&.subscription_group_identifier.present?
            return r1.subscription_group_identifier == r2.subscription_group_identifier
          end

          # group by product id or OTI if autorenewable but for some reason subscription_group_identifier is not available
          if r1.web_order_line_item_id.present? && r2.web_order_line_item_id.present?
            return (r1.product_id == r2.product_id || r1.original_transaction_id == r2.original_transaction_id)
          end

          r1.original_transaction_id == r2.original_transaction_id
        end

        def raw_grouped_receipts
          groups = {}
          total_receipts.each do |candy_receipt|
            added = false
            groups.each do |_oti, receipts|
              next unless same_group?(receipts.first, candy_receipt)

              receipts << candy_receipt
              added = true
              break
            end
            groups[candy_receipt.original_transaction_id] = [candy_receipt] unless added
          end

          groups
        end

        def total_receipts
          return @total_receipts if @total_receipts

          @total_receipts = []
          @total_receipts += latest_receipt_info
          not_added_in_app_receipts = in_app.select { |r1| @total_receipts.find { |r2| same_receipts?(r1, r2) }.nil? }
          @total_receipts += not_added_in_app_receipts if not_added_in_app_receipts.present?

          @total_receipts
        end

        def same_receipts?(r1, r2)
          if r1.web_order_line_item_id.present? && r2.web_order_line_item_id.present?
            return r1.web_order_line_item_id == r2.web_order_line_item_id
          end

          # if receipts are non-renewing, then compare by transaction id
          r1.transaction_id == r2.transaction_id
        end

        def pending_renewal_transaction(oti, product_id)
          return unless subscription?

          pending_renewal_info.find do |t|
            t.original_transaction_id == oti || t.product_id == product_id
          end
        end

        # @return [Unified::InAppReceipt] by original_transaction_id
        def latest_subscription_info(original_transaction_id)
          subscriptions.find { |s| s.original_transaction_id == original_transaction_id }
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
