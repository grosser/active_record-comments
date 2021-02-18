require "spec_helper"

describe ActiveRecord::Comments::JsonCommenter do
  subject(:commenter) { ActiveRecord::Comments::JsonCommenter.new }

  describe "#current_comment" do
    it "is empty when not a hash" do
      commenter.comment("xxx") {}
      expect(commenter.send(:current_comment)).to eq(nil)
    end

    it "is filled when called with hash" do
      result = nil
      commenter.comment(foo: "bar") do
        result = commenter.send(:current_comment)
      end
      expect(result).to eq('{"foo":"bar"}')
    end

    it "concatenates to json when multiple comments" do
      result = nil
      commenter.comment(foo: "bar") do
        commenter.comment(hello: "world") do
          result = commenter.send(:current_comment)
        end
      end
      expect(result).to eq('{"foo":"bar","hello":"world"}')
    end

    it "merges existing hash key" do
      result = nil
      commenter.comment(foo: "bar") do
        commenter.comment(foo: "world") do
          result = commenter.send(:current_comment)
        end
      end
      expect(result).to eq('{"foo":"world"}')
    end

    it "removes comment when its block ends" do
      result = nil
      commenter.comment(foo: "bar") do
        commenter.comment(hello: "world") {}
        result = commenter.send(:current_comment)
      end
      expect(result).to eq('{"foo":"bar"}')
    end

    it "does not removes comment when its block ends and the key already exist" do
      result = nil
      commenter.comment(foo: "bar") do
        commenter.comment(foo: "world") {}
        result = commenter.send(:current_comment)
      end
      expect(result).to eq('{"foo":"bar"}')
    end
  end

  describe "#comment" do
    it "returns results" do
      expect(commenter.comment(foo: "bar") { 1 }).to eq(1)
    end
  end

  describe "#with_comment_sql" do
    it "returns sql with single k/v pair comment" do
      result = nil
      commenter.comment(foo: "bar") do
        result = commenter.with_comment_sql("SELECT * FROM User")
      end
      expect(result).to eq('SELECT * FROM User /* {"foo":"bar"} */')
    end

    it "returns sql with multiple k/v pair comment" do
      result = nil
      commenter.comment({foo: "bar", hello: "world"}) do
        commenter.comment(hello: "foo") do
          result = commenter.with_comment_sql("SELECT * FROM User")
        end
      end
      expect(result).to eq('SELECT * FROM User /* {"foo":"bar","hello":"foo"} */')
    end

    it "returns sql without comments" do
      result = commenter.with_comment_sql("SELECT * FROM User")
      expect(result).to eq("SELECT * FROM User")
    end
  end
end
