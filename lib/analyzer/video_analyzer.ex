# frozen_string_literal: true

# Extracts the following from a video blob:
#
# * Width (pixels)
# * Height (pixels)
# * Duration (seconds)
# * Angle (degrees)
# * Display aspect ratio
#
# Example:
#
#   ActiveStorage::Analyzer::VideoAnalyzer.new(blob).metadata
#   # => { width: 640.0, height: 480.0, duration: 5.0, angle: 0, display_aspect_ratio: [4, 3] }
#
# When a video's angle is 90 or 270 degrees, its width and height are automatically swapped for convenience.
#
# This analyzer requires the {FFmpeg}[https://www.ffmpeg.org] system library, which is not provided by Rails.
defmodule ActiveStorage.Analyzer.VideoAnalyzer do
  def accept?(_blob) do
    # blob.video?
  end

  def metadata(_blob) do
    # %{ width: width,
    # height: height,
    #  duration: duration,
    #  angle: angle,
    #  display_aspect_ratio: display_aspect_ratio
    # }
  end

  defp width do
    # if rotated?
    #   computed_height || encoded_height
    # else
    #   encoded_width
    # end
  end

  defp height do
    # if rotated?
    #   encoded_width
    # else
    #   computed_height || encoded_height
    # end
  end

  defp duration do
    #  duration = video_stream["duration"] || container["duration"]
    #  Float(duration) if duration
  end

  defp angle do
    #  Integer(tags["rotate"]) if tags["rotate"]
  end

  def display_aspect_ratio do
    #  if descriptor = video_stream["display_aspect_ratio"]
    #    if terms = descriptor.split(":", 2)
    #      numerator   = Integer(terms[0])
    #      denominator = Integer(terms[1])
    #
    #      [numerator, denominator] unless numerator == 0
    #    end
    #  end
  end

  def rotated? do
    #  angle == 90 || angle == 270
  end

  def computed_height do
    #  if encoded_width && display_height_scale
    #    encoded_width * display_height_scale
    #  end
  end

  def encoded_width do
    #  @encoded_width ||= Float(video_stream["width"]) if video_stream["width"]
  end

  def encoded_height do
    #  @encoded_height ||= Float(video_stream["height"]) if video_stream["height"]
  end

  def display_height_scale do
    #  @display_height_scale ||= Float(display_aspect_ratio.last) / display_aspect_ratio.first if display_aspect_ratio
  end

  def tags do
    #  @tags ||= video_stream["tags"] || {}
  end

  def video_stream do
    #  @video_stream ||= streams.detect { |stream| stream["codec_type"] == "video" } || {}
  end

  def streams do
    #  probe["streams"] || []
  end

  def container do
    #  probe["format"] || {}
  end

  def probe do
    #  @probe ||= download_blob_to_tempfile { |file| probe_from(file) }
  end

  def probe_from(_file) do
    #   IO.popen([ ffprobe_path,
    #     "-print_format", "json",
    #     "-show_streams",
    #     "-show_format",
    #     "-v", "error",
    #     file.path
    #   ]) do |output|
    #     JSON.parse(output.read)
    #   end
    # rescue Errno::ENOENT
    #   logger.info "Skipping video analysis because FFmpeg isn't installed"
    #   {}
  end

  def ffprobe_path do
    # ActiveStorage.paths[:ffprobe] || "ffprobe"
  end
end
