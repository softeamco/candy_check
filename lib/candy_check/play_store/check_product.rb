module CandyCheck
  module PlayStore
    class CheckProduct
      def initialize(authorization:)
        @authorization = authorization
      end

      def in_app_product(package_name:, sku:)
        in_app_product = CandyCheck::PlayStore::InAppProduct::Product.new(
          package_name: package_name,
          sku: sku,
          authorization: @authorization,
          )
        in_app_product.call!
      end
    end
  end
end
