defmodule ActiveStorage.Attached.Changes.DetachOne do
  defstruct [:name, :record, :attachment]

  def new(name, record, attachment) do
    %__MODULE__{
      name: name,
      record: record,
      attachment: attachment
    }
  end

  def detach(instance) do
    if instance.attachment do
      # attachment.delete
      reset(instance)
    end
  end

  def reset(instance) do
    # record.attachment_changes.delete(name)
    # record.public_send("#{name}_attachment=", nil)
  end

  #  attr_reader :name, :record, :attachment
  #
  #  def initialize(name, record, attachment)
  #    @name, @record, @attachment = name, record, attachment
  #  end
  #
  #  def detach
  #    if attachment.present?
  #      attachment.delete
  #      reset
  #    end
  #  end
  #
  #  private
  #    def reset
  #      record.attachment_changes.delete(name)
  #      record.public_send("#{name}_attachment=", nil)
  #    end
end
