# frozen_string_literal: true
# require "test_helper"
# require "database/setup"

defmodule RepresentationTest do
  use ExUnit.Case, async: false

  @tag skip: "this test is incomplete"
  test "representing an image" do
    # blob = create_file_blob
    # representation = blob.representation(resize_to_limit: [100, 100]).processed
    #
    # image = read_image(representation.image)
    # assert_equal 100, image.width
    # assert_equal 67, image.height
  end

  @tag skip: "this test is incomplete"
  test "representing a PDF" do
    # blob = create_file_blob(filename: "report.pdf", content_type: "application/pdf")
    # representation = blob.representation(resize_to_limit: [640, 280]).processed
    #
    # image = read_image(representation.image)
    # assert_equal 612, image.width
    # assert_equal 792, image.height
  end

  @tag skip: "this test is incomplete"
  test "representing an MP4 video" do
    # blob = create_file_blob(filename: "video.mp4", content_type: "video/mp4")
    # representation = blob.representation(resize_to_limit: [640, 280]).processed
    #
    # image = read_image(representation.image)
    # assert_equal 640, image.width
    # assert_equal 480, image.height
  end

  @tag skip: "this test is incomplete"
  test "representing an unrepresentable blob" do
    # blob = create_blob
    #
    # assert_raises ActiveStorage::UnrepresentableError do
    #   blob.representation resize_to_limit: [100, 100]
    # end
  end
end