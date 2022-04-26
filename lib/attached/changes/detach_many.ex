defmodule ActiveStorage.Attached.Changes.DetachMany do
  defstruct [:name, :record, :attachments]
  #  attr_reader :name, :record, :attachments
  #
  def new(name, record, attachments) do
    %__MODULE__{
      name: name,
      record: record,
      attachments: attachments
    }
  end

  def detach(instance) do
    if instance.attachments |> Enum.any?() do
      #      attachments.delete_all if attachments.respond_to?(:delete_all)
      #      record.attachment_changes.delete(name)
    end
  end

  #  def initialize(name, record, attachments)
  #    @name, @record, @attachments = name, record, attachments
  #  end
  #
  #  def detach
  #    if attachments.any?
  #      attachments.delete_all if attachments.respond_to?(:delete_all)
  #      record.attachment_changes.delete(name)
  #    end
  #  end
end
