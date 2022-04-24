# frozen_string_literal: true

defmodule ActiveStorage.Previewer.MuPDFPreviewer do
  defstruct [:blob]

  def new(blob) do
    %__MODULE__{blob: blob}
  end

  def accept?(blob) do
    blob.content_type == "application/pdf" && mutool_exists?()
    # blob.content_type == "application/pdf" && mutool_exists?
  end

  def mutool_path do
    ActiveStorage.paths()[:mutool] || "mutool"
  end

  def mutool_exists? do
    # return @mutool_exists if defined?(@mutool_exists) && !@mutool_exists.nil?

    # system mutool_path, out: File::NULL, err: File::NULL

    # @mutool_exists = $?.exitstatus == 1
    # TODO cache state here
    case System.cmd(__MODULE__.mutool_path(), ["-v"]) do
      {"", 0} ->
        true

      _ ->
        false
    end
  end

  def preview(previewer, options \\ [], block \\ nil) do
    input = ActiveStorage.Previewer.download_blob_to_tempfile(previewer.blob)

    draw_first_page_from(previewer, input, fn path, _fd ->
      filename =
        (previewer.blob |> ActiveStorage.Blob.filename() |> ActiveStorage.Filename.base()) <>
          ".png"

      content_type = "image/png"

      output = [io: path, filename: filename, content_type: content_type] ++ options

      if(block) do
        block.(output)
      else
        output
      end

      # yield the output
    end)

    # download_blob_to_tempfile do |input|
    #  draw_first_page_from input do |output|
    #    yield io: output, filename: "#{blob.filename.base}.png", content_type: "image/png", **options
    #  end
    # end
  end

  def draw_first_page_from(previewer, file, block \\ nil) do
    args = [
      mutool_path(),
      "draw",
      "-F",
      "png",
      "-0",
      "-",
      file,
      "1"
    ]

    ActiveStorage.Previewer.draw(
      previewer,
      args,
      fn path, fd ->
        block.(path, fd)
      end
    )

    # draw self.class.mutool_path, "draw", "-F", "png", "-o", "-", file.path, "1", &block
  end
end
