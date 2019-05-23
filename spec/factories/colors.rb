FactoryBot.define do
  factory :color do
    hex { "%06x" % (rand * 0xffffff) }
  end
end
