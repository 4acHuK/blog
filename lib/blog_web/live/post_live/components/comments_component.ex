defmodule YourAppWeb.CommentsComponent do
  use BlogWeb, :live_component

  alias Blog.PostComments

  @impl true
  def update(assigns, socket) do
    comments = PostComments.list_comments_for_post(assigns.post.id)
    {:ok, assign(socket, comments: comments)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= for comment <- @comments do %>
        <div class="border p-2 rounded-md">
          <p class="text-sm text-gray-700"><%= comment.body %></p>
          <p class="text-xs text-gray-500"><%= comment.user.email %> • <%= comment.inserted_at %></p>
        </div>
      <% end %>
    </div>
    """
  end
end
