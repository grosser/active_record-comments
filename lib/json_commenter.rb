require "json"

class JsonCommenter
  def comment(comment)
    current_comments.merge!(comment) if comment.is_a?(Hash)
    yield
  ensure
    comment.each { |k, _| current_comments.delete(k) } if comment.is_a?(Hash)
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
