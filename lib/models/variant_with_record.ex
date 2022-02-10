# frozen_string_literal: true

defmodule ActiveStorage.VariantWithRecord do
  # attr_reader :blob, :variation

  # alias __MODULE__
  defstruct [:blob, :variation, :record]

  def new(blob, variation) do
    %__MODULE__{
      blob: blob,
      variation: ActiveStorage.Variation.wrap(variation)
    }

    # blob, variation = blob, ActiveStorage::Variation.wrap(variation)
  end

  def processed(instance) do
    instance = instance.process()
    instance |> record()
  end

  def process(_instance) do
    # transform_blob { |image| create_or_find_record(image: image) } unless processed?
  end

  def processed?(instance) do
    case record(instance) do
      nil -> false
      _ -> true
    end
  end

  def image(instance) do
    case instance.record do
      nil -> nil
      %{image: image} -> image
    end
  end

  def key(instance) do
    img = instance |> image()
    img.key
  end

  def url(instance) do
    img = instance |> image()
    img.url
  end

  # delegate :key, :url, :download, to: :image, allow_nil: true

  # alias_method :service_url, :url
  # deprecate service_url: :url

  # private
  #  def transform_blob
  #    blob.open do |input|
  #      variation.transform(input) do |output|
  #        yield io: output, filename: "#{blob.filename.base}.#{variation.format.downcase}",
  #          content_type: variation.content_type, service_name: blob.service.name
  #      end
  #    end
  #  end

  #  def create_or_find_record(image:)
  #    @record =
  #      ActiveRecord::Base.connected_to(role: ActiveRecord::Base.writing_role) do
  #        blob.variant_records.create_or_find_by!(variation_digest: variation.digest) do |record|
  #          record.image.attach(image)
  #        end
  #      end
  #  end

  def record(instance) do
    case instance.record do
      nil ->
        require IEx
        IEx.pry()
        true

      # instance.blob.variant_records.find_by(variation_digest: variation.digest)
      r ->
        r
    end
  end
end
