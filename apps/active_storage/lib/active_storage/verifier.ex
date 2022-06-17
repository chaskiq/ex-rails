defmodule ActiveStorage.Verifier do
  def sign(message, options \\ [])

  def sign(message, options) when message |> is_number() do
    message = message |> to_string()
    handle_message_encoding(message, options)
  end

  def sign(message, options) do
    handle_message_encoding(message, options)
  end

  def handle_message_encoding(message, options) do
    defaults = [expires_in: nil, purpose: nil]
    options = Keyword.merge(defaults, options)
    expires_in = Keyword.get(options, :expires_in)
    purpose = Keyword.get(options, :purpose)

    %{
      message: message,
      expires_in: encoded_date(expires_in),
      purpose: purpose
    }
    |> Jason.encode!()
    |> Plug.Crypto.MessageVerifier.sign(secret())
  end

  @spec verify(binary, any) :: {:error, <<_::64, _::_*8>>} | {:ok, any}
  def verify(message, purpose \\ nil) do
    case Plug.Crypto.MessageVerifier.verify(message, secret()) do
      {:ok, encoded} ->
        case Jason.decode!(encoded) do
          nil ->
            {:error, "no encoding"}

          %{"purpose" => nil} = data ->
            handle_verification_with_expiration(data)

          %{"purpose" => p} = data ->
            cond do
              p == purpose -> handle_verification_with_expiration(data)
              true -> {:error, "purpose no matches"}
            end
        end

      _ ->
        {:error, "expired signature"}
    end
  end

  def verify!(message) do
    case verify(message) do
      {:ok, id} ->
        id

      {:error, message} ->
        raise message
    end
  end

  def encoded_date(expires_in) do
    case expires_in do
      nil -> nil
      _ -> expires_in
    end
  end

  def secret do
    Application.get_env(:active_storage, :secret_key_base)
  end

  def handle_verification_with_expiration(%{"expires_in" => nil, "message" => id}) do
    {:ok, id}
  end

  def handle_verification_with_expiration(%{"expires_in" => "", "message" => id}) do
    {:ok, id}
  end

  def handle_verification_with_expiration(%{"expires_in" => expires_in, "message" => id}) do
    date = NaiveDateTime.from_iso8601!(expires_in |> to_string)

    cond do
      date > NaiveDateTime.local_now() ->
        {:ok, id}

      true ->
        {:error, "expired signature! for #{id}"}
    end
  end
end
