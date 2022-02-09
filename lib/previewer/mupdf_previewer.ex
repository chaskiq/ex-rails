# frozen_string_literal: true

defmodule ActiveStorage.Previewer.MuPDFPreviewer do
  def accept?(blob) do
    # blob.content_type == "application/pdf" && mutool_exists?
  end

  def mutool_path do
    # ActiveStorage.paths[:mutool] || "mutool"
  end

  def mutool_exists? do
    # return @mutool_exists if defined?(@mutool_exists) && !@mutool_exists.nil?

    # system mutool_path, out: File::NULL, err: File::NULL

    # @mutool_exists = $?.exitstatus == 1
  end

  def preview(previewer, options) do
    # download_blob_to_tempfile do |input|
    #  draw_first_page_from input do |output|
    #    yield io: output, filename: "#{blob.filename.base}.png", content_type: "image/png", **options
    #  end
    # end
  end

  defp draw_first_page_from(previewer, file, block) do
    # draw self.class.mutool_path, "draw", "-F", "png", "-o", "-", file.path, "1", &block
  end
end
