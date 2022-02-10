# frozen_string_literal: true

# Some non-image blobs can be previewed: that is, they can be presented as images. A video blob can be previewed by
# extracting its first frame, and a PDF blob can be previewed by extracting its first page.
#
# A previewer extracts a preview image from a blob. Active Storage provides previewers for videos and PDFs.
# ActiveStorage::Previewer::VideoPreviewer is used for videos whereas ActiveStorage::Previewer::PopplerPDFPreviewer
# and ActiveStorage::Previewer::MuPDFPreviewer are used for PDFs. Build custom previewers by
# subclassing ActiveStorage::Previewer and implementing the requisite methods. Consult the ActiveStorage::Previewer
# documentation for more details on what's required of previewers.
#
# To choose the previewer for a blob, Active Storage calls +accept?+ on each registered previewer in order. It uses the
# first previewer for which +accept?+ returns true when given the blob. In a Rails application, add or remove previewers
# by manipulating +Rails.application.config.active_storage.previewers+ in an initializer:
#
#   Rails.application.config.active_storage.previewers
#   # => [ ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer ]
#
#   # Add a custom previewer for Microsoft Office documents:
#   Rails.application.config.active_storage.previewers << DOCXPreviewer
#   # => [ ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer, DOCXPreviewer ]
#
# Outside of a Rails application, modify +ActiveStorage.previewers+ instead.
#
# The built-in previewers rely on third-party system libraries. Specifically, the built-in video previewer requires
# {FFmpeg}[https://www.ffmpeg.org]. Two PDF previewers are provided: one requires {Poppler}[https://poppler.freedesktop.org],
# and the other requires {muPDF}[https://mupdf.com] (version 1.8 or newer). To preview PDFs, install either Poppler or muPDF.
#
# These libraries are not provided by Rails. You must install them yourself to use the built-in previewers. Before you
# install and use third-party software, make sure you understand the licensing implications of doing so.
defmodule ActiveStorage.Preview do
  # class UnprocessedError < StandardError; end

  # attr_reader :blob, :variation

  alias ActiveStorage.{RepoClient}
  alias __MODULE__
  defstruct [:blob, :variation]

  def new(blob, variation_or_variation_key) do
    %__MODULE__{
      blob: blob,
      variation: ActiveStorage.Variation.wrap(variation_or_variation_key)
    }

    # @blob, @variation = blob, ActiveStorage.Variation.wrap(variation_or_variation_key)
  end

  # Processes the preview if it has not been processed yet. Returns the receiving Preview instance for convenience:
  #
  #   blob.preview(resize_to_limit: [100, 100]).processed.url
  #
  # Processing a preview generates an image from its blob and attaches the preview image to the blob. Because the preview
  # image is stored with the blob, it is only generated once.
  def processed(preview) do
    case processed?(preview) do
      true -> preview
      _ -> process(preview)
    end

    # process unless processed?
    # self
  end

  # Returns the blob's attached preview image.
  def image(preview) do
    ActiveStorage.attachment_query(preview.blob, "image")
    |> RepoClient.repo().one()

    # blob.preview_image
  end

  # Returns the URL of the preview's variant on the service. Raises ActiveStorage::Preview::UnprocessedError if the
  # preview has not been processed yet.
  #
  # This method synchronously processes a variant of the preview image, so do not call it in views. Instead, generate
  # a stable URL that redirects to the URL returned by this method.
  def url(preview, options \\ []) do
    if processed?(preview) do
      # Activestorage.Representable.variant.url(options)
      ActiveStorage.Blob.Representable.variant(preview.blob, options)
      |> ActiveStorage.Variant.url()
    else
      raise ActiveStorage.UnprocessedError
    end
  end

  # Returns a combination key of the blob and the variation that together identifies a specific variant.
  def key(preview) do
    if processed?(preview) do
      preview.variant |> ActiveStorage.Variant.url()
    else
      raise ActiveStorage.UnprocessedError
    end
  end

  # Downloads the file associated with this preview's variant. If no block is
  # given, the entire file is read into memory and returned. That'll use a lot
  # of RAM for very large files. If a block is given, then the download is
  # streamed and yielded in chunks. Raises ActiveStorage::Preview::UnprocessedError
  # if the preview has not been processed yet.
  def download(preview, _block) do
    if processed?(preview) do
      # variant.download(block)
    else
      raise ActiveStorage.UnprocessedError
    end
  end

  def processed?(preview) do
    ActiveStorage.attached?(preview.blob, "image")
    # image.attached?
  end

  def process(preview) do
    %mod{} = previewer(preview)

    mod.preview(
      preview,
      service_name: preview.blob.service_name,
      block: fn attachable ->
        IO.puts("HERE WE SHOWLD RECEIVE ATTACHMENT")
        IO.inspect(attachable)
        # ActiveStorage.attach(preview.blob, attachable)
      end
    )

    # previewer.preview(service_name: blob.service_name) do |attachable|
    #   ActiveRecord::Base.connected_to(role: ActiveRecord.writing_role) do
    #     image.attach(attachable)
    #   end
    # end
  end

  def variant(preview) do
    ActiveStorage.Blob.Representable.variant(preview.blob, preview.variation)
    |> ActiveStorage.Variant.processed()

    # image.variant(variation).processed
  end

  def previewer(preview) do
    previewer_class(preview).new(preview.blob)
  end

  def previewer_class(preview) do
    ActiveStorage.previewers()
    |> Enum.find(fn mod ->
      mod.accept?(preview.blob)
    end)

    # ActiveStorage.previewers.detect { |klass| klass.accept?(blob) }
  end
end