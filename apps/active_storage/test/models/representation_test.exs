defmodule RepresentationTest do
  use ExUnit.Case, async: false

  setup do
    ActiveStorage.TableConfig.put("track_variants", true)
    {:ok, %{}}
  end

  test "representing an image" do
    blob = ActiveStorageTestHelpers.create_file_blob()

    representation = ActiveStorage.Blob.representation(blob, %{resize_to_limit: "100x100"})

    processed = representation.__struct__.processed(representation)

    attached = processed.__struct__.image(processed)

    image = ActiveStorageTestHelpers.read_image(attached)
    assert 100 == image.width
    assert 67 == image.height
    # blob = create_file_blob
    # representation = blob.representation(resize_to_limit: [100, 100]).processed
    #
    # image = read_image(representation.image)
    # assert_equal 100, image.width
    # assert_equal 67, image.height
  end

  test "representing a PDF" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "report.pdf",
        content_type: "application/pdf"
      )

    representation = ActiveStorage.Blob.representation(blob, %{resize_to_limit: "640x280"})
    processed = representation.__struct__.processed(representation)

    attached = processed.__struct__.image(processed)

    image = ActiveStorageTestHelpers.read_image(attached)
    assert 612 == image.width
    assert 792 == image.height

    # blob = create_file_blob(filename: "report.pdf", content_type: "application/pdf")
    # representation = blob.representation(resize_to_limit: [640, 280]).processed
    #
    # image = read_image(representation.image)
    # assert_equal 612, image.width
    # assert_equal 792, image.height
  end

  test "representing an MP4 video" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "video.mp4",
        content_type: "video/mp4"
      )

    representation =
      ActiveStorage.Blob.representation(
        blob,
        %{resize_to_limit: "640x280"}
      )

    processed = representation.__struct__.processed(representation)

    attached = processed.__struct__.image(processed)

    image = ActiveStorageTestHelpers.read_image(attached)
    assert 640 == image.width
    assert 480 == image.height

    # blob = create_file_blob(filename: "video.mp4", content_type: "video/mp4")
    # representation = blob.representation(resize_to_limit: [640, 280]).processed
    #
    # image = read_image(representation.image)
    # assert_equal 640, image.width
    # assert_equal 480, image.height
  end

  test "representing an unrepresentable blob" do
    blob = ActiveStorageTestHelpers.create_blob()

    assert_raise ActiveStorage.UnrepresentableError, fn ->
      ActiveStorage.Blob.representation(
        blob,
        %{resize_to_limit: "100x100"}
      )
    end

    # blob = create_blob
    #
    # assert_raises ActiveStorage::UnrepresentableError do
    #   blob.representation resize_to_limit: [100, 100]
    # end
  end
end
