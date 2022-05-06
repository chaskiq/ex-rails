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

### Execute Job async

    ObanJob.perform_later(%{a: "David", b: 2})
### Execute inline

    ObanJob.perform_now(%{a: "David", b: 2})

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

### executing:

    ObanJob.perform_later(%{a: "David", b: 2})

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




### Existing Queue libraries in Elixir

* [rihanna](https://github.com/samphilipd/rihanna) - PostgreSQL storage, uses advisory locks
* [exq](https://github.com/akira/exq) - Redis backed, compatible with Sidekiq format - I like the ["do you need exq?" section](https://github.com/akira/exq#do-you-need-exq)
* [verk](https://github.com/edgurgel/verk) - Redis based as well,  also supports sidekiq format
* [que](https://github.com/sheharyarn/que) - backed by Mnesia which is a database builtin to erlang/otp so no extra infrastructure
* [toniq](https://github.com/joakimk/toniq) - uses redis, hasn't seen an update in over a year
* [honeydew](https://github.com/koudelka/honeydew) - pluggable storage, featuring in memory, Mnesia and ecto queues.
* [ecto_job](https://github.com/mbuhot/ecto_job) - backed by PostgreSQL, focussed on transactional behaviour, uses `pg_notify` so doesn't do any database polling afaik (might be true for others here I just know this)
* [kiq](https://github.com/sorentwo/kiq) - a rather new library, also redis backed and aiming at sidekiq compatibility, it was under heavy development around the jump of the year
* [faktory_worker_ex](https://github.com/cjbottaro/faktory_worker_ex) - a worker for Mike Perham's new more server based system [faktory](https://contribsys.com/faktory/) - woud especially be interested in opinions/experiences here.
* [gen_queue](https://github.com/nsweeting/gen_queue) - a generic interface to different queue systems mentioned above and others for flexibility