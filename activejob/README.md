# ActiveJob

**WIP**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `activejob` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:activejob, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/activejob](https://hexdocs.pm/activejob).


### Preliminar API

### With oban:

```elixir
defmodule ActiveJob.ObanJob do
  use ActiveJob.Base,
    queue_adapter: ActiveJob.QueueAdapters.ObanAdapter

  def perform(args) do
    IO.inspect("GREAT THE OBAN JOB WAS PERFORMED!!!!!!")
    IO.inspect(args)
  end
end
```

### With inline, for testing:

```elixir
defmodule ActiveJob.HelloJob do
  use ActiveJob.Base,
    queue_adapter: :inline,

  def perform(greeter) do
    IO.inspect("GREAT THE JOB HAS PERFORMED!")
  end
end
```

### Other options for enqueueing

```elixir
  use ActiveJob.Base,
    queue_adapter: :inline,
    queue_as: :aaa,
    callbacks: %{
      before: fn x -> IO.inspect("BEFORE") end,
      after: fn x -> IO.inspect("AFTER") end
    }
```



