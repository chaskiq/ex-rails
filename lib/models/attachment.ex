defmodule ActiveStorage.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  alias ActiveStorage.Blob

  schema "active_storage_attachments" do
    field(:name, :string, null: false)
    field(:record_type, :string, null: false)
    field(:record_id, :integer, null: false)

    belongs_to(:blob, Blob)

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  # belongs_to :record, polymorphic: true, touch: true
  # belongs_to :blob, class_name: "ActiveStorage::Blob", autosave: true

  # delegate_missing_to :blob
  # delegate :signed_id, to: :blob

  # after_create_commit :mirror_blob_later, :analyze_blob_later
  # after_destroy_commit :purge_dependent_blob_later

  # scope :with_all_variant_records, -> { includes(blob: :variant_records) }

  # Synchronously deletes the attachment and {purges the blob}[rdoc-ref:ActiveStorage::Blob#purge].
  def purge do
    # transaction do
    #  delete
    #  record.touch if record&.persisted?
    # end
    # blob&.purge
  end

  # Deletes the attachment and {enqueues a background job}[rdoc-ref:ActiveStorage::Blob#purge_later] to purge the blob.
  def purge_later do
    # transaction do
    #   delete
    #   record.touch if record&.persisted?
    # end
    # blob&.purge_later
  end

  # Returns an ActiveStorage::Variant or ActiveStorage::VariantWithRecord
  # instance for the attachment with the set of +transformations+ provided.
  # See ActiveStorage::Blob::Representable#variant for more information.
  #
  # Raises an +ArgumentError+ if +transformations+ is a +Symbol+ which is an
  # unknown pre-defined variant of the attachment.
  def variant(transformations) do
    # case transformations
    # when Symbol
    #  variant_name = transformations
    #  transformations = variants.fetch(variant_name) do
    #    record_model_name = record.to_model.model_name.name
    #    raise ArgumentError, "Cannot find variant :#{variant_name} for #{record_model_name}##{name}"
    #  end
    # end

    # blob.variant(transformations)
  end

  @doc false
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [
      :name,
      :record_type,
      :record_id,
      :created_at
    ])
    |> cast_assoc(:blob)
    |> validate_required([
      :name,
      :record_type,
      :record_id,
      :created_at
    ])
    |> assoc_constraint(:blob)
  end

  def new(record: record, name: name, blob: blob) do
    %__MODULE__{
      record_id: record.id,
      record_type: record.__struct__ |> to_string,
      blob_id: blob.id,
      name: name
    }
  end

  def analyze_blob_later(attachment) do
    # blob.analyze_later unless blob.analyzed?
  end

  def mirror_blob_later(attachment) do
    # blob.mirror_later
  end

  def purge_dependent_blob_later(attachment) do
    # blob&.purge_later if dependent == :purge_later
  end

  def dependent(attachment) do
    # record.attachment_reflections[name]&.options&.fetch(:dependent, nil)
  end

  def variants(attachment) do
    # record.attachment_reflections[name]&.variants
  end
end
