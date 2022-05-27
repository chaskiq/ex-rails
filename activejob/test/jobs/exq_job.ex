# frozen_string_literal: true

defmodule ActiveJob.ExqJob do
  use ActiveJob.Base,
    queue_adapter: :exq,
    queue_as: :aaa,
    callbacks: %{
      before: fn _x -> IO.inspect("BEFORE") end,
      after: fn _x -> IO.inspect("AFTER") end
    }

  def perform(args) do
    IO.inspect("GREAT THE Exq JOB WAS PERFORMED!!!!!!")
    IO.inspect(args)
    str = "#{args["a"]} says hello #{args["b"]} times"

    JobBuffer.push(:job_buffer, str)
  end
end
