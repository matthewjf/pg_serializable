require 'spec_helper'

Dir[File.join(__dir__, '../models/**/*.rb')].each { |f| require f }

RSpec.describe "json" do
  context 'instance' do
    let(:label) { FactoryBot.create(:label) }
    let(:color) { FactoryBot.create(:color) }
    let(:product) { FactoryBot.create(:product, label: label) }
    let(:variation1) { FactoryBot.create(:variation, color: color) }
    let(:variation2) { FactoryBot.create(:variation, color: color) }

    subject { JSON.parse(product.json) }

    it 'works' do
      expect(subject['id']).to eq(product.id)
      expect(subject['name']).to eq(product.name)
      expect(subject['label']).to include({
        "id" => label.id,
        "name" => label.name
      })
    end
  end

  context 'collection' do

  end
end
