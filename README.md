# PgSerializable
[![codecov](https://codecov.io/gh/matthewjf/pg_serializable/branch/master/graph/badge.svg)](https://codecov.io/gh/matthewjf/pg_serializable)
[![Maintainability](https://api.codeclimate.com/v1/badges/f3450fdd21d38e2a2fe6/maintainability)](https://codeclimate.com/github/matthewjf/pg_serializable/maintainability)
[![Gem Version](https://badge.fury.io/rb/pg_serializable.svg)](https://badge.fury.io/rb/pg_serializable)

## Description

Serialize json directly from postgres (9.4+).

## Upgrading from version 2.x.x to 3.x.x

Serialization returns a PORO instead of a json string. If you have code like:
```ruby
OJ.load(Product.where(id: ids).json)
```

You can replace it with:
```ruby
Product.where(id: ids).json
```

To automatically use OJ to serialize your POROs to json strings, add this code to your initialization:
```ruby
Oj.optimize_rails()
```

## Motivation
Models:
```ruby
class Product < ApplicationRecord
  has_many :categories_products
  has_many :categories, through: :categories_products
  has_many :variations
  belongs_to :label
end
class Variation < ApplicationRecord
  belongs_to :product
  belongs_to :color
end
class Color < ApplicationRecord
  has_many :variations
end
class Label < ApplicationRecord
  has_many :products
end
class Category < ApplicationRecord
  has_many :categories_products
  has_many :products, through: :categories_products
end
```

Using Jbuilder+ActiveRecord:
```ruby
class Api::ProductsController < ApplicationController
  def index
    @products = Product.limit(200)
                       .order(updated_at: :desc)
                       .includes(:categories, :label, variations: :color)
    render 'api/products/index.json.jbuilder'
  end
end
```
```shell
Completed 200 OK in 2975ms (Views: 2944.2ms | ActiveRecord: 29.9ms)
```

Using fast_jsonapi:
```ruby
class Api::ProductsController < ApplicationController
  def index
    @products = Product.limit(200)
                       .order(updated_at: :desc)
                       .includes(:categories, :label, variations: :color)
    options = {
      include: [:categories, :variations, :label, :'variations.color']
    }

    render json: ProductSerializer.new(@products, options).serialized_json
  end
end
```
```shell
Completed 200 OK in 542ms (Views: 0.5ms | ActiveRecord: 29.0ms)
```

Using PgSerializable:
```ruby
class Api::ProductsController < ApplicationController
  def index
    render json: Product.limit(200).order(updated_at: :desc).json
  end
end
```
```shell
Completed 200 OK in 54ms (Views: 0.1ms | ActiveRecord: 43.0ms)
```

Benchmarking `fast_jsonapi` against `pg_serializable` on 100 requests:
```shell
                      user     system      total        real
jbuilder        175.620000  70.750000 246.370000 (282.967300)
fast_jsonapi     37.880000   0.720000  38.600000 ( 48.234853)
pg_serializable   1.180000   0.080000   1.260000 (  4.150280)
```

You'll see the greatest benefits from PgSerializable for deeply nested json objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_serializable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_serializable

## Configuration

To ensure traits are valid during rails initialization instead of when accessed:
```ruby
# config/initializers/pg_serializable.rb
PgSerializable.validate_traits!
```

## Migrating from version 1 to 2

Trait validations were occasionally running before the class's traits were loaded when there are complex dependencies. These were moved out of the class definition. To maintain existing behavior, add `PgSerializable.validate_traits!` to an initializer. See [configuration](#Configuration).

## Usage

In your model:
```ruby
require 'pg_serializable'

class Product < ApplicationRecord
  include PgSerializable

  serializable do
    default do
      attributes :name, :id
      attribute :name, label: :test_name
    end
  end
end
```

You can also include it in your `ApplicationRecord` so all models will be serializable.

In your controller:
```ruby
render json: Product.limit(200).order(updated_at: :desc).json
```

It works with single records:
```ruby
render json: Product.find(10).json
```

### Attributes
List attributes:
```ruby
attributes :name, :id
```
results in:
```json
[
  {
    "id": 503,
    "name": "Direct Viewer"
  },
  {
    "id": 502,
    "name": "Side Disc Bracket"
  }
]
```
Re-label individual attributes:
```ruby
attributes :id
attribute :name, label: :different_name
```
```json
[
  {
    "id": 503,
    "different_name": "Direct Viewer"
  },
  {
    "id": 502,
    "different_name": "Side Disc Bracket"
  }
]
```

Wrap attributes in custom sql
```ruby
serializable do
  default do
    attributes :id
    attribute :active, label: :deleted { |v| "NOT #{v}" }
  end
end
```
```sql
SELECT
  COALESCE(json_agg(
    json_build_object('id', a0.id, 'deleted', NOT a0.active)
  ), '[]'::json)
FROM (
  SELECT "products".*
  FROM "products"
  ORDER BY "products"."updated_at" DESC
  LIMIT 2
) a0
```
```json
[
  {
    "id": 503,
    "deleted": false
  },
  {
    "id": 502,
    "deleted": false
  }
]
```
### Traits

```ruby
serializable do
  default do
    attributes :id, :name
  end

  trait :simple do
    attributes :id
  end
end
```

```ruby
render json: Product.limit(10).json(trait: :simple)
```

```json
[
  { "id": 1 },
  { "id": 2 },
  { "id": 3 },
  { "id": 4 },
  { "id": 5 },
  { "id": 6 },
  { "id": 7 },
  { "id": 8 },
  { "id": 9 },
  { "id": 10 }
]
```

### Associations
Supported associations:
- `belongs_to`
- `has_many`
- `has_many :through`
- `has_and_belongs_to_many`
- `has_one`

#### belongs_to
```ruby
serializable do
  default do
    attributes :id, :name
    belongs_to :label
  end
end
```
```json
[
  {
    "id": 503,
    "label": {
      "name": "Piper",
      "id": 106
    }
  },
  {
    "id": 502,
    "label": {
      "name": "Sebrina",
      "id": 77
    }
  }
]
```

#### has_many
Works for nested relationships
```ruby
class Product < ApplicationRecord
  serializable do
    default do
      attributes :id, :name
      has_many :variations
    end
  end
end

class Variation < ApplicationRecord
  serializable do
    default do
      attributes :id, :name
      belongs_to :color
    end
  end
end

class Color < ApplicationRecord
  serializable do
    default do
      attributes :id, :hex
    end
  end
end
```
```json
[
  {
    "id": 503,
    "variations": [
      {
        "name": "Cormier",
        "id": 2272,
        "color": {
          "id": 5,
          "hex": "f4b9c8"
        }
      },
      {
        "name": "Spencer",
        "id": 2271,
        "color": {
          "id": 586,
          "hex": "2e0719"
        }
      }
    ]
  },
  {
    "id": 502,
    "variations": [
      {
        "name": "DuBuque",
        "id": 2270,
        "color": {
          "id": 593,
          "hex": "0b288f"
        }
      },
      {
        "name": "Berge",
        "id": 2269,
        "color": {
          "id": 536,
          "hex": "b2bfee"
        }
      }
    ]
  }
]
```

#### has_many :through
```ruby
class Product < ApplicationRecord
  has_many :categories_products
  has_many :categories, through: :categories_products

  serializable do
    default do
      attributes :id
      has_many :categories
    end
  end
end

class Category < ApplicationRecord
  serializable do
    default do
      attributes :name, :id
    end
  end
end
```

```json
[
  {
    "id": 503,
    "categories": [
      {
        "name": "Juliann",
        "id": 13
      },
      {
        "name": "Teressa",
        "id": 176
      },
      {
        "name": "Garret",
        "id": 294
      }
    ]
  },
  {
    "id": 502,
    "categories": [
      {
        "name": "Rossana",
        "id": 254
      }
    ]
  }
]
```

#### has_many_and_belongs_to_many
```ruby
class Product < ApplicationRecord
  has_and_belongs_to_many :categories

  serializable do
    default do
      attributes :id
      has_and_belongs_to_many :categories
    end
  end
end

class Category < ApplicationRecord
  serializable do
    default do
      attributes :name, :id
    end
  end
end
```

```json
[
  {
    "id": 503,
    "categories": [
      {
        "name": "Juliann",
        "id": 13
      },
      {
        "name": "Teressa",
        "id": 176
      },
      {
        "name": "Garret",
        "id": 294
      }
    ]
  },
  {
    "id": 502,
    "categories": [
      {
        "name": "Rossana",
        "id": 254
      }
    ]
  }
]
```

#### has_one

```ruby
class Product < ApplicationRecord
  has_one :variation

  serializable do
    default do
      attributes :name, :id
      has_one :variation
    end
  end
end
```

```json
[
  {
    "name": "GPS Kit",
    "id": 1003,
    "variation": {
      "name": "Gottlieb",
      "id": 4544,
      "color": {
        "id": 756,
        "hex": "67809b"
      }
    }
  },
  {
    "name": "Video Transmitter",
    "id": 1002,
    "variation": {
      "name": "Hessel",
      "id": 4535,
      "color": {
        "id": 111,
        "hex": "144f9e"
      }
    }
  }
]
```

### Association Traits
Models:
```ruby
class Product < ApplicationRecord
  has_many :variations

  serializable do
    default do
      attributes :id, :name
    end

    trait :with_variations do
      attributes :id
      has_many :variations, trait: :for_products
    end
  end
end

class Variation < ApplicationRecord
  serializable do
    default do
      attributes :id
      belongs_to: :color
    end

    trait :for_products do
      attributes :id
    end
  end
end
```

Controller:
```ruby
render json: Product.limit(3).json(trait: :with_variations)
```
Response:
```json
[
   {
      "id":1,
      "variations":[

      ]
   },
   {
      "id":2,
      "variations":[
         {
            "id":5
         },
         {
            "id":4
         },
         {
            "id":3
         },
         {
            "id":2
         },
         {
            "id":1
         }
      ]
   },
   {
      "id":3,
      "variations":[
         {
            "id":14
         },
         {
            "id":13
         },
         {
            "id":12
         },
         {
            "id":11
         },
         {
            "id":10
         },
         {
            "id":9
         },
         {
            "id":8
         },
         {
            "id":7
         },
         {
            "id":6
         }
      ]
   }
]
```

### Single Table Inheritance

It works with single table inheritance. Traits must be defined on each class individually.

## Without Rails

Rails isn't a dependency of this gem. However, setting it up to work without Rails takes some work. The `specs/support` folder has the initialization code needed to run the gem with just `ActiveSupport` and `ActiveRecord`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgements

Full credit Colin Rhodes for the idea.
