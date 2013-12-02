require "active_record"

module ActiveRecord
  module Comments
    class << self
      def comment(comment)
        @comment ||= []
        @comment << comment
        yield
      ensure
        @comment.pop
      end

      def with_comment_sql(sql)
        return sql unless comment = current_comment
        "#{sql} /* #{comment} */"
      end

      private

      def current_comment
        @comment.join(" ") if @comment.present?
      end
    end
  end
end

# log is called by execute in all db adapters
ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
  def log_with_comment_injection(query, *args, &block)
    query = ActiveRecord::Comments.with_comment_sql(query)
    log_without_comment_injection(query, *args, &block)
  end
  alias_method_chain :log, :comment_injection
end
