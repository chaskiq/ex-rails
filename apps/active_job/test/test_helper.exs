alias ActiveJob.Test.Repo

Oban.Application.start([], [])

ExUnit.start(timeout: 100_000_000)

# {:ok, _pid} = Repo.start_link()
