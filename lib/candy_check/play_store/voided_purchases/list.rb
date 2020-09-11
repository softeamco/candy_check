module CandyCheck
  module PlayStore
    class VoidedPurchases::List
      # @return [String] the package_name which will be queried
      attr_reader :package_name

      attr_reader :start_time
      attr_reader :end_time
      attr_reader :max_results
      attr_reader :start_index
      attr_reader :token
      attr_reader :fields
      attr_reader :quota_user
      attr_reader :options

      TYPES_MAP = {
        subscription: 1,
        product: 0
      }

      # Initializes a new call to the API
      # @param package_name [String]
      # @param sku [String]
      def initialize(package_name:,
                     authorization:,
                     start_time:,
                     end_time:,
                     max_results:,
                     start_index:,
                     token:,
                     fields:,
                     quota_user:,
                     options:)
        @package_name = package_name
        @authorization = authorization
        @start_time = start_time
        @end_time = end_time
        @max_results = max_results
        @start_index = start_index
        @token = token
        @fields = fields
        @quota_user = quota_user
        @options = options
      end

      def call
        service.list_purchase_voidedpurchases(package_name, **params) do |result, error|
          yield(purchases(result), pagination(result), error)
        end
      end

      private

      def service
        return @service if @service

        @service = CandyCheck::PlayStore::AndroidPublisherService.new
        @service.authorization = @authorization
        @service
      end

      def purchases(result)
        return [] unless result&.voided_purchases

        result.voided_purchases.map do |purchase|
          CandyCheck::PlayStore::VoidedPurchases::Purchase.new(purchase)
        end
      end

      def params
        { type: 1,
          start_time: start_time,
          end_time: end_time,
          max_results: max_results,
          start_index: start_index,
          token: token,
          fields: fields,
          quota_user: quota_user,
          options: options }
      end

      def pagination(result)
        return unless result.page_info

        CandyCheck::PlayStore::VoidedPurchases::Pagination.new(
          page_info: result.page_info,
          token_pagination: result.token_pagination
        )
      end
    end
  end
end
