require "spec_helper"

describe JsonCommenter do
  subject(:commenter) { JsonCommenter.new }

  describe "#comment" do
    it "be empty when not hash" do
      commenter.comment("xxx") { }
      commenter.send(:current_comment).should == nil
    end

    it "be filled when called with hash" do
      result = nil
      commenter.comment(foo: "bar") do
        result = commenter.send(:current_comment)
      end
      '{"foo":"bar"}'.should == result
    end

    it "appends multiple comments" do
      result = nil
      commenter.comment(foo: "bar") do
        commenter.comment(hello: "world") do
          result = commenter.send(:current_comment)
        end
      end
      '{"foo":"bar","hello":"world"}'.should == result
    end

    it "merges existing hash key" do
      result = nil
      commenter.comment(foo: "bar") do
        commenter.comment(foo: "world") do
          result = commenter.send(:current_comment)
        end
      end
      result.should == '{"foo":"world"}'
    end

    it "ignores last comment when nothing to yield" do
      result = nil
      commenter.comment(foo: "bar") do
        commenter.comment(hello: "world") { }
        result = commenter.send(:current_comment)
      end
      result.should == '{"foo":"bar"}'
    end

    it "return results" do
      commenter.comment(foo: "bar"){ 1 }.should == 1
    end
  end

  describe "#with_comment_sql" do
    it "returns sql with comments" do
      result = nil
      commenter.comment(foo: "bar") do
        result = commenter.with_comment_sql("SELECT * FROM User")
      end
      result.should == 'SELECT * FROM User /* {"foo":"bar"} */'
    end

    it "returns sql without comments" do
      result = commenter.with_comment_sql("SELECT * FROM User")
      result.should == "SELECT * FROM User"
    end
  end
end
