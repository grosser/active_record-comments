require "json"

module ActiveRecord
  module Comments
    class JsonCommenter
      def comment(comment)
        return yield unless comment.is_a?(Hash)

        begin
          orig = current_comments.dup
          current_comments.merge!(comment)
          yield
        ensure
          current_comments.replace(orig)
        end
      end

      def with_comment_sql(sql)
        return sql unless comment = current_comment

        "#{sql} /* #{comment} */"
      end

      private

      def current_comments
        Thread.current[:ar_json_comment] ||= {}
      end

      def current_comment
        current_comments.to_json if current_comments.present?
      end
    end
  end
end
