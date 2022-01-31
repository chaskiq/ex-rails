# frozen_string_literal: true

defmodule ActiveStorage.Service.Registry do
  # def initialize(configurations) do
  def new(_configurations) do
    # @configurations = configurations.deep_symbolize_keys
    # @services = {}
  end

  def fetch(source_name) do
    source_config =
      Application.get_env(:active_storage, :sources)
      |> Keyword.get(source_name |> String.to_existing_atom())

    ActiveStorage.Service.Configurator.build(source_name, source_config)

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

  defp configurator do
    # @configurator ||= ActiveStorage::Service::Configurator.new(configurations)
  end
end
