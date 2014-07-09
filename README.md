# Perimeter

> **[perimeter](https://en.wikipedia.org/wiki/Perimeter) |pəˈrɪmɪtə| noun** -  the continuous line forming the boundary of a closed geometrical figure, alt.  the outermost parts or boundary of an area or object: *the perimeter of the garden*.

As developers we are used to draw strict lines in our code, such as with MVC and ORM. There is much buzz about the repository pattern and this gem is an attempt to introduce an implementation convention for it across our applications.

Consider this file structure:

```bash
models
  |- product.rb           # Entity
  |- products.rb          # Repository
  \- products
       |- backend.rb      # Persistence Backend
       \- calculator.rb   # (Here you can put any other related class)
```

## Entity

This is where your business logic lives. Here you have [Virtus](https://github.com/solnic/virtus) and [ActiveModel Validations](http://api.rubyonrails.org/classes/ActiveModel/Validations.html) at your fingertips.

```ruby
class Product
  attriute, :name

  validate :name, presence: true
end
```

## Repository

This is where you run CRUD operations for your Entities. The repository is the only one who may interact with your persistence backend.

```ruby
module Products
  def self.find(id)
    # ...
  end

  def self.destroy(id)
    # ...
  end
end
```

Every method of the repository always returns an [Operation](http://rubygems.org/gems/operation) instance. You can, however, use the bang version (e.g. '#find!') so that the operation will raise an Exception if it was not successful. Again, what is a "successful" operation is defined [here](https://github.com/bukowskis/perimeter/blob/master/lib/perimeter/repository/adapters/abstract.rb) and not neccessarily that which you know from ActiveRecord. A few methods are *inspired* by the ActiveRecord API, such as find, destroy,... (see them [here](https://github.com/bukowskis/perimeter/blob/master/lib/perimeter/repository/adapters/abstract.rb)). But not more than that, because the repository is supposed to facilitate different kinds of backends (SQL, ElasticSearch,...).

The returned Operation instances usually hold metadata, such as Entities, or [Leaflet](http://rubygems.org/gems/leaflet) Collections of Entties. They never expose Backend instances, however.

By default, perimeter looks for the persistence backend class in [REPOSITORY]::Backend, e.g. `Products::Backend`. If you change the location, you can specify it manually. Likewise, the Entity is derived from the singular name of the repository by default and can be overriden.

```ruby
module Products
  entity_class MyPersonalEntity
  backend_class SomeWhereElse::MyCustomBackend
end
```

Because it is so common, there is an [ActiveRecord adapter](https://github.com/bukowskis/perimeter/tree/master/lib/perimeter/repository/adapters) included which you can kickstart your repository with:

```ruby
require 'perimeter/repository/adapters/active_record'

module UserTags
  include Perimeter::Repository::Adapters::ActiveRecord
end
```

## Backend

The persistence backend is tucked away in a directory and may look like the following code. You are not supposed to interact with the backend at all in your code.

```ruby
module Products
  class Backend < ActiveRecord::Base
  end
end
```

Again there is an adapter which does some initial configuration for you, such as specifying the custom table name of the class. Note that you need to specify the backend classes of associations manually:

```ruby
require 'perimeter/backend/adapters/active_record'

module Products
  class Backend < ActiveRecord::Base

    include Perimeter::Backend::Adapters::ActiveRecord

    has_many :tags, dependent: :destroy, class_name: '::Tags::Backend', foreign_key: 'tag_id'
  end
end
```

# License

See `MIT-LICENSE` for details.
