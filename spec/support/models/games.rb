require 'game'
require 'games/backend'
require 'perimeter/repository/adapters/active_record'

module Games
  include Perimeter::Repository::Adapters::ActiveRecord
end
