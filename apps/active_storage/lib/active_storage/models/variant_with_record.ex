defmodule ActiveStorage.VariantWithRecord do
  import Ecto.Query, warn: false

  defstruct [:blob, :variation, :record]

  def new(blob, variation) do
    %__MODULE__{
      blob: blob,
      variation: ActiveStorage.Variation.wrap(variation)
    }

    # blob, variation = blob, ActiveStorage::Variation.wrap(variation)
  end

  def processed(instance) do
    instance = process(instance)
    instance |> record()
  end

  def process(instance) do
    if !processed?(instance) do
      a = transform_blob(instance)
      create_or_find_record(instance, a)
    end

    # transform_blob { |image| create_or_find_record(image: image) } unless processed?
  end

  def processed?(instance) do
    case record(instance) do
      nil -> false
      _ -> true
    end
  end

  def image(instance) do
    record = __MODULE__.record(instance)

    case record do
      nil -> nil
      %{image: image} -> image
    end
  end

  def key(instance) do
    img = image(instance)
    img.key
  end

  def url(instance) do
    img = image(instance)
    img.url
  end

  # delegate :key, :url, :download, to: :image, allow_nil: true

  # alias_method :service_url, :url
  # deprecate service_url: :url

  def transform_blob(instance) do
    ActiveStorage.Blob.open(instance.blob,
      block: fn input ->
        ActiveStorage.Variation.transform(instance.variation, input, fn output ->
          basename = Path.rootname(instance.blob.filename)
          format = ActiveStorage.Variation.format(instance.variation) |> String.downcase()
          [io: output, filename: "#{basename}.#{format}"]
        end)
      end
    )
  end

  # private
  #  def transform_blob
  #    blob.open do |input|
  #      variation.transform(input) do |output|
  #        yield io: output, filename: "#{blob.filename.base}.#{variation.format.downcase}",
  #          content_type: variation.content_type, service_name: blob.service.name
  #      end
  #    end
  #  end

  def create_or_find_record(instance, image) do
    record =
      case find_variant_record(instance) do
        nil ->
          digest = ActiveStorage.Variation.digest(instance.variation)

          struct = %ActiveStorage.VariantRecord{
            variation_digest: digest,
            blob_id: instance.blob.id
          }

          one = struct.__struct__.image(struct)
          a = one.__struct__.attach(one, image)

          {:ok, new_blob} =
            a.attachment_changes.image.blob
            |> ActiveStorage.RepoClient.repo().insert

          {:ok, record} =
            a.attachment_changes.image.record
            |> ActiveStorage.RepoClient.repo().insert

          {:ok, record} =
            record
            |> Ecto.build_assoc(:image_attachment)
            |> Ecto.Changeset.change(%{
              name: "image",
              record_type: "ActiveStorage.VariantRecord",
              blob: new_blob
            })
            |> ActiveStorage.RepoClient.repo().insert

          create_one = a.attachment_changes.image

          %ActiveStorage.Attached.Changes.CreateOne{
            create_one
            | blob: new_blob,
              attachment: record
          }
          |> ActiveStorage.Attached.Changes.CreateOne.upload(image)

          # record = record |> ActiveStorage.RepoClient.repo().preload(:blob)

          record

        record ->
          record
      end

    instance |> Map.merge(%{record: record})
  end

  #  def create_or_find_record(image:)
  #    @record =
  #      ActiveRecord::Base.connected_to(role: ActiveRecord::Base.writing_role) do
  #        blob.variant_records.create_or_find_by!(variation_digest: variation.digest) do |record|
  #          record.image.attach(image)
  #        end
  #      end
  #  end

  def find_variant_record(instance) do
    digest = ActiveStorage.Variation.digest(instance.variation)

    instance.blob
    |> Ecto.assoc(:variant_records)
    |> where([c], c.variation_digest == ^digest)
    |> limit(1)
    |> ActiveStorage.RepoClient.repo().one
  end

  def record(instance) do
    case instance.record do
      nil ->
        find_variant_record(instance)

      # instance.blob.variant_records.find_by(variation_digest: variation.digest)
      record ->
        record
    end
  end
end
