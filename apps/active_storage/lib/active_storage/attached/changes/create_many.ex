defmodule ActiveStorage.Attached.Changes.CreateMany do
  # attr_reader :name, :record, :attachables

  alias Ecto.Multi

  defstruct [:name, :record, :attachables, :blobs, :attachments, :subchanges]

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
    instance = subchanges(instance)

    attachments =
      instance.attachments ||
        instance.subchanges
        |> Enum.map(fn x ->
          x.__struct__.attachment(x)
        end)

    %__MODULE__{instance | attachments: attachments}

    # @attachments ||= subchanges.collect(&:attachment)
  end

  def blobs(instance) do
    instance = subchanges(instance)

    instance.blobs ||
      instance.subchanges
      |> Enum.map(fn x ->
        x.__struct__.blob(x)
      end)

    # @blobs ||= subchanges.collect(&:blob)
  end

  def upload(instance) do
    instance = subchanges(instance)

    instance.subchanges
    |> Enum.each(fn x ->
      x.__struct__.upload(x)
    end)
  end

  def save(instance) do
    assign_associated_attachments(instance)
    # |> reset_associated_blobs
  end

  def subchanges(instance) do
    subchanges =
      instance.subchanges ||
        instance.attachables
        |> Enum.map(fn attachable ->
          build_subchange_from(instance, attachable)
        end)

    %__MODULE__{instance | subchanges: subchanges}

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

    instance = attachments(instance)

    # TODO: this is a little bit ugly
    attachments = persisted_or_new_attachments(instance)

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
      |> ActiveStorage.RepoClient.repo().preload(name)
      |> Ecto.Changeset.change()

    Multi.new()
    |> Multi.update(
      :attachments,
      save_attachments(record_changeset, name, attachments)
    )
    |> Ecto.Multi.run(:after_save, fn _repo, %{attachments: attachments} ->
      attachments
      |> Map.get(name)
      |> Enum.each(fn attachment ->
        attachment = attachment |> ActiveStorage.RepoClient.repo().preload(:blob)
        ActiveStorage.Attachment.after_create_commit(attachment)
      end)

      {:ok, nil}
    end)
    |> ActiveStorage.RepoClient.repo().transaction()

    # |> Multi.insert(:after_save, aaa(account, params))

    # record.public_send("#{name}_attachments=", persisted_or_new_attachments)
  end

  def save_attachments(record_changeset, name, attachments) do
    Ecto.Changeset.put_assoc(record_changeset, name, attachments)
    # |> ActiveStorage.RepoClient.repo().update!
  end

  def reset_associated_blobs(_record) do
    # this resets the active record collection for invalidate the cache for the next queries,
    # I don't know how this would apply into ecto
    # record.public_send("#{name}_blobs").reset
  end

  def persisted_or_new_attachments(instance) do
    instance = attachments(instance)

    instance.attachments
    |> Enum.map(fn struct ->
      struct.attachment
      # case Ecto.get_meta(attachment, :state) do
      #  :loaded ->
      #    attachment
      #  :built ->
      #    attachment
      # end
    end)
    |> Enum.filter(& &1)

    # attachments.select { |attachment| attachment.persisted? || attachment.new_record? }
  end
end
