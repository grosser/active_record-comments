Adds comments to your activerecord queries so you can seem where they came from or what user caused them.<br/>
for on Rails 2 + 3 + 4

Install
=======

    gem install active_record-comments

Usage
=====

    require "active_record/comments"

    # => SELECT ... /* user.rb:123 */
    result = ActiveRecord::Comments.comment("user.rb:123"){ User.where("x like y").count }

    # => SELECT ... /* account cleanup initial */
    result = ActiveRecord::Comments.comment("account cleanup") do
      ActiveRecord::Comments.comment("initial"){ User.where("x like y").count }
    end

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/active_record-comments.png)](https://travis-ci.org/grosser/active_record-comments)
