$LOAD_PATH.unshift File.expand_path('../support/models', __FILE__)

require 'perimeter'

module ActiveRecord
  RecordNotFound = Class.new(StandardError)
end
