# frozen_string_literal: true

defmodule JobBuffer2 do
  def clear do
    # values.clear
  end

  def add(value) do
    # values << value
  end

  def values do
    # @values ||= []
  end

  def last_value do
    # values.last
  end
end

defmodule JobBuffer do
  use GenServer

  def init(args) do
    #IO.inspect("inicio")
    #IO.inspect(args)
    {:ok, []}
  end

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [])
  end

  def size(pid) do
    GenServer.call(pid, :size)
  end

  def push(pid, item) do
    GenServer.cast(pid, {:push, item})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  def values(pid) do
    GenServer.call(pid, :list)
  end

  def last_value(pid) do
    GenServer.call(pid, :last_value)
  end

  ####
  # Genserver implementation
  def handle_call(:size, _from, stack) do
    {:reply, Enum.count(stack), stack}
  end

  def handle_call(:list, _from, stack) do
    {:reply, stack, stack}
  end

  def handle_cast({:push, item}, stack) do
    {:noreply, [item | stack]}
  end

  def handle_call(:pop, _from, [item | rest]) do
    {:reply, item, rest}
  end

  def handle_call(:last_value, _from, stack) do
    {:reply, stack |> List.last(), stack}
  end

  def handle_call(:clear, _from, stack) do
    {:reply, [], []}
  end
end
