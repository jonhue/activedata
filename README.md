# Active Data

Object-Relational-Mapping in Rails with consistent JSON data.

## Installation

1. Bundle the gem.
2. Run the generator: `rails g active_data`

## Philosophy

Active Data aims to implement the same functionality as Active Record without using a database as datastore. Instead it utilizes a JSON file. You can use Active Data alongside with Active Record to create models in your Rails application. Features include:

* Common methods (`self.all`, `self.create`, `self.where`, `self.find_by`, `self.find`, `save`, `update`, `update_attributes`, `update_attribute`, `destroy`, `destroyed?`)
* Callbacks (`before_validation`, `after_validation`, `before_save`, `after_save`, `before_create`, `after_create`, `before_update`, `after_update`, `before_destroy`, `after_destroy`)
* Associations (`has_many`, `belongs_to` - also with Active Record models)
* All functionality provided by the `ActiveModel::Model` class (e.g.: validations)

## Usage

```ruby
class Example < ApplicationData
  active_data(
    file_name: 'example_data', # uses /data/example_data.json; if omitted would use /data/example.json
    json_scope: lambda { |data| data[:examples] }, # if omitted would use data, result has to return a JSON array
    permit_attributes: [:foo, :bar], # should only contain attribute names that have getter and setter methods
    explicit_ids: true # if false, does not store id's of instances in JSON
  )

  attr_accessor :foo, :bar
end
```
