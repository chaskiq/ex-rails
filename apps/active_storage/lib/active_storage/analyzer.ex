defmodule ActiveStorage.Analyzer do
  defmacro __using__(_opts) do
    quote do
      # alias __MODULE__
      defstruct [:blob]

      # This is an abstract base class for analyzers, which extract metadata from blobs. See
      # ActiveStorage::Analyzer::ImageAnalyzer for an example of a concrete subclass.

      # attr_reader :blob

      # Implement this method in a concrete subclass. Have it return true when given a blob from which
      # the analyzer can extract metadata.
      def accept?(_blob) do
        false
      end

      defoverridable accept?: 1
      # Implement this method in concrete subclasses. It will determine if blob analysis
      # should be done in a job or performed inline. By default, analysis is enqueued in a job.
      def analyze_later? do
        true
      end

      defoverridable analyze_later?: 0

      def new(blob) do
        %__MODULE__{blob: blob}
      end

      # Override this method in a concrete subclass. Have it return a Hash of metadata.
      # def metadata do
      #  # raise NotImplementedError
      # end

      # Downloads the blob to a tempfile on disk. Yields the tempfile.
      # defp download_blob_to_tempfile(&block) #:doc:
      def download_blob_to_tempfile(blob) do
        # , tmpdir: tmpdir)
        blob.__struct__.open(blob)
        # blob.open tmpdir: tmpdir, &block
      end

      def logger do
        ActiveStorage.logger()
      end

      def tmpdir do
        # Dir.tmpdir()
      end

      def instrument(analyzer, block) do
        ActiveStorage.Metrics.instrument(
          [:analyze, :active_storage],
          %{analyzer: analyzer},
          block
        )
      end
    end
  end
end
