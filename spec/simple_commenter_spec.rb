require "spec_helper"

describe SimpleCommenter do
  subject(:commenter) { SimpleCommenter.new }

  describe "#current_comment" do
    it "be empty when not called" do
      commenter.comment("xxx"){}
      commenter.send(:current_comment).should == nil
    end

    it "be filled when called" do
      result = nil
      commenter.comment("xxx") do
        result = commenter.send(:current_comment)
      end
      "xxx".should == result
    end

    it "concat" do
      result = nil
      commenter.comment("xxx") do
        commenter.comment("yyy") do
          result = commenter.send(:current_comment)
        end
      end
      result.should == "xxx yyy"
    end

    it "unpop" do
      result = nil
      commenter.comment("xxx") do
        commenter.comment("yyy") { }
        result = commenter.send(:current_comment)
      end
      result.should == "xxx"
    end
  end

  describe "#comment" do
    it "return results" do
      commenter.comment("xxx"){ 1 }.should == 1
    end
  end
end
