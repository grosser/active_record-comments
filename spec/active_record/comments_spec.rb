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

  describe ".current_comment" do
    it "be empty when not called" do
      ActiveRecord::Comments.comment("xxx"){}
      ActiveRecord::Comments.send(:current_comment).should == nil
    end

    it "be filled when called" do
      result = nil
      ActiveRecord::Comments.comment("xxx") do
        result = ActiveRecord::Comments.send(:current_comment)
      end
      "xxx".should == result
    end

    it "concat" do
      result = nil
      ActiveRecord::Comments.comment("xxx") do
        ActiveRecord::Comments.comment("yyy") do
          result = ActiveRecord::Comments.send(:current_comment)
        end
      end
      result.should == "xxx yyy"
    end

    it "unpop" do
      result = nil
      ActiveRecord::Comments.comment("xxx") do
        ActiveRecord::Comments.comment("yyy") { }
        result = ActiveRecord::Comments.send(:current_comment)
      end
      result.should == "xxx"
    end
  end

  describe ".comment" do
    it "return results" do
      ActiveRecord::Comments.comment("xxx"){ 1 }.should == 1
    end
  end

  describe "finding" do
    it "not be there when not called" do
      ActiveRecord::Comments.comment("xxx"){ }
      sql = capture_sql { User.where(id: 1).to_a }

      if ActiveRecord::VERSION::MAJOR >= 4
        sql.should == 'SELECT * FROM "users" WHERE "users"."id" = ?'
      else
        sql.should == 'SELECT * FROM "users" WHERE "users"."id" = 1'
      end
    end

    it "be there when called" do
      sql = nil
      ActiveRecord::Comments.comment("xxx") do
        sql = capture_sql { User.where(id: 1).to_a }
      end

      if ActiveRecord::VERSION::MAJOR >= 4
        sql.should == 'SELECT * FROM "users" WHERE "users"."id" = ? /* xxx */'
      else
        sql.should == 'SELECT * FROM "users" WHERE "users"."id" = 1 /* xxx */'
      end
    end

    it "should be thread safe" do
      res = []
      ["xx", "yy"].map do |comment|
        Thread.new do
          res << ActiveRecord::Comments.comment(comment) do
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
      ActiveRecord::Comments.comment("xxx"){ }
      sql = capture_sql { User.where(id: 1).count }

      if ActiveRecord::VERSION::MAJOR >= 4
        sql.should == 'SELECT COUNT(*) FROM "users" WHERE "users"."id" = ?'
      else
        sql.should == 'SELECT COUNT(*) FROM "users" WHERE "users"."id" = 1'
      end
    end

    it "be there when called" do
      sql = nil
      ActiveRecord::Comments.comment("xxx") do
        sql = capture_sql { User.where(id: 1).count }
      end

      if ActiveRecord::VERSION::MAJOR >= 4
        sql.should == 'SELECT COUNT(*) FROM "users" WHERE "users"."id" = ? /* xxx */'
      else
        sql.should == 'SELECT COUNT(*) FROM "users" WHERE "users"."id" = 1 /* xxx */'
      end
    end
  end
end
