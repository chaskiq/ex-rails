defmodule ActiveStorage.Previewer.PopplerPDFPreviewerTest do
  use ExUnit.Case, async: false

  test "previewing a PDF document" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "report.pdf",
        content_type: "application/pdf"
      )

    attachable =
      ActiveStorage.Previewer.PopplerPDFPreviewer.new(blob)
      |> ActiveStorage.Previewer.PopplerPDFPreviewer.preview([], fn attachable ->
        assert "image/png" == attachable[:content_type]
        assert "report.png" == attachable[:filename]
        image = Mogrify.open(attachable[:io]) |> Mogrify.verbose()
        assert 612 == image.width
        assert 792 == image.height
      end)

    # blob = create_file_blob(filename: "report.pdf", content_type: "application/pdf")

    # ActiveStorage::Previewer::PopplerPDFPreviewer.new(blob).preview do |attachable|
    #  assert_equal "image/png", attachable[:content_type]
    #  assert_equal "report.png", attachable[:filename]

    #  image = MiniMagick::Image.read(attachable[:io])
    #  assert_equal 612, image.width
    #  assert_equal 792, image.height
    # end
  end

  test "previewing a cropped PDF document" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "cropped.pdf",
        content_type: "application/pdf"
      )

    attachable =
      ActiveStorage.Previewer.PopplerPDFPreviewer.new(blob)
      |> ActiveStorage.Previewer.PopplerPDFPreviewer.preview([], fn attachable ->
        assert "image/png" == attachable[:content_type]
        assert "cropped.png" == attachable[:filename]
        image = Mogrify.open(attachable[:io]) |> Mogrify.verbose()
        assert 430 == image.width
        assert 145 == image.height
      end)

    # blob = create_file_blob(filename: "cropped.pdf", content_type: "application/pdf")

    # ActiveStorage::Previewer::PopplerPDFPreviewer.new(blob).preview do |attachable|
    #  assert_equal "image/png", attachable[:content_type]
    #  assert_equal "cropped.png", attachable[:filename]

    #  image = MiniMagick::Image.read(attachable[:io])
    #  assert_equal 430, image.width
    #  assert_equal 145, image.height
    # end
  end

  test "previewing a PDF that can't be previewed" do
    blob =
      ActiveStorageTestHelpers.create_file_blob(
        filename: "video.mp4",
        content_type: "application/pdf"
      )

    assert_raise ActiveStorage.PreviewError, fn ->
      ActiveStorage.Previewer.PopplerPDFPreviewer.new(blob)
      |> ActiveStorage.Previewer.PopplerPDFPreviewer.preview()
    end

    # blob = create_file_blob(filename: "video.mp4", content_type: "application/pdf")

    # assert_raises ActiveStorage::PreviewError do
    #  ActiveStorage::Previewer::PopplerPDFPreviewer.new(blob).preview
    # end
  end
end
