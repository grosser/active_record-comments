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
end
