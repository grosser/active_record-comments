require "spec_helper"

describe ActiveRecord::Comments do
  def normalize_sql(sql)
    sql.
      gsub("``", '""').
      gsub("  ", " ").
      gsub("\"users\".*", "*").
      sub(/WHERE \((.*)\)/, "WHERE \\1").
      sub("count(\"users\".id)", "COUNT(*)").
      sub("count(*) AS count_all", "COUNT(*)").
      strip
  end

  def capture_sql
    LOG.clear
    yield
    normalize_sql LOG.last
  end

  describe "finding" do
    it "not be there when not called" do
      ActiveRecord::Comments.commenter.comment("xxx"){ }
      sql = capture_sql { User.where(id: 1).to_a }
      sql.should == 'SELECT * FROM "users" WHERE "users"."id" = ?'
    end

    it "be there when called" do
      sql = nil
      ActiveRecord::Comments.commenter.comment("xxx") do
        sql = capture_sql { User.where(id: 1).to_a }
      end
      sql.should == 'SELECT * FROM "users" WHERE "users"."id" = ? /* xxx */'
    end

    it "should be thread safe" do
      res = []
      ["xx", "yy"].map do |comment|
        Thread.new do
          res << ActiveRecord::Comments.commenter.comment(comment) do
            sleep 0.1 # make sure they both enter this block together
            sql = capture_sql { User.where(id: 1).to_a }
          end
        end
       end.each(&:join)

       res.sort.first.should =~ /xx/
       res.sort.first.should_not =~ /yy/

       res.sort.last.should =~ /yy/
       res.sort.last.should_not =~ /xx/
    end
  end

  describe "counting" do
    it "not be there when not called" do
      ActiveRecord::Comments.commenter.comment("xxx"){ }
      sql = capture_sql { User.where(id: 1).count }
      sql.should == 'SELECT COUNT(*) FROM "users" WHERE "users"."id" = ?'
    end

    it "be there when called" do
      sql = nil
      ActiveRecord::Comments.commenter.comment("xxx") do
        sql = capture_sql { User.where(id: 1).count }
      end
      sql.should == 'SELECT COUNT(*) FROM "users" WHERE "users"."id" = ? /* xxx */'
    end
  end

  context "using json commenter" do
    before do
      ActiveRecord::Comments.configure do |config|
        config.as_json_comment = true
      end
    end

    describe "finding" do
      it "not be there when not called" do
        ActiveRecord::Comments.commenter.comment(foo: "bar"){ }
        sql = capture_sql { User.where(id: 1).to_a }
        sql.should == 'SELECT * FROM "users" WHERE "users"."id" = ?'
      end

      it "be there when called" do
        sql = nil
        ActiveRecord::Comments.commenter.comment(foo: "bar") do
          sql = capture_sql { User.where(id: 1).to_a }
        end
        sql.should == 'SELECT * FROM "users" WHERE "users"."id" = ? /* {"foo":"bar"} */'
      end

      it "should be thread safe" do
        res = []
        [{foo: "bar"}, {hello: "world"}].map do |comment|
          Thread.new do
            res << ActiveRecord::Comments.commenter.comment(comment) do
              sleep 0.1 # make sure they both enter this block together
              sql = capture_sql { User.where(id: 1).to_a }
            end
          end
         end.each(&:join)

         res.sort.first.should =~ /"foo":"bar"/
         res.sort.first.should_not =~ /"hello":"world"/

         res.sort.last.should =~ /"hello":"world"/
         res.sort.last.should_not =~ /"foo":"bar"/
      end
    end

    describe "counting" do
      it "not be there when not called" do
        ActiveRecord::Comments.commenter.comment(foo: "bar"){ }
        sql = capture_sql { User.where(id: 1).count }
        sql.should == 'SELECT COUNT(*) FROM "users" WHERE "users"."id" = ?'
      end

      it "be there when called" do
        sql = nil
        ActiveRecord::Comments.commenter.comment(foo: "bar") do
          sql = capture_sql { User.where(id: 1).count }
        end
        sql.should == 'SELECT COUNT(*) FROM "users" WHERE "users"."id" = ? /* {"foo":"bar"} */'
      end
    end
  end
end
