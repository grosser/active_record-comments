require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "file::memory:?cache=shared"
)

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.string :name
  end
end

LOG = []

ActiveRecord::ConnectionAdapters::SQLite3Adapter.class_eval do
  alias_method :exec_query_without_log, :exec_query
  def exec_query(query, *args, &block)
    LOG << query
    exec_query_without_log(query, *args, &block)
  end
end

require "active_support/all"
require "active_record/comments"
require "simple_commenter"
require "json_commenter"

class User < ActiveRecord::Base
end
