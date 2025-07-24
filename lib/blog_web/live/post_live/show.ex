defmodule BlogWeb.PostLive.Show do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Accounts

  @impl true
  def mount(_params, session, socket) do
    with user_token <- session["user_token"],
         current_user <- Accounts.get_user_by_session_token(user_token) do
      {:ok, socket |> assign(:current_user, current_user)}
    else
      _ -> {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, Posts.get_post_with_user!(id))}
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
