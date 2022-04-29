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
  use ActiveStorage.Analyzer

  def accept?(blob) do
    # blob.video?
    blob |> ActiveStorage.Blob.video?()
  end

  def metadata(blob) do
    file = download_blob_to_tempfile(blob)
    probe = probe_from(file)

    %{
      "width" => width(probe),
      "height" => height(probe),
      "duration" => duration(probe),
      "angle" => angle(probe),
      "display_aspect_ratio" => display_aspect_ratio(probe),
      "audio" => audio?(probe),
      "video" => video?(probe)
    }
  end

  defp width(probe) do
    if rotated?(probe) do
      computed_height(probe) || encoded_height(probe)
    else
      encoded_width(probe)
    end
  end

  defp height(probe) do
    if rotated?(probe) do
      encoded_width(probe)
    else
      computed_height(probe) || encoded_height(probe)
    end
  end

  def duration(probe) do
    # IO.inspect(video_stream(probe))
    data = video_stream(probe)
    duration = Map.get(data, "duration") || Map.get(container(probe), "duration")

    case duration do
      nil ->
        nil

      d ->
        {f, _} = Float.parse(d)
        f
    end

    #  duration = video_stream["duration"] || container["duration"]
    #  Float(duration) if duration
  end

  def angle(probe) do
    case tags(probe) |> Map.get("rotate") do
      nil ->
        nil

      br ->
        {i, _} = Integer.parse(br)
        i
    end

    #  Integer(tags["rotate"]) if tags["rotate"]
  end

  def display_aspect_ratio(probe) do
    case video_stream(probe) |> Map.get("display_aspect_ratio") do
      nil ->
        nil

      descriptor ->
        case descriptor |> String.split(":") do
          nil ->
            nil

          terms ->
            {numerator, _} = Integer.parse(List.first(terms))

            {denominator, _} = Integer.parse(List.last(terms))

            unless numerator == 0 do
              [numerator, denominator]
            end
        end
    end

    #  if descriptor = video_stream["display_aspect_ratio"]
    #    if terms = descriptor.split(":", 2)
    #      numerator   = Integer(terms[0])
    #      denominator = Integer(terms[1])
    #
    #      [numerator, denominator] unless numerator == 0
    #    end
    #  end
  end

  def rotated?(probe) do
    angle(probe) == 90 || angle(probe) == 270
  end

  def audio?(probe) do
    s = audio_stream(probe)

    cond do
      map_size(s) > 0 -> true
      true -> false
    end
  end

  def video?(probe) do
    s = video_stream(probe)

    cond do
      map_size(s) > 0 -> true
      true -> false
    end
  end

  def computed_height(probe) do
    if encoded_width(probe) && display_height_scale(probe) do
      encoded_width(probe) * display_height_scale(probe)
    end
  end

  def encoded_width(probe) do
    case video_stream(probe) |> Map.get("width") do
      nil ->
        nil

      # Float.parse(width)
      width ->
        width
    end

    #  @encoded_width ||= Float(video_stream["width"]) if video_stream["width"]
  end

  def encoded_height(probe) do
    case video_stream(probe) |> Map.get("height") do
      nil ->
        nil

      height ->
        height
        # Float.parse(height)
    end

    #  @encoded_height ||= Float(video_stream["height"]) if video_stream["height"]
  end

  def display_height_scale(probe) do
    case display_aspect_ratio(probe) do
      nil -> nil
      [a, b] -> b / a
    end

    #  @display_height_scale ||= Float(display_aspect_ratio.last) / display_aspect_ratio.first if display_aspect_ratio
  end

  def tags(probe) do
    case video_stream(probe) |> Map.get("tags") do
      nil -> %{}
      tags -> tags
    end

    #  @tags ||= video_stream["tags"] || {}
  end

  def video_stream(probe) do
    stream_resource(probe, "video")
    #  @video_stream ||= streams.detect { |stream| stream["codec_type"] == "video" } || {}
  end

  def audio_stream(probe) do
    stream_resource(probe, "audio")
    #  @video_stream ||= streams.detect { |stream| stream["codec_type"] == "audio" } || {}
  end

  def stream_resource(probe, type) do
    streams(probe)
    |> Enum.find(fn stream ->
      stream |> Map.get("codec_type") == type
    end) || %{}

    #  @video_stream ||= streams.detect { |stream| stream["codec_type"] == "video" } || {}
  end

  def streams(probe) do
    #  probe["streams"] || []
    probe |> Map.get("streams") || []
  end

  def container(probe) do
    #  probe["format"] || {}
    probe |> Map.get("format") || %{}
  end

  # this function is called on the beggining of metadata
  # defp probe(blob) do
  #  file = download_blob_to_tempfile(blob)
  #  probe_from(file)
  #  # @probe ||= download_blob_to_tempfile { |file| probe_from(file) }
  # end

  def probe_from(file) do
    try do
      {output, _status} =
        System.cmd(ffprobe_path(), [
          "-print_format",
          "json",
          "-show_streams",
          "-show_format",
          "-v",
          "error",
          file
        ])

      Jason.decode!(output)
    rescue
      RuntimeError ->
        IO.puts("Skipping video analysis because FFmpeg isn't installed")

        %{}
    end

    # IO.popen([ ffprobe_path,
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
    ActiveStorage.paths()[:ffprobe] || "ffprobe"
  end
end
