# frozen_string_literal: true

defmodule ActiveStorage.Attached.OneRails do
  # Representation of a single attachment to a model.
  # class Attached::One < Attached
  ##
  # :method: purge
  #
  # Directly purges the attachment (i.e. destroys the blob and
  # attachment and deletes the file on the service).

  # delegate :purge, to: :purge_one

  ##
  # :method: purge_later
  #
  # Purges the attachment through the queuing system.

  # delegate :purge_later, to: :purge_one

  ##
  # :method: detach
  #
  # Deletes the attachment without purging it, leaving its blob in place.

  # delegate :detach, to: :detach_one

  # delegate_missing_to :attachment, allow_nil: true

  # Returns the associated attachment record.
  #
  # You don't have to call this method to access the attachment's methods as
  # they are all available at the model level.
  def attachment do
    # change.present? ? change.attachment : record.public_send("#{name}_attachment")
  end

  # Returns +true+ if an attachment is not attached.
  #
  #   class User < ApplicationRecord
  #     has_one_attached :avatar
  #   end
  #
  #   User.new.avatar.blank? # => true
  def blank? do
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
  def attach(_instance, _attachable) do
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
  def attached?(_instance) do
    # attachment.present?
  end

  defp purge_one(_instance) do
    # Attached::Changes::PurgeOne.new(name, record, attachment)
  end

  defp detach_one(_instance) do
    # Attached::Changes::DetachOne.new(name, record, attachment)
  end
end

defmodule ActiveStorage.Attached.One do
  @moduledoc """
  The multies module
  """
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import ActiveStorage.Attached.One
      import Ecto.Query, warn: false
      import Ecto.Changeset
      alias Ecto.Multi

      def insert(%__MODULE__{} = resource, attrs) do
        IO.puts("FIND ME IN ActiveStorage.Attached.One")
        IO.inspect(attrs)
        # new_changeset(resource, attrs)
      end

      # def delete(%__MODULE__{position: position} = resource) do
      #   opts = unquote(opts)
      #   scope = Keyword.get(opts, :scope)

      #   update_position_query =
      #     if scope do
      #       from(i in __MODULE__,
      #         where: i.position > ^position and field(i, ^scope) == ^Map.get(resource, scope),
      #         update: [inc: [position: -1]]
      #       )
      #     else
      #       from(i in __MODULE__, where: i.position > ^position, update: [inc: [position: -1]])
      #     end

      #   Multi.new()
      #   |> Multi.delete(:delete_resource, resource)
      #   |> Multi.update_all(:update_position, update_position_query, [])
      # end
    end
  end
end
