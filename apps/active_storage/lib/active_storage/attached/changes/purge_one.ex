defmodule ActiveStorage.Attached.Changes.PurgeOne do
  defstruct [:name, :record, :attachment]

  def new(name, record, attachment) do
    %__MODULE__{
      name: name,
      record: record,
      attachment: attachment
    }
  end

  def purge(instance) do
    # instance.attachment.purge
    reset(instance)
  end

  def purge_later(instance) do
    # instance.attachment&.purge_later
    reset(instance)
  end

  def reset(_instance) do
    # record.attachment_changes.delete(name)
    # record.public_send("#{name}_attachment=", nil)
  end

  # attr_reader :name, :record, :attachment

  # def initialize(name, record, attachment)
  #   @name, @record, @attachment = name, record, attachment
  # end

  # def purge
  #   attachment&.purge
  #   reset
  # end

  # def purge_later
  #   attachment&.purge_later
  #   reset
  # end

  # private
  #   def reset
  #     record.attachment_changes.delete(name)
  #     record.public_send("#{name}_attachment=", nil)
  #   end
end
