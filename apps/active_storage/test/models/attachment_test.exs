defmodule AttachmentTest do
  use ExUnit.Case, async: false

  setup do
    user = User.create!(%{name: "Josh"})
    {:ok, user: user}
  end

  # teardown { ActiveStorage::Blob.all.each(&:delete) }

  @tag skip: "this test is incomplete"
  test "analyzing a directly-uploaded blob after attaching it", %{user: user} do
    blob = ActiveStorageTestHelpers.directly_upload_file_blob(filename: "racecar.jpg")
    assert ActiveStorage.Blob.analyzed?(blob) != true
    # assert_not blob.analyzed?
    #
    # perform_enqueued_jobs do
    #   @user.highlights.attach(blob)
    # end
    #
    # assert blob.reload.analyzed?
    # assert_equal 4104, blob.metadata[:width]
    # assert_equal 2736, blob.metadata[:height]
  end

  test "attaching a un-analyzable blob", %{user: user} do
    blob = ActiveStorageTestHelpers.create_blob()

    assert blob |> ActiveStorage.Blob.analyzed?() != true

    attachments = User.highlights(user)

    attached_record = attachments.__struct__.attach(attachments, blob)

    blob = blob |> blob.__struct__.reload!

    assert blob |> ActiveStorage.Blob.analyzed?() == true

    # blob = create_blob(filename: "blank.txt")
    #
    # assert_not_predicate blob, :analyzed?
    #
    # assert_no_enqueued_jobs do
    #   @user.highlights.attach(blob)
    # end
    #
    # assert_predicate blob.reload, :analyzed?
  end

  @tag skip: "this test is incomplete"
  test "mirroring a directly-uploaded blob after attaching it" do
    # with_service("mirror") do
    #   blob = directly_upload_file_blob
    #   assert_not ActiveStorage::Blob.service.mirrors.second.exist?(blob.key)
    #
    #   perform_enqueued_jobs do
    #     @user.highlights.attach(blob)
    #   end
    #
    #   assert ActiveStorage::Blob.service.mirrors.second.exist?(blob.key)
    # end
  end

  test "directly-uploaded blob identification for one attached occurs before validation", %{
    user: user
  } do
    blob =
      ActiveStorageTestHelpers.directly_upload_file_blob(
        filename: "racecar.jpg",
        content_type: "application/octet-stream"
      )

    assert_blob_identified_before_owner_validated(user, blob, "image/jpeg", fn ->
      avatar = user.__struct__.avatar(user)
      user = avatar.__struct__.attach(avatar, blob)
    end)

    # blob = directly_upload_file_blob(filename: "racecar.jpg", content_type: "application/octet-stream")
    #
    # assert_blob_identified_before_owner_validated(@user, blob, "image/jpeg") do
    #   @user.avatar.attach(blob)
    # end
  end

  test "directly-uploaded blob identification for many attached occurs before validation", %{
    user: user
  } do
    blob =
      ActiveStorageTestHelpers.directly_upload_file_blob(
        filename: "racecar.jpg",
        content_type: "application/octet-stream"
      )

    assert_blob_identified_before_owner_validated(user, blob, "image/jpeg", fn ->
      highligths = user.__struct__.highlights(user)
      user = highligths.__struct__.attach(highligths, blob)
    end)

    # blob = directly_upload_file_blob(filename: "racecar.jpg", content_type: "application/octet-stream")
    #
    # assert_blob_identified_before_owner_validated(@user, blob, "image/jpeg") do
    #   @user.highlights.attach(blob)
    # end
  end

  @tag skip: "this test is incomplete"
  test "directly-uploaded blob identification for one attached occurs outside transaction" do
    # blob = directly_upload_file_blob(filename: "racecar.jpg")
    #
    # assert_blob_identified_outside_transaction(blob) do
    #   @user.avatar.attach(blob)
    # end
  end

  @tag skip: "this test is incomplete"
  test "directly-uploaded blob identification for many attached occurs outside transaction" do
    # blob = directly_upload_file_blob(filename: "racecar.jpg")
    #
    # assert_blob_identified_outside_transaction(blob) do
    #   @user.highlights.attach(blob)
    # end
  end

  test "getting a signed blob ID from an attachment", %{user: user} do
    blob = ActiveStorageTestHelpers.create_blob()
    avatar = user.__struct__.avatar(user)
    user = avatar.__struct__.attach(avatar, blob)
    signed_id = User.avatar(user).__struct__.signed_id(User.avatar(user))

    assert blob == ActiveStorage.Blob.find_signed!(signed_id)
    assert blob == ActiveStorage.Blob.find_signed(signed_id)

    # blob = create_blob
    # @user.avatar.attach(blob)
    #
    # signed_id = @user.avatar.signed_id
    # assert_equal blob, ActiveStorage::Blob.find_signed!(signed_id)
    # assert_equal blob, ActiveStorage::Blob.find_signed(signed_id)
  end

  test "getting a signed blob ID from an attachment with a custom purpose", %{user: user} do
    blob = ActiveStorageTestHelpers.create_blob()

    avatar = user.__struct__.avatar(user)
    user = avatar.__struct__.attach(avatar, blob)

    signed_id =
      User.avatar(user).__struct__.signed_id(
        User.avatar(user),
        purpose: "custom_purpose"
      )

    assert blob == ActiveStorage.Blob.find_signed!(signed_id, "custom_purpose")

    # blob = create_blob
    # @user.avatar.attach(blob)
    #
    # signed_id = @user.avatar.signed_id(purpose: :custom_purpose)
    # assert_equal blob, ActiveStorage::Blob.find_signed!(signed_id, purpose: :custom_purpose)
  end

  test "getting a signed blob ID from an attachment with a expires_in", %{user: user} do
    blob = ActiveStorageTestHelpers.create_blob()

    avatar = user.__struct__.avatar(user)
    user = avatar.__struct__.attach(avatar, blob)

    t = NaiveDateTime.add(NaiveDateTime.local_now(), 60, :second)
    signed_id = User.avatar(user).__struct__.signed_id(User.avatar(user), expires_in: t)
    assert blob == ActiveStorage.Blob.find_signed!(signed_id)

    # blob = create_blob
    # @user.avatar.attach(blob)
    #
    # signed_id = @user.avatar.signed_id(expires_in: 1.minute)
    # assert_equal blob, ActiveStorage::Blob.find_signed!(signed_id)
  end

  test "fail to find blob within expiration date", %{user: user} do
    blob = ActiveStorageTestHelpers.create_blob()

    avatar = user.__struct__.avatar(user)
    user = avatar.__struct__.attach(avatar, blob)

    t = NaiveDateTime.add(NaiveDateTime.local_now(), -120, :second)
    signed_id = User.avatar(user).__struct__.signed_id(User.avatar(user), expires_in: t)
    assert nil == ActiveStorage.Blob.find_signed(signed_id)

    # blob = create_blob
    # @user.avatar.attach(blob)
    #
    # signed_id = @user.avatar.signed_id(expires_in: 1.minute)
    # travel 2.minutes
    # assert_nil ActiveStorage::Blob.find_signed(signed_id)
  end

  test "signed blob ID backwards compatibility", %{user: user} do
    blob = ActiveStorageTestHelpers.create_blob()

    avatar = user.__struct__.avatar(user)
    user = avatar.__struct__.attach(avatar, blob)

    signed_id_generated_old_way = ActiveStorage.Verifier.sign(user.avatar_attachment.blob_id)
    assert blob == ActiveStorage.Blob.find_signed!(signed_id_generated_old_way)

    # blob = create_blob
    # @user.avatar.attach(blob)
    # signed_id_generated_old_way = ActiveStorage.verifier.generate(@user.avatar.blob.id, purpose: :blob_id)
    # assert_equal blob, ActiveStorage::Blob.find_signed!(signed_id_generated_old_way)
  end

  test "attaching with strict_loading and getting a signed blob ID from an attachment", %{
    user: user
  } do
    blob = ActiveStorageTestHelpers.create_blob()
    avatar = user.__struct__.avatar(user)
    user = avatar.__struct__.attach(avatar, blob)

    signed_id = User.avatar(user).__struct__.signed_id(User.avatar(user))
    assert blob == ActiveStorage.Blob.find_signed!(signed_id)

    ###########
    # blob = create_blob
    # @user.strict_loading!(true)
    # @user.avatar.attach(blob)
    #
    # signed_id = @user.avatar.signed_id
    # assert_equal blob, ActiveStorage::Blob.find_signed(signed_id)
  end

  @tag skip: "this test is incomplete"
  test "can destroy attachment without existing relation" do
    # blob = create_blob
    # @user.highlights.attach(blob)
    # attachment = @user.highlights.find_by(blob_id: blob.id)
    # attachment.update_attribute(:name, "old_highlights")
    # assert_nothing_raised { attachment.destroy }
  end

  defp assert_blob_identified_before_owner_validated(owner, blob, content_type, block) do
    validated_content_type = nil

    # owner.class.validate do
    #  validated_content_type ||= blob.content_type
    # end

    validated_content_type = blob.content_type

    b = block.()

    # assert content_type == validated_content_type
    # blob.reload.content_type
    assert content_type == blob.__struct__.reload!(blob).content_type
  end

  #
  defp assert_blob_identified_outside_transaction(blob, block \\ nil) do
    #  baseline_transaction_depth = ActiveRecord::Base.connection.open_transactions
    #  max_transaction_depth = -1
    #
    #  track_transaction_depth = ->(*) do
    #    max_transaction_depth = [ActiveRecord::Base.connection.open_transactions, max_transaction_depth].max
    #  end
    #
    #  blob.stub(:identify_without_saving, track_transaction_depth, &block)
    #
    #  assert_equal 0, (max_transaction_depth - baseline_transaction_depth)
  end
end
