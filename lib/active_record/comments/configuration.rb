module ActiveRecord
  module Comments
    Configuration = Struct.new(:enable_json_comment)

    class << self
      def configure
        yield(configuration)
      end

      private

      def configuration
        @configuration ||= Configuration.new(false)
      end
    end
  end
end
