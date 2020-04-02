require "active_record/comments/execute_with_comments"
require "active_record/comments/simple_commenter"
require "active_record/comments/version"
require "active_record"

module ActiveRecord
  module Comments
    class << self
      def comment(comment, &block)
        simple_commenter.comment(comment, &block)
      end

      def with_comment_sql(sql)
        simple_commenter.with_comment_sql(sql)
      end

      private

      def simple_commenter
        @simple_commenter ||= SimpleCommenter.new
      end
    end
  end
end

ActiveRecord::Comments::ExecuteWithComments.install!
