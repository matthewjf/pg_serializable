require 'spec_helper'

RSpec.describe "json" do

  context 'single table inheritance' do
    let!(:component) { FactoryBot.create(:component) }
    let!(:material) { FactoryBot.create(:material_component) }
    let!(:labor) { FactoryBot.create(:labor_component) }

    it 'works for the base class' do
      json_result = Component.json
      expect(json_result).to match_array([
        {
          "id" => component.id,
          "name" => component.name,
          "type" => component.type
        },
        {
          "id" => material.id,
          "name" => material.name,
          "type" => material.type
        },
        {
          "id" => labor.id,
          "name" => labor.name,
          "type" => labor.type
        }
      ])
    end

    it 'works for the inherited classes with scope' do
      json_results = MaterialComponent.limit(10).json

      expect(json_results).to eq([
        {
          "id" => material.id,
          "name" => material.name
        }
      ])
    end

    it 'works for single records of inherited classes' do
      json_result = labor.json
      expect(json_result).to eq({
        "id" => labor.id
      })
    end
  end
end
