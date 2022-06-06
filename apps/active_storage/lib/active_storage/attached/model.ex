defmodule ActiveStorage.Attached.Model do
  # @callback new_changeset(resource :: term, attrs :: term) :: %Ecto.Changeset{}
  # @callback new_changeset(resource :: term, attrs :: term, parent_resource :: term) ::
  #            %Ecto.Changeset{}
  #
  defmacro __using__(_opts) do
    quote do
      # @behaviour ActiveStorage.Attached.Model

      def attachment_changes(struct) do
        changes =
          case struct |> Map.get(:attachment_changes) do
            %{} = map -> map
            _ -> %{}
          end

        struct |> Map.put(:attachment_changes, changes)
      end

      def changed_for_autosave?(struct) do
        # super || attachment_changes(struct) |> Enum.any?
        attachment_changes(struct) |> Map.get(:attachment_changes) |> Enum.any?()
      end

      def save_with_attachment(struct, name) do
        case struct.attachment_changes[name] do
          nil ->
            nil

          m ->
            IO.inspect("SAVE to #{m.__struct__}")
            m.__struct__.save(m)
        end

        # after_save { attachment_changes[name.to_s]&.save }
      end

      def save_with_attachments(struct, name) do
        case struct.attachment_changes[name] do
          nil ->
            nil

          m ->
            m.__struct__.save(m)
        end

        # after_save { attachment_changes[name.to_s]&.save }
      end

      # def initialize_dup(*) do
      #  super
      #  @active_storage_attached = nil
      #  @attachment_changes = nil
      # end

      # def reload(*) do
      #  super.tap { @attachment_changes = nil }
      # end
    end
  end
end

defmodule ActiveStorage.Attached.HasOne do
  @moduledoc """
  The HasOne module
  """
  defmacro __using__(opts) do
    name = opts |> Keyword.get(:name)

    quote do
      import Ecto.Query, warn: false

      def unquote(:"#{name}")(struct) do
        active_storage_attached =
          case struct |> Map.get(:active_storage_attached) do
            %{} = map -> map
            _ -> %{}
          end

        struct = struct |> Map.put(:active_storage_attached, active_storage_attached)

        attached = ActiveStorage.Attached.One.new(unquote(name), struct)

        # active_storage_attached =
        #  active_storage_attached
        #  |> Map.merge(%{
        #    :"#{unquote(name)}" => attached, struct)
        #  })

        # @active_storage_attached ||= {}
        # @active_storage_attached[:#{name}] ||= ActiveStorage::Attached::One.new("#{name}", self)
      end

      def unquote(:"assign_#{name}")(struct, attachable \\ nil) do
        struct = attachment_changes(struct)

        new_attachment_changes =
          struct.attachment_changes
          |> Map.put(
            String.to_atom("#{unquote(name)}"),
            if attachable |> is_nil do
              ActiveStorage.Attached.Changes.DeleteOne.new("#{unquote(name)}", struct)
            else
              ActiveStorage.Attached.Changes.CreateOne.new("#{unquote(name)}", struct, attachable)
            end
          )

        struct |> Map.put(:attachment_changes, new_attachment_changes)
      end

      def unquote(:"with_attached_#{name}")(query) do
        from(c in query, preload: [^:"#{unquote(name)}_attachment", :blob])
      end
    end
  end
end

defmodule ActiveStorage.Attached.HasMany do
  @moduledoc """
  The HasMany module
  """
  defmacro __using__(opts) do
    name = opts |> Keyword.get(:name)

    quote do
      import Ecto.Query, warn: false

      def unquote(:"#{name}")(struct) do
        active_storage_attached =
          case struct |> Map.get(:active_storage_attached) do
            %{} = map -> map
            _ -> %{}
          end

        struct = struct |> Map.put(:active_storage_attached, active_storage_attached)

        attached = ActiveStorage.Attached.Many.new(unquote(name), struct)
      end

      def unquote(:"assign_#{name}")(struct, attachable \\ nil) do
        struct = attachment_changes(struct)

        new_attachment_changes =
          struct.attachment_changes
          |> Map.put(
            String.to_atom("#{unquote(name)}"),
            if attachable |> is_nil do
              ActiveStorage.Attached.Changes.DeleteMany.new("#{unquote(name)}", struct)
            else
              ActiveStorage.Attached.Changes.CreateMany.new(
                "#{unquote(name)}",
                struct,
                attachable
              )
            end
          )

        struct |> Map.put(:attachment_changes, new_attachment_changes)
      end

      def unquote(:"with_attached_#{name}")(query) do
        if ActiveStorage.track_variants() do
          from(c in query, preload: [^:"#{unquote(name)}_attachments", blob: :variant_records])
        else
          from(c in query, preload: [^:"#{unquote(name)}_attachments", :blob])
        end
      end
    end
  end
end
