# frozen_string_literal: true

# Encapsulates a string representing a filename to provide convenient access to parts of it and sanitization.
# A Filename instance is returned by ActiveStorage::Blob#filename, and is comparable so it can be used for sorting.
defmodule ActiveStorage.Filename do
  defstruct [:filename]

  # include Comparable

  # class << self
  # Returns a Filename instance based on the given filename. If the filename is a Filename, it is
  # returned unmodified. If it is a String, it is passed to ActiveStorage::Filename.new.
  def wrap(filename) do
    case filename do
      %ActiveStorage.Filename{} -> filename
      _ -> __MODULE__.new(filename)
    end

    # filename.kind_of?(self) ? filename : __MODULE__.new(filename)
  end

  # end

  def new(filename) do
    %__MODULE__{
      filename: filename
    }
  end

  # Returns the part of the filename preceding any extension.
  #
  #   ActiveStorage::Filename.new("racecar.jpg").base # => "racecar"
  #   ActiveStorage::Filename.new("racecar").base     # => "racecar"
  #   ActiveStorage::Filename.new(".gitignore").base  # => ".gitignore"
  def base(filename) do
    # File.basename filename, extension_with_delimiter(filename)
    Path.basename(filename.filename, extension_with_delimiter(filename))
  end

  # Returns the extension of the filename (i.e. the substring following the last dot, excluding a dot at the
  # beginning) with the dot that precedes it. If the filename has no extension, an empty string is returned.
  #
  #   ActiveStorage::Filename.new("racecar.jpg").extension_with_delimiter # => ".jpg"
  #   ActiveStorage::Filename.new("racecar").extension_with_delimiter     # => ""
  #   ActiveStorage::Filename.new(".gitignore").extension_with_delimiter  # => ""
  def extension_with_delimiter(filename) do
    Path.extname(filename.filename)
  end

  # Returns the extension of the filename (i.e. the substring following the last dot, excluding a dot at
  # the beginning). If the filename has no extension, an empty string is returned.
  #
  #   ActiveStorage::Filename.new("racecar.jpg").extension_without_delimiter # => "jpg"
  #   ActiveStorage::Filename.new("racecar").extension_without_delimiter     # => ""
  #   ActiveStorage::Filename.new(".gitignore").extension_without_delimiter  # => ""
  def extension_without_delimiter(filename) do
    extension_with_delimiter(filename) |> String.slice(1..-1)
  end

  # alias_method :extension, :extension_without_delimiter

  # Returns the sanitized filename.
  #
  #   ActiveStorage::Filename.new("foo:bar.jpg").sanitized # => "foo-bar.jpg"
  #   ActiveStorage::Filename.new("foo/bar.jpg").sanitized # => "foo-bar.jpg"
  #
  # Characters considered unsafe for storage (e.g. \, $, and the RTL override character) are replaced with a dash.
  def sanitized(filename) do
    # filename.filename.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "�").strip.tr("\u{202E}%$|:;/\t\r\n\\", "-")
    Regex.replace(
      ~r/u{202E}%$|:;\/\t\r\n\\\\/,
      String.trim(filename),
      "-"
    )
  end

  # Returns the sanitized version of the filename.
  def to_s(filename) do
    case filename do
      %ActiveStorage.Filename{filename: f} -> sanitized(f)
      f -> sanitized(f)
    end
  end

  # def as_json(*)
  #  to_s
  # end

  # def to_json
  #  to_s
  # end

  def compare(filename, other) do
    to_s(filename) |> String.downcase() === to_s(other) |> String.downcase()
  end
end
