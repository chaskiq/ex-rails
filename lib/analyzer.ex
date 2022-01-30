# frozen_string_literal: true

defmodule ActiveStorage.Analyzer do
  # This is an abstract base class for analyzers, which extract metadata from blobs. See
  # ActiveStorage::Analyzer::ImageAnalyzer for an example of a concrete subclass.

  # attr_reader :blob

  # Implement this method in a concrete subclass. Have it return true when given a blob from which
  # the analyzer can extract metadata.
  def accept?(_blob) do
    false
  end

  # Implement this method in concrete subclasses. It will determine if blob analysis
  # should be done in a job or performed inline. By default, analysis is enqueued in a job.
  def analyze_later? do
    true
  end

  def new(_blob) do
    # @blob = blob
  end

  # Override this method in a concrete subclass. Have it return a Hash of metadata.
  def metadata do
    # raise NotImplementedError
  end

  # Downloads the blob to a tempfile on disk. Yields the tempfile.
  # defp download_blob_to_tempfile(&block) #:doc:
  defp download_blob_to_tempfile do
    # blob.open tmpdir: tmpdir, &block
  end

  defp logger do
    ActiveStorage.logger()
  end

  defp tmpdir do
    # Dir.tmpdir()
  end
end
