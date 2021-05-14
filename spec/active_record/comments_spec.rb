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
    it "is empty when not called" do
      ActiveRecord::Comments.comment("xxx") {}
      expect(ActiveRecord::Comments.send(:current_comment)).to eq(nil)
    end

    it "is filled when called" do
      result = nil
      ActiveRecord::Comments.comment("xxx") do
        result = ActiveRecord::Comments.send(:current_comment)
      end
      expect(result).to eq("xxx")
    end

    it "concatenates multiple comments" do
      result = nil
      ActiveRecord::Comments.comment("xxx") do
        ActiveRecord::Comments.comment("yyy") do
          result = ActiveRecord::Comments.send(:current_comment)
        end
      end
      expect(result).to eq("xxx */ /* yyy")
    end

    it "removes comment when its block ends" do
      result = nil
      ActiveRecord::Comments.comment("xxx") do
        ActiveRecord::Comments.comment("yyy") {}
        result = ActiveRecord::Comments.send(:current_comment)
      end
      expect(result).to eq("xxx")
    end
  end

  describe ".comment" do
    it "returns results" do
      expect(ActiveRecord::Comments.comment("xxx") { 1 }).to eq(1)
    end
  end

  describe "finding" do
    it "is not there when not called" do
      ActiveRecord::Comments.comment("xxx") {}
      sql = capture_sql { User.where(id: 1).to_a }
      expect(sql).to eq('SELECT * FROM "users" WHERE "users"."id" = ?')
    end

    it "is there when called" do
      sql = nil
      ActiveRecord::Comments.comment("xxx") do
        sql = capture_sql { User.where(id: 1).to_a }
      end
      expect(sql).to eq('SELECT * FROM "users" WHERE "users"."id" = ? /* xxx */')
    end

    it "is thread safe" do
      res = []
      ["xx", "yy"].map do |comment|
        Thread.new do
          res << ActiveRecord::Comments.comment(comment) do
            sleep 0.1 # make sure they both enter this block together
            sql = capture_sql { User.where(id: 1).to_a }
          end
        end
      end.each(&:join)

      expect(res.sort.first).to match(/xx/)
      expect(res.sort.first).not_to match(/yy/)

      expect(res.sort.last).to match(/yy/)
      expect(res.sort.last).not_to match(/xx/)
    end
  end

  describe "counting" do
    it "is not there when not called" do
      ActiveRecord::Comments.comment("xxx") {}
      sql = capture_sql { User.where(id: 1).count }
      expect(sql).to eq('SELECT COUNT(*) FROM "users" WHERE "users"."id" = ?')
    end

    it "is there when called" do
      sql = nil
      ActiveRecord::Comments.comment("xxx") do
        sql = capture_sql { User.where(id: 1).count }
      end
      expect(sql).to eq('SELECT COUNT(*) FROM "users" WHERE "users"."id" = ? /* xxx */')
    end
  end

  describe "nested calls" do
    it "appends multiple comments" do
      sql = nil
      ActiveRecord::Comments.comment("xxx") do
        ActiveRecord::Comments.comment("yyy") do
          sql = capture_sql { User.where(id: 1).count }
        end
      end
      expect(sql).to eq('SELECT COUNT(*) FROM "users" WHERE "users"."id" = ? /* xxx */ /* yyy */')
    end
  end
end
