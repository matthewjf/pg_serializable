require 'spec_helper'

RSpec.describe "json" do
  context 'instance' do
    let(:label) { FactoryBot.create(:label) }
    let(:color1) { FactoryBot.create(:color) }
    let(:color2) { FactoryBot.create(:color) }
    let(:product) { FactoryBot.create(:product, label: label) }
    let(:variation1) { FactoryBot.create(:variation, color: color1, product: product) }
    let(:variation2) { FactoryBot.create(:variation, color: color2, product: product) }
    let(:category1) { FactoryBot.create(:category, products: [product]) }
    let(:category2) { FactoryBot.create(:category, products: [product]) }

    subject { JSON.parse(product.json(trait: trait)) }

    it 'works with simple attributes without trait' do
      json_result = JSON.parse(product.json)

      expect(json_result).to eq({
        'id' => product.id,
        'name' => product.name
      })
    end

    context 'with enums' do
      let(:trait) { :enum }
      it { should eq({ 'product_type' => product.product_type }) }
    end

    context 'with custom sql' do
      let(:trait) { :custom_sql }
      it { should eq({ 'deleted' => !product.active }) }
    end

    context 'with custom attributes' do
      let(:trait) { :custom_attributes}
      it { should eq({ 'id' => product.id, 'custom_name' => product.name }) }
    end

    context 'has many variations' do
      let(:trait) { :has_many }
      it do
        should eq({
          'id' => product.id,
          'variations' => [
            variation1.slice('id', 'name'),
            variation2.slice('id', 'name')
          ]
        })
      end
    end

    context 'has and belongs to many categories' do
      let(:trait) { :habtm }
      it do
        should eq({
          'id' => product.id,
          'categories' => [
            category1.slice('id', 'name'),
            category2.slice('id', 'name')
          ]
        })
      end
    end

    context 'has many colors through variations' do
      let(:trait) { :has_many_through }

      before do
        variation1
        variation2
      end

      it do
        should eq({
          'id' => product.id,
          'colors' => [
            color1.slice('id', 'hex'),
            color2.slice('id', 'hex')
          ]
        })
      end

      it 'works for :has_many through a :belongs_to' do
        result_json = JSON.parse(color1.json(trait: :has_many_through))

        expect(result_json).to eq({
          'id' => color1.id,
          'products' => [ product.slice(:id, :name) ]
        })
      end
    end

    context 'deeply nested and many associations' do
      let(:trait) { :complex }

      it do
        should eq({
          'id' => product.id,
          'name' => product.name,
          'label' => product.label.slice(:name, :id),
          'variations' => [
            variation1.slice(:id, :name).merge({ color: variation1.color.slice(:id, :hex) }),
            variation2.slice(:id, :name).merge({ color: variation2.color.slice(:id, :hex) })
          ],
          'categories' => [
            category1.slice(:id, :name),
            category2.slice(:id, :name)
          ]
        })
      end
    end
  end

  context 'collection' do

    let!(:label1) { FactoryBot.create(:label) }
    let!(:label2) { FactoryBot.create(:label) }

    let!(:color1) { FactoryBot.create(:color) }
    let!(:color2) { FactoryBot.create(:color) }
    let!(:color3) { FactoryBot.create(:color) }

    let!(:product1) { FactoryBot.create(:product, label: label1) }
    let!(:product2) { FactoryBot.create(:product, label: label2) }

    let!(:variation1) { FactoryBot.create(:variation, color: color1, product: product1) }
    let!(:variation2) { FactoryBot.create(:variation, color: color2, product: product1) }
    let!(:variation3) { FactoryBot.create(:variation, color: color2, product: product2) }

    let!(:category1) { FactoryBot.create(:category, products: [product1]) }
    let!(:category2) { FactoryBot.create(:category, products: [product1, product2]) }


  end
end
