defmodule ActiveStorage.Attached.Changes.CreateMany do
  # attr_reader :name, :record, :attachables

  defstruct [:name, :record, :attachables, :blobs]

  def new(name, record, attachables) do
    p = %__MODULE__{
      name: name,
      record: record,
      attachables: make_array(attachables)
    }

    blobs =
      blobs(p)
      |> Enum.map(fn x ->
        # IO.inspect(x.__struct__)
        case x do
          %Ecto.Changeset{} -> x
          _ -> x.__struct__.identify_without_saving(x)
        end
      end)

    p |> Map.put(:blobs, blobs)
    # @name, @record, @attachables = name, record, Array(attachables)
    # blobs.each(&:identify_without_saving)
    # attachments
  end

  def make_array(opts) do
    cond do
      opts |> is_list -> opts
      true -> [opts]
    end
  end

  def attachments(instance) do
    subchanges(instance)
    |> Enum.map(fn x ->
      x.__struct__.attachment(x)
    end)

    # @attachments ||= subchanges.collect(&:attachment)
  end

  def blobs(instance) do
    instance.blobs ||
      subchanges(instance)
      |> Enum.map(fn x ->
        x.__struct__.blob(x)
      end)

    # @blobs ||= subchanges.collect(&:blob)
  end

  def upload(instance) do
    subchanges(instance)
    |> Enum.each(fn x ->
      x.__struct__.upload(x)
    end)
  end

  def save(instance) do
    assign_associated_attachments(instance)
    # |> reset_associated_blobs
  end

  def subchanges(instance) do
    instance.attachables
    |> Enum.map(fn attachable ->
      build_subchange_from(instance, attachable)
    end)

    # @subchanges ||= attachables.collect { |attachable| build_subchange_from(attachable) }
  end

  def build_subchange_from(instance, attachable) do
    ActiveStorage.Attached.Changes.CreateOneOfMany.new(
      instance.name,
      instance.record,
      attachable
    )
  end

  def assign_associated_attachments(instance) do
    name = String.to_atom("#{instance.name}_attachments")

    # TODO: this is a little bit ugly
    attachments = persisted_or_new_attachments(instance)

    # consoder a multi
    # update changeset blobs
    instance.blobs
    |> Enum.each(fn blob ->
      case blob do
        %Ecto.Changeset{valid?: true, data: _} ->
          blob |> ActiveStorage.RepoClient.repo().update!

        %ActiveStorage.Blob{} ->
          blob

        _ ->
          nil
      end
    end)

    record_changeset =
      instance.record
      |> ActiveStorage.RepoClient.repo().preload(:highlights_attachments)
      |> Ecto.Changeset.change()

    Ecto.Changeset.put_assoc(record_changeset, name, attachments)
    |> ActiveStorage.RepoClient.repo().update!

    # record.public_send("#{name}_attachments=", persisted_or_new_attachments)
  end

  def reset_associated_blobs(record) do
    # this resets the active record collection for invalidate the cache for the next queries,
    # I don't know how this would apply into ecto
    # record.public_send("#{name}_blobs").reset
  end

  def persisted_or_new_attachments(instance) do
    attachments(instance)
    |> Enum.filter(fn attachment ->
      case Ecto.get_meta(attachment, :state) do
        :loaded ->
          attachment

        :built ->
          attachment
      end
    end)

    # attachments.select { |attachment| attachment.persisted? || attachment.new_record? }
  end
end
