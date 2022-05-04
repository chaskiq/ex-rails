# frozen_string_literal: true

defmodule ActiveJob.HelloJob do
  use ActiveJob.Base,
    queue_adapter: :inline,
    queue_as: :aaa,
    callbacks: %{
      before: fn x -> IO.inspect("BEFORE") end,
      after: fn x -> IO.inspect("AFTER") end
    }

  def perform(greeter) do
    greeter = case greeter do
      nil -> "David"
      _ -> greeter
    end
    IO.inspect("GREAT THE JOB HAS PERFORMED!")
    JobBuffer.push(:job_buffer, "#{greeter} says hello")
  end
end
