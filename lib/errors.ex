# Generic base class for all Active Storage exceptions.
defmodule ActiveStorage.Error do
  defexception message: "an example error has occurred"
end

# Raised when ActiveStorage::Blob#variant is called on a blob that isn't variable.
# Use ActiveStorage::Blob#variable? to determine whether a blob is variable.
defmodule ActiveStorage.InvariableError do
  defexception message: "an example error has occurred"
end

# Raised when ActiveStorage::Blob#preview is called on a blob that isn't previewable.
# Use ActiveStorage::Blob#previewable? to determine whether a blob is previewable.
defmodule ActiveStorage.UnpreviewableError do
  defexception message: "an example error has occurred"
end

# Raised when ActiveStorage::Blob#representation is called on a blob that isn't representable.
# Use ActiveStorage::Blob#representable? to determine whether a blob is representable.
defmodule ActiveStorage.UnrepresentableError do
  defexception message: "an example error has occurred"
end

# Raised when uploaded or downloaded data does not match a precomputed checksum.
# Indicates that a network error or a software bug caused data corruption.
defmodule ActiveStorage.IntegrityError do
  defexception message: "an example error has occurred"
end

# Raised when ActiveStorage::Blob#download is called on a blob where the
# backing file is no longer present in its service.
defmodule ActiveStorage.FileNotFoundError do
  defexception message: "an example error has occurred"
end

# Raised when a Previewer is unable to generate a preview image.
defmodule ActiveStorage.PreviewError do
  defexception message: "an example error has occurred"
end
