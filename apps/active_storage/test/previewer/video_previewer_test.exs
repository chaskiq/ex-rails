defmodule ActiveStorage.Previewer.VideoPreviewerTest do
  use ExUnit.Case, async: false

  test "previewing an MP4 video" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "video.mp4",
        content_type: "video/mp4"
      )

    attachable =
      ActiveStorage.Previewer.VideoPreviewer.new(blob)
      |> ActiveStorage.Previewer.VideoPreviewer.preview([], fn attachable ->
        assert "image/jpeg" == attachable[:content_type]
        assert "video.jpg" == attachable[:filename]
        image = Mogrify.open(attachable[:io]) |> Mogrify.verbose()
        assert 640 == image.width
        assert 480 == image.height
        # assert "image/jpeg" == image.mime_type
      end)

    # blob = create_file_blob(filename: "video.mp4", content_type: "video/mp4")

    # ActiveStorage::Previewer::VideoPreviewer.new(blob).preview do |attachable|
    #  assert_equal "image/jpeg", attachable[:content_type]
    #  assert_equal "video.jpg", attachable[:filename]

    #  image = MiniMagick::Image.read(attachable[:io])
    #  assert_equal 640, image.width
    #  assert_equal 480, image.height
    #  assert_equal "image/jpeg", image.mime_type
    # end
  end

  test "previewing a video that can't be previewed" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "report.pdf",
        content_type: "video/mp4"
      )

    assert_raise ActiveStorage.PreviewError, fn ->
      ActiveStorage.Previewer.VideoPreviewer.new(blob)
      |> ActiveStorage.Previewer.VideoPreviewer.preview()
    end

    # blob = create_file_blob(filename: "report.pdf", content_type: "video/mp4")
    #
    # assert_raises ActiveStorage::PreviewError do
    #  ActiveStorage::Previewer::VideoPreviewer.new(blob).preview
    # end
  end
end
