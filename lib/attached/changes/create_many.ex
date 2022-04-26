defmodule ActiveStorage.Attached.Changes.CreateMany do
  # attr_reader :name, :record, :attachables

  defstruct [:name, :record, :attachables, :blobs]

  def initialize(name, record, attachables) do
    %__MODULE__{name: name, record: record, attachables: attachables}
    # @name, @record, @attachables = name, record, Array(attachables)
    # blobs.each(&:identify_without_saving)
    # attachments
  end

  def attachments(instance) do
    instance.attachments || subchanges(instance) |> Enum.map(fn x -> x.attachment end)
    # @attachments ||= subchanges.collect(&:attachment)
  end

  def blobs(instance) do
    instance.blobs || subchanges(instance) |> Enum.map(fn x -> x.blob end)
    # @blobs ||= subchanges.collect(&:blob)
  end

  def upload(instance) do
    subchanges(instance) |> Enum.each(fn x -> x.upload end)
  end

  def save do
    # assign_associated_attachments
    # reset_associated_blobs
  end

  def subchanges(instance) do
    # @subchanges ||= attachables.collect { |attachable| build_subchange_from(attachable) }
  end

  def build_subchange_from(instance, attachable) do
    ActiveStorage.Attached.Changes.CreateOneOfMany.new(
      instance.name,
      instance.record,
      instance.attachable
    )
  end

  def assign_associated_attachments(instance) do
    # record.public_send("#{name}_attachments=", persisted_or_new_attachments)
  end

  def reset_associated_blobs(instance) do
    # record.public_send("#{name}_blobs").reset
  end

  def persisted_or_new_attachments(instance) do
    # attachments.select { |attachment| attachment.persisted? || attachment.new_record? }
  end
end
