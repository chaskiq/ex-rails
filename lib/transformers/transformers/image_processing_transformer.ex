# frozen_string_literal: true

# begin
#   require "image_processing"
# rescue LoadError
#   raise LoadError, <<~ERROR.squish
#     Generating image variants require the image_processing gem.
#     Please add `gem 'image_processing', '~> 1.2'` to your Gemfile.
#   ERROR
# end

defmodule ActiveStorage.Transformers.ImageProcessingTransformer do
  import Mogrify
  alias __MODULE__

  defstruct [:transformations]
  # A Transformer applies a set of transformations to an image.
  #
  # The following concrete subclasses are included in Active Storage:
  #
  # * ActiveStorage::Transformers::ImageProcessingTransformer:
  #   backed by ImageProcessing, a common interface for MiniMagick and ruby-vips
  # attr_reader :transformations

  def new(transformations) do
    %__MODULE__{transformations: transformations}
  end

  def process(transformer, file, %{format: format}, block \\ nil) do
    # image = open(file) |> resize("100x100") |> save

    _image =
      open(file)
      |> format(format)
      |> operations(transformer.transformations)
      |> save

    # processor.
    #   source(file).
    #   loader(page: 0).
    #   convert(format).
    #   apply(operations).
    #   call
  end

  def processor do
    # ImageProcessing.const_get(ActiveStorage.variant_processor.to_s.camelize)
  end

  def operations(file, transformer) do
    transformer
    |> Enum.reduce(file, fn {key, value}, acc ->
      acc |> add_operation(key, value)
    end)

    # transformations.each_with_object([]) do |(name, argument), list|
    #   if name.to_s == "combine_options"
    #     raise ArgumentError, <<~ERROR.squish
    #       Active Storage's ImageProcessing transformer doesn't support :combine_options,
    #       as it always generates a single ImageMagick command.
    #     ERROR
    #   end

    #   if argument.present?
    #     list << [ name, argument ]
    #   end
    # end
  end

  def add_operation(file, operation, value) do
    case operation do
      :resize_to_fill ->
        file |> resize_to_fill(value)

      :resize_to_limit ->
        file |> resize_to_limit(value)

      :gravity ->
        file |> gravity(value)

      :extent ->
        file |> extent(value)

      _ ->
        file |> custom(operation, value)
    end
  end
end
