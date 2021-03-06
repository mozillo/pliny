require 'rollbar/exception_reporter'
require 'rollbar/request_data_extractor'

module Pliny
  module ErrorReporters
    class Rollbar
      include ::Rollbar::ExceptionReporter
      include ::Rollbar::RequestDataExtractor

      def notify(exception, context:, rack_env:)
        ::Rollbar.reset_notifier!
        scope = fetch_scope(context: context, rack_env: rack_env)
        ::Rollbar.scoped(scope) do
          report_exception_to_rollbar(rack_env, exception)
        end
      end

      private

      def fetch_scope(context:, rack_env:)
        scope = {}
        unless rack_env.empty?
          scope[:request] = proc { extract_request_data_from_rack(rack_env) }
        end
        scope
      rescue Exception => e
        report_exception_to_rollbar(rack_env, e)
        raise
      end
    end
  end
end
