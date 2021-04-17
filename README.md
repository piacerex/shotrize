# shotrize

[Shotrize](https://hex.pm/packages/shotrize) is a  Web page/API/REST API easy renderer without MVC and router in Phoenix (it's just like PHP).

## Installation

Add to your ```mix.exs``` file:

```elixir
def deps do
  [
    {:shotrize ,git: "https://github.com/piacerex/shotrize.git", branch: "v1.0"}
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
