# frozen_string_literal: true

defmodule ActiveStorage.Analyzer.AudioAnalyzer do
  use ActiveStorage.Analyzer

  # Extracts duration (seconds) and bit_rate (bits/s) from an audio blob.
  #
  # Example:
  #
  #   ActiveStorage::Analyzer::AudioAnalyzer.new(blob).metadata
  #   # => { duration: 5.0, bit_rate: 320340 }
  #
  # This analyzer requires the {FFmpeg}[https://www.ffmpeg.org] system library, which is not provided by Rails.
  def accept?(blob) do
    blob |> ActiveStorage.Blob.audio?()
  end

  def metadata(blob) do
    %{"duration" => duration(blob), "bit_rate" => bit_rate(blob)}

    # .compact
  end

  defp duration(blob) do
    case blob |> audio_stream |> Map.get("duration") do
      nil ->
        nil

      d ->
        {f, _} = Float.parse(d)
        f
    end

    # Float(duration) if duration
  end

  defp bit_rate(blob) do
    case blob |> audio_stream |> Map.get("bit_rate") do
      nil ->
        nil

      br ->
        {i, _} = Integer.parse(br)
        i
    end

    # Integer(bit_rate) if bit_rate
  end

  defp audio_stream(blob) do
    streams(blob)
    |> Enum.find(fn stream ->
      stream |> Map.get("codec_type") == "audio"
    end) || %{}

    # @audio_stream ||= streams.detect { |stream| stream["codec_type"] == "audio" } || {}
  end

  defp streams(blob) do
    probe(blob) |> Map.get("streams") || []
  end

  defp probe(blob) do
    file = download_blob_to_tempfile(blob)
    probe_from(file)
    # @probe ||= download_blob_to_tempfile { |file| probe_from(file) }
  end

  defp probe_from(file) do
    instrument(Path.basename(ffprobe_path()), fn ->
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
    end)

    # instrument(File.basename(ffprobe_path)) do
    #   IO.popen([ ffprobe_path,
    #     "-print_format", "json",
    #     "-show_streams",
    #     "-show_format",
    #     "-v", "error",
    #     file.path
    #   ]) do |output|
    #     JSON.parse(output.read)
    #   end
    # end
    # rescue Errno::ENOENT
    # logger.info "Skipping audio analysis because ffprobe isn't installed"
    # {}
  end

  defp ffprobe_path do
    ActiveStorage.paths()[:ffprobe] || "ffprobe"
  end
end
