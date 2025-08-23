defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view

  alias Blog.Repo
  alias Blog.Posts
  alias Blog.PostComments
  alias Blog.Posts.PostComment
  alias Blog.Posts.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :posts, Posts.list_posts_with_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Posts.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  defp apply_action(socket, :new_post_comment, %{"post_id" => post_id}) do
    socket
    |> assign(:page_title, "New Post Comment")
    |> assign(:post_comment, %PostComment{})
    |> assign(:post, Posts.get_post!(post_id))
  end

  defp apply_action(socket, :edit_post_comment, %{"post_id" => post_id, "id" => id}) do
    socket
    |> assign(:page_title, "Edit Post Comment")
    |> assign(:post_comment, PostComments.get_comment!(id))
    |> assign(:post, Posts.get_post!(post_id))
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
