module ActiveRecord
  module Comments
    Configuration = Struct.new

    class << self
      def configure
        yield(configuration)
      end

      private

      def configuration
        @configuration ||= Configuration.new
      end
    end
  end
end
