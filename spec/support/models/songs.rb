require 'song'
require 'perimeter/repository'
require 'songs/backend'

module Songs
  include Perimeter::Repository

  def self.my_favorite_song
    record = Songs::Backend.new title: "I'm singing in the rain", length: '2:00'
    record_to_entity record
  end

  def self.after_conversion(entity, record)
    entity.title = "#{entity.title} (#{record.length})"
  end
end
