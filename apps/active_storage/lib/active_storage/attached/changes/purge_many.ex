# frozen_string_literal: true

defmodule ActiveStorage.Attached.Changes.PurgeMany do
  defstruct [:name, :record, :attachments]

  def new(name, record, attachments) do
    %__MODULE__{
      name: name,
      record: record,
      attachments: attachments
    }
  end

  def purge(instance) do
    instance.attachments |> Enum.each(fn x -> x.purge end)
    reset(instance)
  end

  def reset(instance) do
    # instance.record.attachment_changes.delete(name)
    # record.public_send("#{name}_attachments").reset
  end

  #  attr_reader :name, :record, :attachments
  #
  #  def initialize(name, record, attachments)
  #    @name, @record, @attachments = name, record, attachments
  #  end
  #
  #  def purge
  #    attachments.each(&:purge)
  #    reset
  #  end
  #
  #  def purge_later
  #    attachments.each(&:purge_later)
  #    reset
  #  end
  #
  #  private
  #    def reset
  #      record.attachment_changes.delete(name)
  #      record.public_send("#{name}_attachments").reset
  #    end
end
