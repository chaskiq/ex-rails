# frozen_string_literal: true

defmodule ActiveStorage.Service.Registry do
  # def initialize(configurations) do

  defstruct [:configurator, :services, :configurations]

  def new(configurations) do
    %__MODULE__{
      configurations: configurations,
      services: %{}
    }

    # :ets.lookup(:user_lookup, "doomspork")
    # :ets.insert(:user_lookup, {"doomspork", "Sean", a})
    # @configurations = configurations.deep_symbolize_keys
    # @services = {}
  end

  def fetch(source_name) when source_name |> is_binary() do
    fetch(:"#{source_name}")
  end

  def fetch(source_name, block \\ nil) do
    case ActiveStorage.Blob.services().services |> Map.fetch(source_name) do
      :error ->
        source_config = ActiveStorage.Blob.services().configurations |> Keyword.get(source_name)

        case source_config do
          nil ->
            if block do
              block.(source_name)
            else
              ActiveStorage.Blob.services().configurations |> Keyword.keys()

              raise KeyError,
                    "Missing configuration for the #{source_name} Active Storage service. Configurations available for the configurations.keys.to_sentence services."
            end

          source_config ->
            args = [] |> Keyword.put(source_name, source_config)
            service = ActiveStorage.Service.Configurator.build(source_name, args)

            services = ActiveStorage.Blob.services().services |> Map.put(source_name, service)
            services_config = ActiveStorage.Blob.services() |> Map.put(:services, services)

            ActiveStorage.TableConfig.put(
              "services",
              services_config
            )

            service
        end

      {:ok, service} ->
        service
    end

    # services.fetch(name.to_sym) do |key|
    #   if configurations.include?(key)
    #     services[key] = configurator.build(key)
    #   else
    #     if block_given?
    #       yield key
    #     else
    #       raise KeyError, "Missing configuration for the #{key} Active Storage service. " \
    #         "Configurations available for the #{configurations.keys.to_sentence} services."
    #     end
    #   end
    # end
  end

  # private
  # attr_reader :configurations, :services

  def configurator(_struct) do
    # @configurator ||= ActiveStorage::Service::Configurator.new(configurations)
  end
end
