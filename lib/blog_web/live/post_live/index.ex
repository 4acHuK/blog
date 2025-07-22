defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Accounts

  @impl true
  def mount(_params, session, socket) do


#    user_token = session["user_token"]
#    current_user = Accounts.get_user_by_session_token(user_token)

    with user_token <- session["user_token"],
         current_user <- Accounts.get_user_by_session_token(user_token) do
      {:ok, stream(socket |> assign(:current_user, current_user), :posts, Posts.list_posts_with_users())}
    else
      _ -> {:ok, stream(socket, :posts, Posts.list_posts_with_users())}
    end


#           |> assign(:post_image_url, get_post_image_url(post))}

#    case session["user_token"] do
#      nil ->
#        {:ok, stream(socket, :posts, Posts.list_posts_with_users())}
#
#      token ->
#        case Accounts.get_user_by_session_token(token) do
#          %Accounts.User{} = user ->
#            socket = assign(socket, :current_user, user)
#            {:ok, stream(socket, :posts, Posts.list_posts_with_users())}
#
#          _ ->
#            {:ok, stream(socket, :posts, Posts.list_posts_with_users())}
#        end
#    end

#    {:ok, stream(socket |> assign(:current_user, current_user), :posts, Posts.list_posts_with_users())}
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
end
