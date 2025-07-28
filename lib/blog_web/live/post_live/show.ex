defmodule BlogWeb.PostLive.Show do
  use BlogWeb, :live_view

  alias Blog.Repo
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

  @impl true
  def handle_event("like", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id)
    {_, post} = Posts.like_post(socket.assigns.current_user, post)

    {:noreply, assign(socket, :post, post |> Repo.preload(:user))}
  end

  @impl true
  def handle_event("unlike", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id)
    {_, post} = Posts.unlike_post(socket.assigns.current_user, post)

    {:noreply, assign(socket, :post, post |> Repo.preload(:user))}
  end

  @impl true
  def handle_event("favorite", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id)
    {:ok, post} = Posts.favorite_post(socket.assigns.current_user, post)

    {:noreply, assign(socket, :post, post |> Repo.preload(:user))}
  end

  @impl true
  def handle_event("unfavorite", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id)
    {_, post} = Posts.unfavorite_post(socket.assigns.current_user, post)

    {:noreply, assign(socket, :post, post |> Repo.preload(:user))}
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
