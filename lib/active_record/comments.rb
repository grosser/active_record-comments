require "active_record/comments/execute_with_comments"
require "active_record/comments/version"
require "active_record"

module ActiveRecord
  module Comments
    class << self
      @@prepend = false

      def prepend=prepend
        @@prepend = prepend
      end

      def comment(comment)
        current_comments << comment
        yield
      ensure
        current_comments.pop
      end

      def with_comment_sql(sql)
        return sql unless comment = current_comment

        if @@prepend == true
          "/* #{comment} */ #{sql}"
        else
          "#{sql} /* #{comment} */"
        end
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
