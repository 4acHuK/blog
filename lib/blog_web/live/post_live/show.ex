defmodule BlogWeb.PostLive.Show do
  use BlogWeb, :live_view

  alias Blog.{Repo, Posts, PostComments}
  alias Blog.Posts.PostComment

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Posts.get_post_with_user!(id))
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    post = Posts.get_post_with_user!(id)
    socket
    |> assign(:post, post)
  end

  defp apply_action(socket, :new_post_comment, %{"post_id" => post_id}) do
    socket
    |> assign(:page_title, "New Post Comment")
    |> assign(:post_comment, %PostComment{})
    |> assign(:post, Posts.get_post_with_user!(post_id))
  end

  defp apply_action(socket, :edit_post_comment, %{"post_id" => post_id, "id" => id}) do
    socket
    |> assign(:page_title, "Edit Post Comment")
    |> assign(:post_comment, PostComments.get_comment!(id))
    |> assign(:post, Posts.get_post_with_user!(post_id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Posts.get_post!(id)
    {:ok, _} = Posts.delete_post(post)

    {:noreply, socket |> push_navigate(to: ~p"/")}
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
end
