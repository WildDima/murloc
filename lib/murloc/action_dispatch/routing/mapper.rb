module ActionDispatch
  module Routing
    # Monkey patching for adding in locale urls
    # rubocop:disable Metrics/LineLength
    class Mapper
      def in_locales(locales, &block)
        scope_name = ':locale'
        scope_args = { locale: /#{locales.join("|")}/ }

        scope(scope_name, scope_args, &block)

        match '',
              to: redirect { |_, request| "#{I18n.locale}#{query_params(request)}" },
              via: :all

        match '*path',
              to: redirect { |params, request| "#{I18n.locale}#{path_params(params)}#{query_params(request)}" },
              constraints: { path: %r{(?!(#{I18n.available_locales.join("|")})\/).*} }, via: :all
      end
      # rubocop:enable Metrics/LineLength

      private

      def query_params(request)
        qp = request.query_parameters
        "?#{qp.to_query}" if qp.present?
      end

      def path_params(params)
        "/#{params[:path]
              .gsub(/^#{I18n.available_locales.join("|")}/, '')
              .gsub(%r{^\/}, '')}"
      end
    end
  end
end
