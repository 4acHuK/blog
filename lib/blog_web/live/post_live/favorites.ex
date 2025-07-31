defmodule BlogWeb.PostLive.Favorites do
  use BlogWeb, :live_view

  alias Blog.Repo
  alias Blog.Posts
  alias Blog.Accounts

  @impl true
  def mount(_params, session, socket) do
    user_token = session["user_token"]
    current_user = Accounts.get_user_by_session_token(user_token)

    if current_user do
      posts = Posts.list_favorite_posts(current_user)
      {:ok, stream(socket |> assign(:current_user, current_user), :posts, posts)}
    else
      {:ok, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  @impl true
  def handle_event("unfavorite", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id)
    {_, post} = Posts.unfavorite_post(socket.assigns.current_user, post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_event("like", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id)
    {_, post} = Posts.like_post(socket.assigns.current_user, post)

    {:noreply, stream_insert(socket, :posts, post |> Repo.preload(:user))}
  end

  @impl true
  def handle_event("unlike", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id)
    {_, post} = Posts.unlike_post(socket.assigns.current_user, post)

    {:noreply, stream_insert(socket, :posts, post |> Repo.preload(:user))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Posts.get_post!(id)
    {:ok, _} = Posts.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end
end
