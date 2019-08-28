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
      it 'supports product type' do
        should eq({ 'product_type' => product.product_type })
      end
    end

    context 'with postgres enum' do
      subject { JSON.parse(category1.json(trait: :with_postgres_enum)) }

      it do
        should eq({ 'id' => category1.id, 'category_type' => category1.category_type })
      end
    end

    context 'with custom sql' do
      let(:trait) { :custom_sql }
      it 'works' do
        should eq({ 'deleted' => !product.active })
      end
    end

    context 'with custom attributes' do
      let(:trait) { :custom_attributes}
      it 'allows custom labels' do
        should eq({ 'id' => product.id, 'custom_name' => product.name })
      end
    end

    context 'has many variations' do
      let(:trait) { :has_many }
      it 'supports :has_many' do
        should eq({
          'id' => product.id,
          'variations' => [
            variation1.slice('id', 'name'),
            variation2.slice('id', 'name')
          ]
        })
      end
    end

    context 'belongs to label' do
      let(:trait) { :belongs_to }

      it 'supports :belongs_to' do
        should eq({
          'id' => product.id,
          'label' => product.label.slice(:id, :name)
        })
      end
    end

    context 'has and belongs to many categories' do
      let(:trait) { :habtm }
      it 'supports :has_and_belongs_to_many' do
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

      it 'supports :has_many through' do
        should eq({
          'id' => product.id,
          'colors' => [
            color1.slice('id', 'hex'),
            color2.slice('id', 'hex')
          ]
        })
      end

      it 'supports :has_many through a :belongs_to' do
        result_json = JSON.parse(color1.json(trait: :has_many_through))

        expect(result_json).to eq({
          'id' => color1.id,
          'products' => [ product.slice(:id, :name) ]
        })
      end
    end

    context 'deeply nested and many associations' do
      let(:trait) { :complex }

      it 'includes nested associations' do
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
    let!(:product3) { FactoryBot.create(:product, label: nil) }

    let!(:variation1) { FactoryBot.create(:variation, color: color1, product: product1) }
    let!(:variation2) { FactoryBot.create(:variation, color: color2, product: product1) }
    let!(:variation3) { FactoryBot.create(:variation, color: color2, product: product2) }

    let!(:category1) { FactoryBot.create(:category, products: [product1]) }
    let!(:category2) { FactoryBot.create(:category, products: [product1, product2]) }

    subject { JSON.parse(scope.json(trait: trait)) }
    let(:trait) { :default }
    let(:scope) { Product }

    it 'works without trait' do
      expect(JSON.parse(Product.json)).to match_array([
        product1.slice(:name, :id),
        product2.slice(:name, :id),
        product3.slice(:name, :id)
      ])
    end

    it 'with default trait' do
      should match_array([
        product1.slice(:name, :id),
        product2.slice(:name, :id),
        product3.slice(:name, :id)
      ])
    end

    context 'with where scope' do
      let(:scope) { Product.limit(2).where(label: label1) }
      it 'supports scopes' do
        should eq([ product1.slice(:id, :name) ])
      end
    end

    context 'scope with joins' do
      let(:scope) { Product.joins(:label) }
      it do
        should eq([
          product1.slice(:id, :name),
          product2.slice(:id, :name)
        ])
      end
    end

    context 'join with association included in trait' do
      let(:scope) { Product.joins(:label) }
      let(:trait) { :belongs_to }
      it 'supports table aliasing' do
        should eq([
          product1.slice(:id).merge(label: product1.label.slice(:id, :name)),
          product2.slice(:id).merge(label: product2.label.slice(:id, :name))
        ])
      end
    end

    context 'deeply nested and many associations' do
      let(:scope) { Product }
      let(:trait) { :complex }

      it 'includes nested associations' do
        should eq([
          {
            'id' => product1.id,
            'name' => product1.name,
            'label' => product1.label.slice(:name, :id),
            'variations' => [
              variation1.slice(:id, :name).merge({ color: variation1.color.slice(:id, :hex) }),
              variation2.slice(:id, :name).merge({ color: variation2.color.slice(:id, :hex) })
            ],
            'categories' => [
              category1.slice(:id, :name),
              category2.slice(:id, :name)
            ]
          },
          {
            'id' => product2.id,
            'name' => product2.name,
            'label' => product2.label.slice(:name, :id),
            'variations' => [
              variation3.slice(:id, :name).merge({ color: variation3.color.slice(:id, :hex) })
            ],
            'categories' => [
              category2.slice(:id, :name)
            ]
          },
          {
            'id' => product3.id,
            'name' => product3.name,
            'label' => nil,
            'variations' => [],
            'categories' => []
          }
        ])
      end
    end
  end
end
