# ExActiveStorage (WIP)

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `active_storage` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:active_storage, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/active_storage](https://hexdocs.pm/active_storage).

## configuration:

### config:

#### `config/config.ex`

```elixir
config :active_storage, repo: MyApp.Repo

config :my_app, :sources, %{
  service: "amazon",
  amazon: %{
    service: :s3,
    # Warning: Environment variables set at compile time unless in runtime.exs
    region: System.get_env("AWS_S3_REGION"),
    access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
    secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")
  },
  local: %{service: "Disk", root: "storage"},
  test: %{
    service: "Disk",
    root: "tmp/storage"
  }
}
```

#### `config/(dev|test|prod).ex`

```
config :active_storage, :default_source, :amazon
```

### Setup

Any Ecto schemas with attachments should have a `record_type` function in the schema module.  `ActiveRecord` has a `classify` method which would take a table name (like `people`) and turn it into a module name (like `Person`).  In Elixir / Ecto explicit definitions are preferred over automatic convention in such cases.  An example:

```elixir
defmodule MyApp.MyContext.Person do
  use Ecto.Schema

  schema "people" do
    # ...
  end

  # Yes, this is the same as the suffix of the module, but it won't always be so.
  # This corresponds directly to the `record_type` stored in the `active_storage_attachments` table.
  def record_type do
    "Person"
  end
```

### Usage

#### Attaching from HTTP requests

Ruby: `user.avatar.attach(params[:avatar])`
Elixir: `?????`

Ruby: `message.images.attach(params[:images])`
Elixir: `?????`

#### TODO: Attaching from File/IO Objects

Ruby:
    @message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')

has_one?

#### Fetching files

Ruby: `user.avatar`
Elixir: `ActiveStorage.get_attachment(user, "avatar")

Ruby: `user.images`
Elixir: `ActiveStorage.get_attachments(post, "images")

#### Checking if attachments exist

Ruby: `user.avatar.attached?`
Elixir: `ActiveStorage.attached?(user, "avatar")

Ruby: `message.images.attached?`
Elixir: `ActiveStorage.attached?(message, "images")

#### TODO: Defining attachments in Ecto schemas

#### TODO: Defining attachment variants

Ruby:
    has_one_attached :avatar do |attachable|
      attachable.variant :thumb, resize_to_limit: [100, 100]
    end
    has_many_attached :images do |attachable|
      attachable.variant :thumb, resize_to_limit: [100, 100]
    end

#### Removing attachments

Ruby: `user.avatar.purge`
Elixir: `ActiveStorage.purge_attachment(user, "avatar")

TODO: `has_many`

TODO? Should we support an alternative to `purge_later`?  Phoenix / Elixir doesn't have something like ActiveJob, but maybe with Elixir `Task`s?

#### Redirect

Ruby: `url_for(user.avatar)`

Ruby: `rails_blob_path(user.avatar, disposition: "attachment")`

TODO: Something for Plug/Phoenix?  Separate library?

See note about XSS attacks: https://edgeguides.rubyonrails.org/active_storage_overview.html#redirect-mode

#### TODO: Proxy mode

https://edgeguides.rubyonrails.org/active_storage_overview.html#redirect-mode

CDN instructions?

#### TODO: Authenticated controllers?

Leave to Plug/Phoenix?


#### TODO: Downloading files

https://edgeguides.rubyonrails.org/active_storage_overview.html#downloading-files

#### TODO: Analyzing files

https://edgeguides.rubyonrails.org/active_storage_overview.html#analyzing-files

#### TODO: Displaying Images, Videos, and PDFs

Phoenix thing???

https://edgeguides.rubyonrails.org/active_storage_overview.html#displaying-images-videos-and-pdfs

#### TODO: Direct Uploads

https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-uploads

`activestorage.js`

CORS config

#### TODO: Testing

https://edgeguides.rubyonrails.org/active_storage_overview.html#testing

#### TODO: Implementing Support for Other Cloud Services

https://edgeguides.rubyonrails.org/active_storage_overview.html#implementing-support-for-other-cloud-services

#### TODO: Purging Unattached Uploads

https://edgeguides.rubyonrails.org/active_storage_overview.html#purging-unattached-uploads


### router:

```elixir
  scope "/", MyAppWeb do
    pipe_through :browser

    get "/active_storage/blobs/redirect/:signed_id", ActiveStorageController, :show
```

## direct upload

### Absinthe:

```elixir
mutation do
  field :create_direct_upload, :direct_upload_response do
    arg(:input, non_null(:direct_upload))
    resolve(&ActiveStorage.graphql_resolver/3)
  end
end
```

### usage blob

```elixir
  {:ok, file} = File.read("./uploads/github-social.png")
  filename = "github-social.png"
  {mime, w, h, _kind} = ExImageInfo.info(file)
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

      ActiveStorage.url(r) # direct url temporal to aws
      ActiveStorage.service_url(r) # redirect url

      a = ActiveStorage.Blob.Representable.variant(r, %{resize_to_limit: "100x100"}) |> ActiveStorage.Variant.processed()
```


### Development

use docker, run:

> docker-compose up
