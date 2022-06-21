require "active_record/comments/configuration"
require "active_record/comments/execute_with_comments"
require "active_record/comments/json_commenter"
require "active_record/comments/simple_commenter"
require "active_record/comments/version"
require "active_record"

module ActiveRecord
  module Comments
    class << self
      def comment(comment, &block)
        commenter.comment(comment, &block)
      end

      def with_comment_sql(sql)
        commenter.with_comment_sql(sql)
      end

      private

      def commenter
        configuration.enable_json_comment ? json_commenter : simple_commenter
      end

      def json_commenter
        @json_commenter ||= JsonCommenter.new
      end

      def simple_commenter
        @simple_commenter ||= SimpleCommenter.new
      end
    end
  end
end

ActiveRecord::Comments::ExecuteWithComments.install!
