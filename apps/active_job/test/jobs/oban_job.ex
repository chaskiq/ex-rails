# frozen_string_literal: true

defmodule ActiveJob.ObanJob do
  use ActiveJob.Base,
    queue_adapter: ActiveJob.QueueAdapters.ObanAdapter

  def perform(args) do
    IO.inspect("GREAT THE OBAN JOB WAS PERFORMED!!!!!!")
    IO.inspect(args)
    JobBuffer.push(:job_buffer, "#{args["a"]} says hello #{args["b"]} times")
  end
end
