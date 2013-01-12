require "spec_helper"

describe ActiveRecordComments do
  it "has a VERSION" do
    ActiveRecordComments::VERSION.should =~ /^[\.\da-z]+$/
  end
end
