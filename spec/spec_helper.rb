require "active_record"
require "fileutils"

sqlite_db = "test_db.sqlite"
FileUtils.rm_f(sqlite_db)

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: sqlite_db # TODO: "file::memory:?cache=shared&uri=true" is broken https://github.com/rails/rails/issues/8805
)

RSpec.configure do |c|
  c.after(:suite) { FileUtils.rm_f(sqlite_db) }
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
  def exec_query(query, *args, prepare: false, &block)
    LOG << query
    exec_query_without_log(query, *args, prepare: prepare, &block)
  end
end

require "active_support/all"
require "active_record/comments"

class User < ActiveRecord::Base
end
