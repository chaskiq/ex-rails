# frozen_string_literal: true

defmodule ActiveStorage.Service.Configurator do
  # attr_reader :configurations

  def build(service_name) do
    # new(configurations).instance_build(service_name)

    instance_build(service_name, Application.fetch_env!(:active_storage, :services)
  end

  # def initialize(configurations) do
  # def new(_configurations) do
  #   # @configurations = configurations.deep_symbolize_keys
  # end

  def instance_build(service_name, service_configs) do
    # config = config_for(service_name.to_sym)

    case Keyword.get(service_configs, service_name) do
      nil ->
        raise "Source not found: #{service_name}.  Configured options: #{inspect(Map.keys(services))}."

      service_config ->
        resolve(service_config)
        # %{
        #   module: resolve(service_config)
        #   config: service_config
        # }
    end

    # .build(
    #  **config, configurator: self, name: service_name
    # )
  end

  defp config_for(service_name) do
    # configurations.fetch name do
    #  raise "Missing configuration for the #{name.inspect} Active Storage service. Configurations available for #{configurations.keys.inspect}"
    # end
  end

  defp resolve(service_config) do
    if Map.has_key?(service_config, :service) do
      class_name = class_name |> Macro.camelize()

      Module.concat(["ActiveStorage.Service.#{service_config.service}Service"])
    else
      raise "Missing service adapter for #{inspect(service_config)}."
    end

    # require "active_storage/service/#{class_name.to_s.underscore}_service"
    # ActiveStorage::Service.const_get(:"#{class_name.camelize}Service")
    # rescue LoadError
    # raise "Missing service adapter for #{class_name.inspect}"
  end
end
