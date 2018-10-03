RSpec.describe PgSerializable do
  it "has a version number" do
    expect(PgSerializable::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
