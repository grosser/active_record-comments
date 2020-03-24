require "active_record"
require_relative "../simple_commenter"
require_relative "../json_commenter"

module ActiveRecord
  module Comments
    module ExecuteWithComments
      class << self
        def included(base)
          base.class_eval do
            # ActiveRecord 3.2 vs sqlite, maybe others ...
            if base.method_defined?(:exec_query)
              alias_method :exec_query_without_comment, :exec_query
              def exec_query(query, *args, &block)
                query = ActiveRecord::Comments.commenter.with_comment_sql(query)
                exec_query_without_comment(query, *args, &block)
              end

            # 99% case
            elsif base.method_defined?(:execute)
              alias_method :execute_without_comment, :execute
              def execute(query, *args, &block)
                query = ActiveRecord::Comments.commenter.with_comment_sql(query)
                execute_without_comment(query, *args, &block)
              end
            end
          end
        end

        def install!
          if defined? ActiveRecord::ConnectionAdapters::SQLite3Adapter
            install ActiveRecord::ConnectionAdapters::SQLite3Adapter
          end

          if defined? ActiveRecord::ConnectionAdapters::MysqlAdapter
            install ActiveRecord::ConnectionAdapters::MysqlAdapter
          end

          if defined? ActiveRecord::ConnectionAdapters::Mysql2Adapter
            install ActiveRecord::ConnectionAdapters::Mysql2Adapter
          end

          if defined? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
            install ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
          end
        end

        private

        def install(adapter)
          adapter.send(:include, ::ActiveRecord::Comments::ExecuteWithComments)
        end
      end
    end

    class << self
      Config = Struct.new(:as_json_comment, keyword_init: true)

      def configuration
        @configuration ||= Config.new(as_json_comment: false)
      end

      def configure
        yield(configuration)
      end

      def commenter
        configuration.as_json_comment ? JsonCommenter.new : SimpleCommenter.new
      end

      private

      def simple_commenter
        @simple_commenter ||= SimpleCommenter.new
      end

      def json_commenter
        @json_commenter ||= JsonCommenter.new
      end
    end
  end
end

ActiveRecord::Comments::ExecuteWithComments.install!
