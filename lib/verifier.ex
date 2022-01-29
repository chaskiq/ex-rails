defmodule ActiveStorage.Verifier do
  def sign(message) do
    Plug.Crypto.MessageVerifier.sign(message, secret())
  end

  def verify(message) do
    Plug.Crypto.MessageVerifier.verify(message, secret())
  end

  def secret do
    Application.get_env(:active_storage, :secret_key_base)
  end
end
