# shotrize

[Shotrize](https://hex.pm/packages/shotrize) is a API / REST API / Web page easy render framework (like a vanilla PHP) that doesn't require MVC and router

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

Custom the templates/api, or templates/api/rest, or templates/page in your Phoenix PJ.

## License

This project is licensed under the terms of the Apache 2.0 license, see LICENSE.
