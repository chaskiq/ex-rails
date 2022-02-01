defmodule ActiveStorage.ConfiguratorTest do
  use ExUnit.Case, async: false
  alias Ecto.Adapters.SQL
  alias ActiveStorage.{Blob}
  import Ecto.Query

  # setup do
  # ActiveStorage.Test.Setup.cleanup_db()
  # end

  test "builds correct service instance based on service name" do
    service =
      ActiveStorage.Service.Configurator.build(:foo, foo: %{service: "Disk", root: "path"})

    assert service = %ActiveStorage.Service.DiskService{name: "Disk", public: true, root: "path"}
    assert "path", service.root
    # assert_instance_of ActiveStorage.Service.DiskService, service
    # assert_equal "path", service.root
  end

  test "builds correct service instance based on lowercase service name" do
    service =
      ActiveStorage.Service.Configurator.build(:foo, foo: %{service: "disk", root: "path"})

    assert service = %ActiveStorage.Service.DiskService{name: "Disk", root: "path"}
    assert "path", service.root

    # service = ActiveStorage::Service::Configurator.build(:foo, foo: { service: "disk", root: "path" })
    # assert_instance_of ActiveStorage::Service::DiskService, service
    # assert_equal "path", service.root
  end

  test "raises error when passing non-existent service name" do
    assert_raise RuntimeError, fn ->
      ActiveStorage.Service.Configurator.build(:foo, foo: %{})
    end

    # assert_raise RuntimeError do
    #  ActiveStorage::Service::Configurator.build(:bigfoot, {})
    # end
  end
end
