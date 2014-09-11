module Songs
  class Backend
    include Virtus.model

    attribute :id, Integer
    attribute :title, String
    attribute :length, String

    def errors
      []
    end
  end
end
