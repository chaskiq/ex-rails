defmodule ActiveStorage.Attached.Changes.DeleteMany do
  defstruct [:name, :record]
  # attr_reader :name, :record

  def new(name, record) do
    %__MODULE__{name: name, record: record}
    # @name, @record = name, record
  end

  def attachables do
    []
  end

  def attachments do
    []
    # ActiveStorage.Attachment.none
  end

  def blobs do
    []
    # ActiveStorage.Blob.none
  end

  def save do
    # record.public_send("#{name}_attachments=", [])
  end
end
