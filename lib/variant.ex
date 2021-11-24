defmodule ExActiveStorage.Variant do
  # import Mogrify
  #
  ## This does operations on an original image:
  # open("input.jpg") |> resize("100x100") |> save(in_place: true)
  #
  ## save/1 creates a copy of the file by default:
  # image = open("input.jpg") |> resize("100x100") |> save
  # IO.inspect(image) # => %Image{path: "/tmp/260199-input.jpg", ext: ".jpg", ...}
  #
  ## Resize to fill
  # open("input.jpg") |> resize_to_fill("450x300") |> save
  #
  ## Resize to limit
  # open("input.jpg") |> resize_to_limit("200x200") |> save
  #
  ## Extent
  # open("input.jpg") |> extent("500x500") |> save
  #
  ## Gravity
  # open("input.jpg") |> gravity("Center") |> save
end
