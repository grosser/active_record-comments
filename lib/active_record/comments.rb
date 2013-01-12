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
        sql.sub(/([a-z]*)/i, "\\1 /* #{comment} */")
      end

      private

      def current_comment
        @comment.join(" ") if @comment.present?
      end
    end
  end
end

if ActiveRecord::VERSION::MAJOR == 2
  class << ActiveRecord::Base
    def construct_finder_sql_with_comments(options)
      sql = construct_finder_sql_without_comments(options)
      ActiveRecord::Comments.with_comment_sql(sql)
    end
    alias_method_chain(:construct_finder_sql, :comments)

    def construct_calculation_sql_with_comments(operation, column_name, options)
      sql = construct_calculation_sql_without_comments(operation, column_name, options)
      ActiveRecord::Comments.with_comment_sql(sql)
    end
    alias_method_chain(:construct_calculation_sql, :comments)
  end
else
  klass = if ActiveRecord::VERSION::MAJOR == 3 && ActiveRecord::VERSION::MINOR == 0
    Arel::SelectManager
  else
    ActiveRecord::Relation
  end

  klass.class_eval do
    alias to_sql_with_comments to_sql
    def to_sql
      ActiveRecord::Comments.with_comment_sql(to_sql_with_comments)
    end
  end
end
