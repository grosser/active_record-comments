require "spec_helper"

describe ActiveRecord::Comments do
  def normalize_sql(sql)
    sql.gsub("``", '""').gsub("  ", " ").strip
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

  if ActiveRecord::VERSION::MAJOR == 2
    describe "#construct_finder_sql" do
      it "not be there when not called" do
        ActiveRecord::Comments.comment("xxx"){ }
        normalize_sql(User.scoped(:conditions => {:id => 1}).send(:construct_finder_sql, {})).should ==
          'SELECT * FROM "users" WHERE ("users"."id" = 1)'
      end

      it "be there when called" do
        result = nil
        ActiveRecord::Comments.comment("xxx") do
          result = User.scoped(:conditions => {:id => 1}).send(:construct_finder_sql, {})
        end
        normalize_sql(result).should == 'SELECT * FROM "users" WHERE ("users"."id" = 1) /* xxx */'
      end
    end

    describe "#construct_calculation_sql_with_comments" do
      it "not be there when not called" do
        ActiveRecord::Comments.comment("xxx"){ }
        normalize_sql(User.scoped(:conditions => {:id => 1}).send(:construct_calculation_sql_with_comments, "count", "id", {})).should ==
          'SELECT count("users".id) AS count_id FROM "users" WHERE ("users"."id" = 1)'
      end

      it "be there when called" do
        result = nil
        ActiveRecord::Comments.comment("xxx") do
          result = User.scoped(:conditions => {:id => 1}).send(:construct_calculation_sql_with_comments, "count", "id", {})
        end
        normalize_sql(result).should == 'SELECT count("users".id) AS count_id FROM "users" WHERE ("users"."id" = 1) /* xxx */'
      end
    end
  else
    describe "#to_sql" do
      it "not be there when not called" do
        ActiveRecord::Comments.comment("xxx"){ }
        normalize_sql(User.where(:id => 1).to_sql).should == 'SELECT "users".* FROM "users" WHERE "users"."id" = 1'
      end

      it "be there when called" do
        result = nil
        ActiveRecord::Comments.comment("xxx") do
          result = User.where(:id => 1).to_sql
        end
        normalize_sql(result).should == 'SELECT "users".* FROM "users" WHERE "users"."id" = 1 /* xxx */'
      end
    end
  end
end
