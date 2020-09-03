module CandyCheck
  module PlayStore
    class VoidedPurchases
      def initialize(authorization:)
        @authorization = authorization
      end

      def voided_purchases(package_name:,
                           start_time: nil,
                           end_time: nil,
                           max_results: nil,
                           start_index: nil,
                           token: nil,
                           fields: nil,
                           quota_user: nil,
                           options: nil)
        list = CandyCheck::PlayStore::VoidedPurchases::List.new(
          package_name: package_name,
          authorization: @authorization,
          kind: kind,
          start_time: start_time,
          end_time: end_time,
          max_results: max_results,
          start_index: start_index,
          token: token,
          fields: fields,
          quota_user: quota_user,
          options: options
        )

        list.call do |purchases, pagination, error|
          yield(purchases, pagination, error)
        end
      end
    end
  end
end
