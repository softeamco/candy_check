module CandyCheck
  module PlayStore
    module InAppProduct
      class Product
        # @return [String] the package_name which will be queried
        attr_reader :package_name
        # @return [String] the item id which will be queried
        attr_reader :sku, :service

        # Initializes a new call to the API
        # @param package_name [String]
        # @param sku [String]
        def initialize(package_name:, sku:, authorization:)
          @package_name = package_name
          @sku = sku
          @authorization = authorization
          @service = CandyCheck::PlayStore::AndroidPublisherService.new
          @service.authorization = @authorization
        end

        def call!
          in_app_product!
        end

        private

        def in_app_product!
          service.get_inappproduct(package_name, sku) do |result, error_data|
            if error_data&.message == 'Invalid request'
              monetization_subscription!
            else
              @response = { result: result, error_data: error_data, subscription: false }
            end
          end
        end

        def monetization_subscription!
          service.get_monetization_subscription(package_name, sku) do |result, error_data|
            @response = { result: result, error_data: error_data, subscription: true }
          end
        end
      end
    end
  end
end
