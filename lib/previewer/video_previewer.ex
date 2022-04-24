# frozen_string_literal: true

# require "shellwords"

defmodule ActiveStorage.Previewer.VideoPreviewer do
  defstruct [:blob]

  def new(blob) do
    %__MODULE__{blob: blob}
  end

  def accept?(blob) do
    ActiveStorage.Blob.video?(blob) && ffmpeg_exists?()
    # blob.video? && ffmpeg_exists?
  end

  def ffmpeg_exists? do
    # TODO: put state here
    # return @ffmpeg_exists if defined?(@ffmpeg_exists)
    # @ffmpeg_exists = system(ffmpeg_path, "-version", out: File::NULL, err: File::NULL)
    case System.cmd(ActiveStorage.paths()[:ffmpeg], ["-version"]) do
      {_, 0} -> true
      _ -> false
    end
  end

  def ffmpeg_path do
    ActiveStorage.paths()[:ffmpeg] || "ffmpeg"
  end

  def preview(previewer, options \\ []) do
    input = ActiveStorage.Previewer.download_blob_to_tempfile(previewer.blob)

    draw_relevant_frame_from(previewer, input, fn output ->
      require IEx
      IEx.pry()
      # yield the output
    end)

    # download_blob_to_tempfile do |input|
    #  draw_relevant_frame_from input do |output|
    #    yield io: output, filename: "#{blob.filename.base}.jpg", content_type: "image/jpeg", **options
    #  end
    # end
  end

  defp draw_relevant_frame_from(previewer, file, block \\ nil) do
    args =
      [
        ffmpeg_path(),
        "-i",
        file
      ] ++
        OptionParser.split(ActiveStorage.video_preview_arguments()) ++
        ["-"]

    ActiveStorage.Previewer.draw(
      previewer,
      args,
      fn f ->
        block.(f)
      end
    )

    # draw self.class.ffmpeg_path, "-i", file.path, *Shellwords.split(ActiveStorage.video_preview_arguments), "-", &block
  end
end
