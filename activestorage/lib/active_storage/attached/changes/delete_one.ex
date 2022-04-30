defmodule ActiveStorage.Attached.Changes.DeleteOne do
  defstruct [:name, :record]
  # attr_reader :name, :record

  def new(name, record) do
    %__MODULE__{name: name, record: record}
    # @name, @record = name, record
  end

  # attr_reader :name, :record
  #
  # def initialize(name, record)
  #  @name, @record = name, record
  # end
  #
  def attachment do
    nil
  end

  #
  def save do
    # record.public_send("#{name}_attachment=", nil)
  end
end
