defmodule BlogWeb.Live.PostLive.Components.CommentsComponent do
  use BlogWeb, :live_component

  alias Blog.Repo
  alias Blog.PostComments

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :stream_id, :"post_comments_#{assigns.post.id}")

    ~H"""
    <div class="text-center">
      <%= if @current_user do %>
        <.link patch={~p"/posts/#{@post}/#{@source}/post_comments/new"}>
          <.button class="w-48 mb-6">Add Comment</.button>
        </.link>
      <% end %>
      <div id={"post_comments_#{@post.id}"} phx-update="stream">
        <div id={"post_comments_#{@post.id}-empty"} class="only:block hidden p-2">
          <p>There is no comments yet</p>
        </div>
        <%= for {id, comment} <- @streams[@stream_id] do %>
          <div id={id} class="border p-2 rounded-md">
            <p class="text-sm"><%= comment.body %></p>
            <p class="text-xs text-gray-500"><%= comment.user.email %> • <%= comment.inserted_at %></p>
            <%= if @current_user && PostComments.created_by_user?(@current_user, comment) do %>
              <div class="px-4 pb-3 text-right space-x-2">
                <.link patch={~p"/posts/#{@post}/#{@source}/post_comments/#{comment}/edit"} class="text-sm text-blue-500 hover:underline">Edit</.link>
                <.link phx-click="delete_comment" phx-value-id={comment.id} phx-target={@myself} data-confirm="Are you sure?" class="text-sm text-blue-500 hover:underline">Delete</.link>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def update(%{comment: comment, comment_stream_id: comment_stream_id}, socket) do
    {:ok, stream_insert(socket, comment_stream_id, comment |> Repo.preload(:user))}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, stream(socket |> assign(assigns), :"post_comments_#{assigns.post.id}", assigns.post_comments |> Repo.preload(:user))}
  end

  @impl true
  def handle_event("delete_comment", %{"id" => id}, socket) do
    comment = PostComments.get_comment!(id)
    post_id = comment.post_id
    {:ok, _} = PostComments.delete_comment(comment)

    {:noreply, stream_delete(socket, :"post_comments_#{post_id}", comment)}
  end
end
