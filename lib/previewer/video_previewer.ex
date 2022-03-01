# frozen_string_literal: true

# require "shellwords"

defmodule ActiveStorage.Previewer.VideoPreviewer do
  def accept?(blob) do
    # blob.video? && ffmpeg_exists?
  end

  def ffmpeg_exists? do
    # return @ffmpeg_exists if defined?(@ffmpeg_exists)

    # @ffmpeg_exists = system(ffmpeg_path, "-version", out: File::NULL, err: File::NULL)
  end

  def ffmpeg_path do
    # ActiveStorage.paths[:ffmpeg] || "ffmpeg"
  end

  def preview(_previewer, _options) do
    # download_blob_to_tempfile do |input|
    #  draw_relevant_frame_from input do |output|
    #    yield io: output, filename: "#{blob.filename.base}.jpg", content_type: "image/jpeg", **options
    #  end
    # end
  end

  defp draw_relevant_frame_from(_previewr, _file, _block) do
    # draw self.class.ffmpeg_path, "-i", file.path, *Shellwords.split(ActiveStorage.video_preview_arguments), "-", &block
  end
end
