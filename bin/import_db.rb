#!/usr/bin/env ruby
dir = Rails.root + 'tmp' + 'exports'
dir.children.each do |path|
  next unless path.fnmatch?('*.json')
  klass = path.basename('.json').to_s.constantize

  buffer = []
  path.each_line do |line|
    buffer << klass.new(JSON.parse(line.strip))
    if 1000 <= buffer.size
      klass.import(buffer, validate: false)
      buffer.map(&:id).join(',')
      buffer.clear
    end
  end
  klass.import(buffer, validate: false) if buffer.present?
  buffer.map(&:id).join(',')
end
