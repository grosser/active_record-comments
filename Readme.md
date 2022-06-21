Adds comments to your activerecord queries so you can seem where they came from or what user caused them.<br/>
Tested on Rails 4/5

ActiveRecord 6.0 introduces an [API to annotate queries](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-annotate)
but doesn't provide a way to pass a block.

Install
=======

```bash
gem install active_record-comments
```

Usage (Default commenter)
=====

```ruby
require "active_record/comments"

# => SELECT ... /* user.rb:123 */
result = ActiveRecord::Comments.comment("user.rb:123") { User.where("x like y").count }

# => SELECT ... /* account cleanup initial */
result = ActiveRecord::Comments.comment("account cleanup") do
  ActiveRecord::Comments.comment("initial") { User.where("x like y").count }
end
```
If you're using raw SQL rather than Active Record to make your query, you will need to use `exec_query` rather than `execute` for comments to be added. e.g.
```ruby
require 'active_record/comments'

ActiveRecord::Comments.comment("My comment")

sql_query = "SELECT * FROM users;"
result = ActiveRecord::Base.connection.exec_query(sql_query)

# => SELECT * FROM users /* My comment */
```

If you're replacing `execute` with `exec_query` to get comments, `exec_query.rows` returns data in the same format as `execute.entries`.

Usage (Json commenter)
=====

```ruby
require "active_record/comments"

ActiveRecord::Comments.configure do |config|
  config.enable_json_comment = true
end

# => SELECT ... /* {"user":"123"} */
result = ActiveRecord::Comments.comment(user: "123") { User.where("x like y").count }

# => SELECT ... /* {"account":"1","service":"commenter"} */
result = ActiveRecord::Comments.comment(account: "1") do
  ActiveRecord::Comments.comment(service: "commenter") { User.where("x like y").count }
end
```

Author
======
[Michael Grosser](https://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
