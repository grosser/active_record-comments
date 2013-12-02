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

ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
  def log_with_query_diet(query, *args, &block)
    LOG << query
    log_without_query_diet(query, *args, &block)
  end
  alias_method_chain :log, :query_diet
end

require "active_support/all"
require "active_record/comments"

class User < ActiveRecord::Base
end
