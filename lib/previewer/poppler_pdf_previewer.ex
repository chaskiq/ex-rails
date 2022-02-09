# frozen_string_literal: true

defmodule ActiveStorage.Previewer.PopplerPDFPreviewer do
  def accept?(blob) do
    # blob.content_type == "application/pdf" && pdftoppm_exists?
  end

  def pdftoppm_path do
    # ActiveStorage.paths[:pdftoppm] || "pdftoppm"
  end

  def pdftoppm_exists? do
    # return @pdftoppm_exists if defined?(@pdftoppm_exists)
    # @pdftoppm_exists = system(pdftoppm_path, "-v", out: File::NULL, err: File::NULL)
  end

  def preview(options) do
    # download_blob_to_tempfile do |input|
    #  draw_first_page_from input do |output|
    #    yield io: output, filename: "#{blob.filename.base}.png", content_type: "image/png", **options
    #  end
    # end
  end

  def draw_first_page_from(file, block) do
    # use 72 dpi to match thumbnail dimensions of the PDF
    # draw self.class.pdftoppm_path, "-singlefile", "-cropbox", "-r", "72", "-png", file.path, &block
  end
end
