defmodule ExActiveStorage.Verifier do
  def sign(message) do
    Plug.Crypto.MessageVerifier.sign(message, secret())
  end

  def verify(message) do
    Plug.Crypto.MessageVerifier.verify(message, secret())
  end

  def secret do
    ChaskiqWeb.Endpoint.config(:secret_key_base)
  end
end
