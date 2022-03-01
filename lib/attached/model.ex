defmodule ActiveStorage.Attached.Model do
  @callback new_changeset(resource :: term, attrs :: term) :: %Ecto.Changeset{}
  @callback new_changeset(resource :: term, attrs :: term, parent_resource :: term) ::
              %Ecto.Changeset{}

  defmacro __using__(_opts) do
    quote do
      @behaviour ActiveStorage.Attached.Model

      use ActiveStorage.Attached.One
      # use ActsAs.NestedSet.Queries
      # use ActsAs.NestedSet.Multies
    end
  end
end
