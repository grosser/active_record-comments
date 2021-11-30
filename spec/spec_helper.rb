require "active_record"

sqlite_file = "file::memory:?cache=shared"
FileUtils.rm_f(sqlite_file)

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => sqlite_file
)

RSpec.configure do |c|
  c.after(:suite) do
    FileUtils.rm_f(sqlite_file)
  end
end

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

  alias_method :execute_without_log, :execute
  def execute(query, *args, &block)
    LOG << query
    execute_without_log(query, *args, &block)
  end
end

require "active_support/all"
require "active_record/comments"

class User < ActiveRecord::Base
end
