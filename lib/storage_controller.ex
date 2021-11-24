defmodule ExActiveStorage.Controller do
  # use ChaskiqWeb, :controller

  # action_fallback ChaskiqWeb.FallbackController

  def show(conn, %{"signed_id" => signed_id}) do
    case ExActiveStorage.Verifier.verify(signed_id) do
      {:ok, id} -> conn |> handle_redirect(id)
      _ -> conn |> error_response(422, "Wrong provider key")
    end
  end

  defp handle_redirect(conn, id) do
    presigned =
      ExActiveStorage.get_storage_blob!(id)
      |> ExActiveStorage.presigned_url()

    case presigned do
      {:ok, url} -> conn |> redirect(external: url) |> halt()
      _ -> conn |> error_response(422, "Invalid blob id")
    end
  end

  defp error_response(conn, status, message) do
    conn
    |> put_status(status)
    |> json(%{
      status: :error,
      message: message
    })
  end
end
