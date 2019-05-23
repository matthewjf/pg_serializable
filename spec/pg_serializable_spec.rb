require 'spec_helper'

RSpec.describe PgSerializable do
  it "has a version number" do
    expect(PgSerializable::VERSION).not_to be nil
  end
end
