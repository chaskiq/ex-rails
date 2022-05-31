defmodule ActiveStorage.Analyzer.AudioAnalyzerTest do
  use ExUnit.Case, async: false

  test "analyzing an audio" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(filename: "audio.mp3", content_type: "audio/mp3")

    metadata = ActiveStorageTestHelpers.extract_metadata_from(blob) |> Jason.decode!()

    assert 0.914286 == metadata["duration"]
    assert 128_000 == metadata["bit_rate"]
    # blob = create_file_blob(filename: "audio.mp3", content_type: "audio/mp3")
    # metadata = extract_metadata_from(blob)

    # assert_equal 0.914286, metadata[:duration]
    # assert_equal 128000, metadata[:bit_rate]
  end

  test "instrumenting analysis" do
    # events = subscribe_events_from("analyze.active_storage")

    # blob = create_file_blob(filename: "audio.mp3", content_type: "audio/mp3")
    # blob.analyze

    # assert_equal 1, events.size
    # assert_equal({ analyzer: "ffprobe" }, events.first.payload)
  end
end
