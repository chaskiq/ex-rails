defmodule ActiveStorage.Service.DiskService do
  defstruct [:root, :public, :name]

  def new(%{root: root, public: public}) do
    %__MODULE__{root: root, public: public}
    # @service = service
  end

  def new(%{root: root, public: public}, _options \\ nil) do
    %__MODULE__{root: root, public: public}
    # @service = service
  end

  # Configure an Active Storage service by name from a set of configurations,
  # typically loaded from a YAML file. The Active Storage engine uses this
  # to set the global Active Storage service when the app boots.
  def configure(service_name, configurations) do
    ActiveStorage.Service.Configurator.build(service_name, configurations)
  end

  ### TODO: this should be a behavior

  # Override in subclasses that stitch together multiple services and hence
  # need to build additional services using the configurator.
  #
  # Passes the configurator and all of the service's config as keyword args.
  #
  # See MirrorService for an example.
  # :nodoc:
  def build(%{configurator: _c, name: n, service: s}, config) do
    new(%{root: config.root, public: true}) |> Map.put(:name, n)
    # new(service_config)
    # .tap do |service_instance|
    #  service_instance.name = name
    # end
  end
end

# <ActiveStorage::Service::DiskService:0x00007fb8d69dece8
# @name=:local,
# @public=false,
# @root="/Users/michelson/Documents/chaskiq/chaskiq/storage">
