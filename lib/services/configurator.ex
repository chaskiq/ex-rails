# frozen_string_literal: true

defmodule ActiveStorage.Service.Configurator do
  # attr_reader :configurations

  def build(service_name, configurations) do
    # new(configurations).instance_build(service_name)
    instance_build(service_name, configurations)
  end

  # def initialize(configurations) do
  def new(configurations) do
    # @configurations = configurations.deep_symbolize_keys
  end

  def instance_build(service_name, configurations) do
    # config = config_for(service_name.to_sym)
    resolve(configurations.service)
    # .build(
    #  **config, configurator: self, name: service_name
    # )
  end

  defp config_for(name) do
    # configurations.fetch name do
    #  raise "Missing configuration for the #{name.inspect} Active Storage service. Configurations available for #{configurations.keys.inspect}"
    # end
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
