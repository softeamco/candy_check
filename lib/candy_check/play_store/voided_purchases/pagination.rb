module CandyCheck
  module PlayStore
    class VoidedPurchases
      class Pagination
        # @return [String] General pagination information
        attr_reader :page_info

        # @return [String] Pagination information for token pagination
        attr_reader :token_pagination

        def initialize(page_info:, token_pagination:)
          @page_info = page_info
          @token_pagination = token_pagination
        end

        def paginable?
          page_info
        end

        def total_results
          page_info.total_results
        end

        def per_page
          page_info.result_per_page
        end

        def start_index
          page_info.start_index
        end
      end
    end
  end
end
