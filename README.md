# Perimeter

> **[perimeter](https://en.wikipedia.org/wiki/Perimeter) |pəˈrɪmɪtə| noun** -  the continuous line forming the boundary of a closed geometrical figure, alt.  the outermost parts or boundary of an area or object: *the perimeter of the garden*.

As developers we are used to draw strict lines in our code, such as MVC and ORM. There is much buzz about the repository pattern and this gem is an attempt to introduce an implementation convention for it across our applications.

Consider this file structure:

```bash
models
  |- products
  |    \- backend.rb      # Persistence Backend
  |
  |- products.rb          # Repository
  \- product.rb           # Entity
```

The persistence backend is tucked away in a directory and may look like the following code. You are not supposed to interact with the backend at all in your code.

```ruby
module Products
  class Backend < ActiveRecord::Base
  end
end
```

The repository is the only one who may interact with your backends:

```ruby
module Products
  def self.find(id)
  end

  def self.delete(id)
  end
end
```

The repository will typically return PORO Entities:

```ruby
class Product
  attribute :id
  attriute, :name
end
```
