# frozen_string_literal: true

defmodule ActiveStorage.Transformers.Transformer do
  # A Transformer applies a set of transformations to an image.
  #
  # The following concrete subclasses are included in Active Storage:
  #
  # * ActiveStorage::Transformers::ImageProcessingTransformer:
  #   backed by ImageProcessing, a common interface for MiniMagick and ruby-vips
  # attr_reader :transformations

  # Applies the transformations to the source image in +file+, producing a target image in the
  # specified +format+. Yields an open Tempfile containing the target image. Closes and unlinks
  # the output tempfile after yielding to the given block. Returns the result of the block.
  def transform(file, %{format: format}) do
    # output = process(file, format: format)

    # begin
    #   yield output
    # ensure
    #   output.close!
    # end
  end

  # Returns an open Tempfile containing a transformed image in the given +format+.
  # All subclasses implement this method.
  # :doc:
  defp process(file, %{format: format}) do
    # raise NotImplementedError
  end
end
