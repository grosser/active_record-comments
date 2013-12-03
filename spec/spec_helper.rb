require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.string :name
  end
end

LOG = []

ActiveRecord::ConnectionAdapters::SQLiteAdapter.class_eval do
  if ActiveRecord::VERSION::MAJOR > 4 || ActiveRecord::VERSION::STRING < "3.2.0"
    alias_method :execute_without_log, :execute
    def execute(query, *args, &block)
      LOG << query
      execute_without_log(query, *args, &block)
    end
  else
    alias_method :exec_query_without_log, :exec_query
    def exec_query(query, *args, &block)
      LOG << query
      exec_query_without_log(query, *args, &block)
    end
  end
end

require "active_support/all"
require "active_record/comments"

class User < ActiveRecord::Base
end
