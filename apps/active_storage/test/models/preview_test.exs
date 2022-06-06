defmodule PreviewTest do
  use ExUnit.Case, async: false

  test "previewing a PDF" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "report.pdf",
        content_type: "application/pdf"
      )

    preview = ActiveStorage.Blob.preview(blob, resize_to_limit: "640x280")
    _processed = ActiveStorage.Preview.processed(preview)

    assert "report.png", preview.blob.__struct__.filename(preview.blob).filename
    assert "image/png", preview.blob.content_type

    image = ActiveStorageTestHelpers.read_image(preview.blob)

    assert 612 == image.width
    assert 792 == image.height

    # blob = create_file_blob(filename: "report.pdf", content_type: "application/pdf")
    # preview = blob.preview(resize_to_limit: [640, 280]).processed
    #
    # assert_predicate preview.image, :attached?
    # assert_equal "report.png", preview.image.filename.to_s
    # assert_equal "image/png", preview.image.content_type
    #
    # image = read_image(preview.image)
    # assert_equal 612, image.width
    # assert_equal 792, image.height
  end

  test "previewing a cropped PDF" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "cropped.pdf",
        content_type: "application/pdf"
      )

    preview = ActiveStorage.Blob.preview(blob, resize_to_limit: "640x280")
    processed = ActiveStorage.Preview.processed(preview)

    assert "cropped.png", processed.blob.__struct__.filename(processed.blob).filename
    assert "image/png", processed.blob.content_type

    image = ActiveStorageTestHelpers.read_image(processed.blob)

    assert 430 == image.width
    assert 145 == image.height

    # blob = create_file_blob(filename: "cropped.pdf", content_type: "application/pdf")
    # preview = blob.preview(resize_to_limit: [640, 280]).processed
    #
    # assert_predicate preview.image, :attached?
    # assert_equal "cropped.png", preview.image.filename.to_s
    # assert_equal "image/png", preview.image.content_type
    #
    # image = read_image(preview.image)
    # assert_equal 430, image.width
    # assert_equal 145, image.height
  end

  test "previewing an MP4 video" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "video.mp4",
        content_type: "video/mp4"
      )

    preview = ActiveStorage.Blob.preview(blob, resize_to_limit: "640x280")
    processed = ActiveStorage.Preview.processed(preview)

    assert "video.jpg", ActiveStorage.Blob.filename(processed.blob).filename
    assert "image/jpeg", processed.blob.content_type

    image = ActiveStorageTestHelpers.read_image(processed.blob)

    assert 640 == image.width
    assert 480 == image.height

    # blob = create_file_blob(filename: "video.mp4", content_type: "video/mp4")
    # preview = blob.preview(resize_to_limit: [640, 280]).processed
    #
    # assert_predicate preview.image, :attached?
    # assert_equal "video.jpg", preview.image.filename.to_s
    # assert_equal "image/jpeg", preview.image.content_type
    #
    # image = read_image(preview.image)
    # assert_equal 640, image.width
    # assert_equal 480, image.height
  end

  test "previewing an unpreviewable blob" do
    blob = ActiveStorageTestHelpers.create_file_blob()

    assert_raise ActiveStorage.UnpreviewableError, fn ->
      ActiveStorage.Blob.preview(blob, resize_to_limit: "640x280")
    end

    # blob = create_file_blob
    #
    # assert_raises ActiveStorage::UnpreviewableError do
    #  blob.preview resize_to_limit: [640, 280]
    # end
  end

  @tag skip: "this test is incomplete"
  test "previewing on the writer DB" do
    _blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "report.pdf",
        content_type: "application/pdf"
      )

    # blob = create_file_blob(filename: "report.pdf", content_type: "application/pdf")

    # # prevent_writes option is required because there is no automatic write protection anymore
    # ActiveRecord::Base.connected_to(role: ActiveRecord.reading_role, prevent_writes: true) do
    #   blob.preview(resize_to_limit: [640, 280]).processed
    # end

    # assert blob.reload.preview_image.attached?
  end

  test "preview of PDF is created on the same service" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "report.pdf",
        content_type: "application/pdf",
        service_name: "local_public"
      )

    preview = ActiveStorage.Blob.preview(blob, resize_to_limit: "640x280")
    _processed = ActiveStorage.Preview.processed(preview)

    assert preview.blob.service_name == "local_public"

    # blob = create_file_blob(filename: "report.pdf", content_type: "application/pdf", service_name: "local_public")
    # preview = blob.preview(resize_to_limit: [640, 280]).processed
    #
    # assert_equal "local_public", preview.image.blob.service_name
  end

  test "preview of MP4 video is created on the same service" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "video.mp4",
        content_type: "video/mp4",
        service_name: "local_public"
      )

    preview = ActiveStorage.Blob.preview(blob, resize_to_limit: "640x280")
    _processed = ActiveStorage.Preview.processed(preview)
    assert preview.blob.service_name == "local_public"

    # blob = create_file_blob(filename: "video.mp4", content_type: "video/mp4", service_name: "local_public")
    # preview = blob.preview(resize_to_limit: [640, 280]).processed
    #
    # assert_equal "local_public", preview.image.blob.service_name
  end
end
