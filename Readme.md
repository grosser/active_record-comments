![CI](https://github.com/grosser/active_record-comments/workflows/CI/badge.svg)

Adds comments to your activerecord queries so you can seem where they came from or what user caused them.<br/>
Tested on Rails 4/5

ActiveRecord 6.0 introduces an [API to annotate queries](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-annotate) 
but doesn't provide a way to pass a block.

Install
=======

```bash
gem install active_record-comments
```

Usage
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

Author
======
[Michael Grosser](https://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/active_record-comments.svg)](https://travis-ci.org/grosser/active_record-comments)
