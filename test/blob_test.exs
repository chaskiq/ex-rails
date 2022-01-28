defmodule ActiveStorageBlobTest do
  use Chaskiq.DataCase
  use Oban.Testing, repo: Chaskiq.Repo

  describe "blob" do
    test "upload " do
      {:ok, file} = File.read("./uploads/github-social.png")
      filename = "github-social.png"
      {mime, _w, _h, _kind} = ExImageInfo.info(file)

      blob = %ActiveStorage.Blob{}

      r =
        ActiveStorage.Blob.create_and_upload!(blob, %{
          io: file,
          filename: filename,
          content_type: mime,
          metadata: nil,
          service_name: "amazon",
          identify: true
        })

      assert ActiveStorage.url(r)
      assert ActiveStorage.service_url(r)

      a = ActiveStorage.Blob.Representable.variant(r, %{resize_to_limit: "100x100"})

      a |> ActiveStorage.Variant.processed()
    end
  end

  describe "variation" do
    test "encode transformations" do
      {:ok, "somekey"} = ActiveStorage.Variation.decode(ActiveStorage.Variation.encode("somekey"))
    end

    test "new" do
      a =
        ActiveStorage.Variation.new(%{
          resize_to_limit: "100x100",
          monochrome: true,
          trim: true,
          rotate: "-90"
        })

      encoded = ActiveStorage.Variation.key(a)
      assert encoded
      # ActiveStorage.Variation.wrap("somekey")
      assert ActiveStorage.Variation.decode(encoded)
    end
  end
end
