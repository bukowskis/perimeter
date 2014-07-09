module Perimeter
  module Repository

    Error = Class.new StandardError

    FindingError     = Class.new ::Perimeter::Repository::Error
    CreationError    = Class.new ::Perimeter::Repository::Error
    DestructionError = Class.new ::Perimeter::Repository::Error

  end
end
