# frozen_string_literal: true

defmodule ActiveStorage.Service.Configurator do
  defstruct [:configurations]

  def new(configurations) do
    %__MODULE__{configurations: configurations}
  end

  def build(service_name, configurations) do
    config_instance = new(configurations)
    instance_build(service_name, config_instance)
  end

  def instance_build(service_key, configurator = %__MODULE__{configurations: service_configs}) do
    # config = config_for(service_name.to_sym)
    case Keyword.get(service_configs, service_key) do
      nil ->
        raise "Source not found: #{service_key}."

      _ ->
        config = service_configs |> Keyword.get(service_key)
        service_name = config |> Keyword.get(:service)
        r = resolve(service_name)

        r.build(
          %{
            configurator: configurator,
            name: service_key,
            service: r
          },
          config
        )
    end

    # .build(
    #  **config, configurator: self, name: service_name
    # )
  end

  def config_for(_name) do
    # configurations.fetch name do
    #  raise "Missing configuration for the #{name.inspect} Active Storage service. Configurations available for #{configurations.keys.inspect}"
    # end
  end

  defp resolve(nil) do
    raise "no service found!"
  end

  defp resolve(class_name) do
    class_name = class_name |> Macro.camelize()
    Module.concat(["ActiveStorage.Service.#{class_name}Service"])
    # require "active_storage/service/#{class_name.to_s.underscore}_service"
    # ActiveStorage::Service.const_get(:"#{class_name.camelize}Service")
    # rescue LoadError
    # raise "Missing service adapter for #{class_name.inspect}"
  end
end
