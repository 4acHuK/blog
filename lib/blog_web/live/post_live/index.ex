defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view

  alias Blog.Repo
  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Accounts

  @impl true
  def mount(_params, session, socket) do
    with user_token <- session["user_token"],
         current_user <- Accounts.get_user_by_session_token(user_token) do
      {:ok, stream(socket |> assign(:current_user, current_user), :posts, Posts.list_posts_with_users())}
    else
      _ -> {:ok, stream(socket, :posts, Posts.list_posts_with_users())}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id, "return_to" => return_to}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Posts.get_post!(id))
    |> assign(:return_to, return_to)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
    |> assign(:return_to, "/")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
    |> assign(:return_to, "/")
  end

  @impl true
  def handle_info({BlogWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Posts.get_post!(id)
    {:ok, _} = Posts.delete_post(post)

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
end
