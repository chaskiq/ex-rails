# frozen_string_literal: true

# require "mini_mime"

# A set of transformations that can be applied to a blob to create a variant. This class is exposed via
# the ActiveStorage::Blob#variant method and should rarely be used directly.
#
# In case you do need to use this directly, it's instantiated using a hash of transformations where
# the key is the command and the value is the arguments. Example:
#
#   ActiveStorage::Variation.new(resize_to_limit: [100, 100], monochrome: true, trim: true, rotate: "-90")
#
# The options map directly to {ImageProcessing}[https://github.com/janko-m/image_processing] commands.
defmodule ActiveStorage.Variation do
  # <- this is the magic
  # alias __MODULE__
  @derive Jason.Encoder

  defstruct [:transformations]
  # attr_reader :transformations
  # Returns a Variation instance based on the given variator. If the variator is a Variation, it is
  # returned unmodified. If it is a String, it is passed to ActiveStorage::Variation.decode. Otherwise,
  # it is assumed to be a transformations Hash and is passed directly to the constructor.
  def wrap(variator) do
    case variator do
      %ActiveStorage.Variation{} ->
        variator

      any ->
        cond do
          any |> is_binary() -> any |> __MODULE__.decode()
          true -> %ActiveStorage.Variation{transformations: variator}
        end
    end

    # case variator do
    # when self
    #   variator
    # when String
    #   decode variator
    # else
    #   new variator
    # end
  end

  # Returns a Variation instance with the transformations that were encoded by +encode+.
  def decode(key) do
    # , purpose: :variation)
    {:ok, decoded} = ActiveStorage.verifier().verify(key)
    Jason.decode!(decoded)
    # new ActiveStorage.verifier.verify(key, purpose: :variation)
  end

  # Returns a signed key for the +transformations+, which can be used to refer to a specific
  # variation in a URL or combined key (like <tt>ActiveStorage::Variant#key</tt>).
  def encode(transformations) do
    ActiveStorage.verifier().sign(Jason.encode!(transformations))
    # ActiveStorage.verifier.generate(transformations, purpose: :variation)
  end

  def new(transformations) do
    %__MODULE__{transformations: transformations}
    # @transformations = transformations.deep_symbolize_keys
  end

  def default_to(struct, defaults) do
    new(defaults |> Map.merge(struct.transformations))
    # self.class.new transformations.reverse_merge(defaults)
  end

  # Accepts a File object, performs the +transformations+ against it, and
  # saves the transformed image into a temporary file.
  def transform(variation, file, block) do
    ActiveStorage.Metrics.instrument(
      [:transform, :active_storage],
      %{},
      fn ->
        t = transformer(variation)

        t.__struct__.process(
          t,
          file,
          %{
            format: variation.transformations.format
          },
          block
        )
      end
    )

    # ActiveSupport::Notifications.instrument("transform.active_storage") do
    #  transformer.transform(file, format: format, &block)
    # end
  end

  def format(variation) do
    # TODO: validate extension
    extension =
      case variation.transformations |> Map.fetch(:format) do
        {:ok, format} -> format
        _ -> "png"
      end

    if MIME.has_type?(extension) do
      extension
    else
      raise ArgumentError
    end

    # transformations.fetch(:format, :png).tap do |format|
    #  if MiniMime.lookup_by_extension(format.to_s).nil?
    #    raise ArgumentError, "Invalid variant format (#{format.inspect})"
    #  end
    # end
  end

  def content_type(variation) do
    MIME.type(format(variation))
    # MiniMime.lookup_by_extension(format.to_s).content_type
  end

  # Returns a signed key for all the +transformations+ that this variation was instantiated with.
  def key(struct) do
    encode(struct.transformations)
    # self.class.encode(transformations)
  end

  def digest(variation) do
    require IEx
    IEx.pry()
    # Digest::SHA1.base64digest Marshal.dump(transformations)
  end

  defp transformer(struct) do
    # struct.transformations.except(:format)
    ActiveStorage.Transformers.ImageProcessingTransformer.new(
      struct.transformations
      |> Map.delete(:format)
    )
  end
end
