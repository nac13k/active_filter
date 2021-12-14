# ActiveFilter
Short description and motivation.

## Usage
How to use my plugin.

In the desire model you declare a class method
This will filter the model.
class Group

    def self.filter_params
        {
            id: :id
            (association)
            country_ids: 'countries.id'
        }
    end

    to use the search method you declare another class method
    in this case you have to use declare the model first and then the attribute.

    def self.search_params
        {
            name: 'group.name'
            country_name: 'countries.name'
        }
    end
end

to use the filter method you use the next method and to use the search params you only have to
pass a single param with the attribute being :text.

    Group.filter_af(params)

    params = {
        id: 1,
        country_ids: [1,3,4],
        text: "example"
    }


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'active_filter'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install active_filter
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
