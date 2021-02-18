require "spec_helper"

describe ActiveRecord::Comments::SimpleCommenter do
  subject(:commenter) { ActiveRecord::Comments::SimpleCommenter.new }

  describe "#current_comment" do
    it "is empty when not called" do
      commenter.comment("xxx") {}
      expect(commenter.send(:current_comment)).to eq(nil)
    end

    it "is filled when called" do
      result = nil
      commenter.comment("xxx") do
        result = commenter.send(:current_comment)
      end
      expect(result).to eq("xxx")
    end

    it "concatenates multiple comments" do
      result = nil
      commenter.comment("xxx") do
        commenter.comment("yyy") do
          result = commenter.send(:current_comment)
        end
      end
      expect(result).to eq("xxx yyy")
    end

    it "removes comment when its block ends" do
      result = nil
      commenter.comment("xxx") do
        commenter.comment("yyy") {}
        result = commenter.send(:current_comment)
      end
      expect(result).to eq("xxx")
    end
  end

  describe "#comment" do
    it "returns results" do
      expect(commenter.comment("xxx") { 1 }).to eq(1)
    end
  end

  describe "#with_comment_sql" do
    it "returns sql with comments" do
      result = nil
      commenter.comment("xxx") do
        result = commenter.with_comment_sql("SELECT * FROM User")
      end
      expect(result).to eq('SELECT * FROM User /* xxx */')
    end

    it "returns sql without comments" do
      result = commenter.with_comment_sql("SELECT * FROM User")
      expect(result).to eq("SELECT * FROM User")
    end
  end
end
