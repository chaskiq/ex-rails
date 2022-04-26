# frozen_string_literal: true

defmodule ActiveStorage.Attached.Many do
  defstruct [:name, :record]

  # ATTACHABLE
  def new(name, record) do
    %__MODULE__{name: name, record: record}
  end

  def change do
    # record.attachment_changes[name]
  end

  # Decorated proxy object representing of multiple attachments to a model.
  ##
  # :method: purge
  #
  # Directly purges each associated attachment (i.e. destroys the blobs and
  # attachments and deletes the files on the service).
  # delegate :purge, to: :purge_many
  defdelegate purge(blob), to: __MODULE__, as: :purge_many

  ##
  # :method: purge_later
  #
  # Purges each associated attachment through the queuing system.
  # delegate :purge_later, to: :purge_many
  defdelegate purge_later(blob), to: __MODULE__, as: :purge_many

  ##
  # :method: detach
  #
  # Deletes associated attachments without purging them, leaving their respective blobs in place.
  # delegate :detach, to: :detach_many
  defdelegate detach(blob), to: __MODULE__, as: :detach_many

  # delegate_missing_to :attachments

  # Returns all the associated attachment records.
  #
  # All methods called on this proxy object that aren't listed here will automatically be delegated to +attachments+.
  def attachments do
    # change.present? ? change.attachments : record.public_send("#{name}_attachments")
  end

  # Returns all attached blobs.
  def blobs do
    # change.present? ? change.blobs : record.public_send("#{name}_blobs")
  end

  # Attaches one or more +attachables+ to the record.
  #
  # If the record is persisted and unchanged, the attachments are saved to
  # the database immediately. Otherwise, they'll be saved to the DB when the
  # record is next saved.
  #
  #   document.images.attach(params[:images]) # Array of ActionDispatch::Http::UploadedFile objects
  #   document.images.attach(params[:signed_blob_id]) # Signed reference to blob from direct upload
  #   document.images.attach(io: File.open("/path/to/racecar.jpg"), filename: "racecar.jpg", content_type: "image/jpeg")
  #   document.images.attach([ first_blob, second_blob ])
  def attach(attachables) do
    # if record.persisted? && !record.changed?
    #   record.public_send("#{name}=", blobs + attachables.flatten)
    #   if record.save
    #     record.public_send("#{name}")
    #   else
    #     false
    #   end
    # else
    #   record.public_send("#{name}=", (change&.attachables || blobs) + attachables.flatten)
    # end
  end

  # Returns true if any attachments have been made.
  #
  #   class Gallery < ApplicationRecord
  #     has_many_attached :photos
  #   end
  #
  #   Gallery.new.photos.attached? # => false
  def attached? do
    # attachments.any?
  end

  defp purge_many do
    # Attached::Changes::PurgeMany.new(name, record, attachments)
  end

  defp detach_many do
    # Attached::Changes::DetachMany.new(name, record, attachments)
  end
end
