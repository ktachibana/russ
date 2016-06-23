#!/usr/bin/env ruby
dir = Rails.root + 'tmp' + 'exports'
dir.mkpath

[User, Feed, Item, Subscription, ActsAsTaggableOn::Tag, ActsAsTaggableOn::Tagging].each do |klass|
  dir.join("#{klass.name}.json").open('w') do |f|
    klass.find_each do |r|
      f.puts r.attributes.to_json # attributesを使わないとUser#encrypted_passwordが出ない
    end
  end
end
