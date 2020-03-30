require "active_record/comments/execute_with_comments"
require "active_record"

module ActiveRecord
  module Comments
    class << self
      def comment(comment)
        current_comments << comment
        yield
      ensure
        current_comments.pop
      end

      def with_comment_sql(sql)
        return sql unless comment = current_comment
        "#{sql} /* #{comment} */"
      end

      private
      def current_comments
        Thread.current[:ar_comments] ||= []
      end

      def current_comment
        current_comments.join(" ") if current_comments.present?
      end
    end
  end
end

ActiveRecord::Comments::ExecuteWithComments.install!
