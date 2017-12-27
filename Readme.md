# Reflective Refactoring Challenge Solution

# NOTE::
- I haven't tried to change the database schema.
- Just tried to refactor the code provided.

# Coding best practises::
- Usually controllers should be skinny.
- All the business logic should stay at models.
- Code should be modular.
- Methods should not be spreaded across large amount of lines.

#### Now if we look at best practises, here's how we can refactor the orders controller:

- I have tried to make order controller's create method as skinny as possible.
- Tried to make the code more object oriented. In a way it can be helpful in maintenance and further developements.
- Divided the functionality into respective classes.

# Other class associations can be defined as following::

    class Cart < ActiveRecord::Base
      has_many :ordered_items
      has_many :products, through: :ordered_items
    end
    

    class OrderedItem < ActiveRecord::Base
      belongs_to :cart
      belongs_to :product
      belongs_to :order
    end
    

    class Product < ActiveRecord::Base
      has_many :ordered_items
      has_many :carts, through: :ordered_items
    end