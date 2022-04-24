# frozen_string_literal: true

defmodule ActiveStorage.Previewer do
  # This is an abstract base class for previewers, which generate images from blobs. See
  # ActiveStorage::Previewer::MuPDFPreviewer and ActiveStorage::Previewer::VideoPreviewer for
  # examples of concrete subclasses.

  # alias __MODULE__
  defstruct [:blob]

  # Implement this method in a concrete subclass. Have it return true when given a blob from which
  # the previewer can generate an image.
  def accept?(_blob) do
    false
  end

  def new(blob) do
    %__MODULE__{blob: blob}
  end

  # Override this method in a concrete subclass. Have it yield an attachable preview image (i.e.
  # anything accepted by ActiveStorage::Attached::One#attach). Pass the additional options to
  # the underlying blob that is created.
  # def preview(**options) do
  #  raise NotImplementedError
  # end

  # Downloads the blob to a tempfile on disk. Yields the tempfile.
  # :doc:
  def download_blob_to_tempfile(blob, options \\ []) do
    defaults = [block: nil, tmpdir: tmpdir()]
    options = Keyword.merge(defaults, options)
    ActiveStorage.Blob.open(blob, options)
    # blob.open tmpdir: tmpdir, block
  end

  # Executes a system command, capturing its binary output in a tempfile. Yields the tempfile.
  #
  # Use this method to shell out to a system library (e.g. muPDF or FFmpeg) for preview image
  # generation. The resulting tempfile can be used as the +:io+ value in an attachable Hash:
  #
  #   def preview
  #     download_blob_to_tempfile do |input|
  #       draw "my-drawing-command", input.path, "--format", "png", "-" do |output|
  #         yield io: output, filename: "#{blob.filename.base}.png", content_type: "image/png"
  #       end
  #     end
  #   end
  #
  # The output tempfile is opened in the directory returned by #tmpdir.
  # :doc:
  def draw(preview, argv \\ [], block) do
    open_tempfile(preview, fn fd, file_path ->
      capture(preview, argv, to: fd)
      block.(file_path, fd)
    end)

    # open_tempfile do |file|
    #  instrument :preview, key: blob.key do
    #    capture(*argv, to: file)
    #  end

    #  yield file
    # end
  end

  def open_tempfile(_previewer, block) do
    {:ok, fd, file_path} = Temp.open("ActiveStorage-")
    # {:ok, tempfile} = Temp.path(%{prefix: "ActiveStorage-"})
    # tempfile = Tempfile.open("ActiveStorage-", tmpdir)
    # IO.puts(file_path)
    # IO.write fd, "some content"
    try do
      block.(fd, file_path)
    after
      File.close(fd)
    end

    # begin
    #  yield tempfile
    # ensure
    #  tempfile.close!
    # end
  end

  def instrument(_operation, _payload = %{}, _block) do
    # ActiveSupport::Notifications.instrument "#{operation}.active_storage", payload, &block
  end

  def capture(preview, argv, to: to) do
    [bin | cmd] = argv
    # path = System.find_executable(bin)
    # port = Port.open({:spawn_executable, path}, [:binary, args: cmd])

    case System.cmd(bin, cmd) do
      {out, 0} ->
        IO.binwrite(to, out)

      {err, status} ->
        # TODO: get the error and print it in the Exception message
        raise ActiveStorage.PreviewError, message: "Failed (status ): err"
    end

    # to.binmode
    # open_tempfile do |err|
    #  IO.popen(argv, err: err) { |out| IO.copy_stream(out, to) }
    #  err.rewind
    #  unless $?.success?
    #    raise PreviewError, "#{argv.first} failed (status #{$?.exitstatus}): #{err.read.to_s.chomp}"
    #  end
    # end
    # to.rewind
  end

  # :doc:
  def logger do
    # ActiveStorage.logger
  end

  # :doc:
  def tmpdir do
    "/tmp"
    # Dir.tmpdir()
  end
end
