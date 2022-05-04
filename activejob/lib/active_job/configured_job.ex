# frozen_string_literal: true

defmodule ActiveJob.ConfiguredJob do
  defstruct [:options, :job_class]

  def new(job_class, options \\ %{}) do
    %__MODULE__{
      options: options,
      job_class: job_class
    }

    # @options = options
    # @job_class = job_class
  end

  def perform_now(struct, args \\ nil) do
    require IEx; IEx.pry
    job = struct.job_class.new(args)
    job.__struct__.set(struct.options)
    require IEx; IEx.pry
    # @job_class.new(args).set(@options).perform_now
  end

  def perform_later(struct, args \\ nil) do
    job = struct.job_class.new(args)
    job.__struct__.enqueue(job, struct.options)
    # @job_class.new(...).enqueue @options
  end
end
