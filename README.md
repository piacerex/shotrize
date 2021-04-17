# shotrize

[Shotrize](https://hex.pm/packages/shotrize) is a  Web page/API/REST API generator without MVC and router in Phoenix (it's just like PHP).

## Installation

Add to your ```mix.exs``` file:

```elixir
def deps do
  [
    {:shotrize, "~> 0.1"}
  ]
end
```

Run below:

```
mix deps.get
mix shotrize.apply
```

Custom the templates/page, 
templates/api, and templates/api/rest.

## License

This project is licensed under the terms of the Apache 2.0 license, see LICENSE.
