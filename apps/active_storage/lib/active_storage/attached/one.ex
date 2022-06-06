# frozen_string_literal: true

defmodule ActiveStorage.Attached.One do
  defstruct [:name, :record]

  # ATTACHABLE
  def new(name, record) do
    %__MODULE__{name: name, record: record}
  end

  def change(instance) do
    # record.attachment_changes[name]
  end

  # Representation of a single attachment to a model.

  # :method: purge
  #
  # Directly purges the attachment (i.e. destroys the blob and
  # attachment and deletes the file on the service).

  # delegate :purge, to: :purge_one

  # :method: purge_later
  #
  # Purges the attachment through the queuing system.

  # delegate :purge_later, to: :purge_one

  # :method: detach
  #
  # Deletes the attachment without purging it, leaving its blob in place.

  # delegate :detach, to: :detach_one

  # delegate_missing_to :attachment, allow_nil: true

  # Returns the associated attachment record.
  #
  # You don't have to call this method to access the attachment's methods as
  # they are all available at the model level.
  def attachment(instance) do
    # change.present? ? change.attachment : record.public_send("#{name}_attachment")
  end

  # Returns +true+ if an attachment is not attached.
  #
  #   class User < ApplicationRecord
  #     has_one_attached :avatar
  #   end
  #
  #   User.new.avatar.blank? # => true
  def blank?(instance) do
    attached?(instance) != true
    # !attached?
  end

  # Attaches an +attachable+ to the record.
  #
  # If the record is persisted and unchanged, the attachment is saved to
  # the database immediately. Otherwise, it'll be saved to the DB when the
  # record is next saved.
  #
  #   person.avatar.attach(params[:avatar]) # ActionDispatch::Http::UploadedFile object
  #   person.avatar.attach(params[:signed_blob_id]) # Signed reference to blob from direct upload
  #   person.avatar.attach(io: File.open("/path/to/face.jpg"), filename: "face.jpg", content_type: "image/jpeg")
  #   person.avatar.attach(avatar_blob) # ActiveStorage::Blob object
  def attach(instance, attachable) do
    aname = :"assign_#{instance.name}"

    case Ecto.get_meta(instance.record, :state) do
      :loaded ->
        IO.inspect("TODO: save here a loaded state")
        a = apply(instance.record.__struct__, aname, [instance.record, attachable])
        a |> instance.record.__struct__.save_with_attachment(instance.name)

      :built ->
        apply(instance.record.__struct__, aname, [instance.record, attachable])
    end

    # if record.persisted? && !record.changed?
    #   record.public_send("#{name}=", attachable)
    #   record.save
    # else
    #   record.public_send("#{name}=", attachable)
    # end
  end

  # Returns +true+ if an attachment has been made.
  #
  #   class User < ApplicationRecord
  #     has_one_attached :avatar
  #   end
  #
  #   User.new.avatar.attached? # => false
  def attached?(instance) do
    attachment(instance) |> is_nil() != true
    # attachment.present?
  end

  def purge_one(instance) do
    Attached.Changes.PurgeOne.new(instance.name, instance.record, attachment(instance))
  end

  def detach_one(instance) do
    Attached.Changes.DetachOne.new(instance.name, instance.record, attachment(instance))
  end
end
