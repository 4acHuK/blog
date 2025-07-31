defmodule BlogWeb.Components.PostActionsComponent do
  use BlogWeb, :live_component

  alias Blog.Repo
  alias Blog.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <%= if @current_user do %>
        <div class="flex">
          <%= if Posts.liked_by_user?(@current_user, @post) do %>
            <div class="px-2 py-2">
              <button phx-click="unlike" phx-value-id={@post.id}>
                <img src="/images/liked.png" class="w-full object-cover max-h-[20px]" />
                <%= @post.likes_count %>
              </button>
            </div>
          <% else %>
            <div class="px-2 py-2">
              <button phx-click="like" phx-value-id={@post.id}>
                <img src="/images/not_liked.png" class="w-full object-cover max-h-[20px]" />
                <%= @post.likes_count %>
              </button>
            </div>
          <% end %>

          <%= if Posts.favorite?(@current_user, @post) do %>
            <div class="px-2 py-2">
              <button phx-click="unfavorite" phx-value-id={@post.id} phx-target={@myself}>
                <img src="/images/favorited.png" class="w-full object-cover max-h-[20px]" />
              </button>
            </div>
          <% else %>
            <div class="px-2 py-2">
              <button phx-click="favorite" phx-value-id={@post.id} phx-target={@myself}>
                <img src="/images/not_favorited.png" class="w-full object-cover max-h-[20px]" />
              </button>
            </div>
          <% end %>
          <div class="px-2 py-2">
            <button class="comments-icon">
              <img src="/images/comment.png" class="w-full object-cover max-h-[20px]" />
            </button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("favorite", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id)
    {:ok, post} = Posts.favorite_post(socket.assigns.current_user, post)

    {:noreply, assign(socket, :post, post |> Repo.preload([:user, :post_favorites]))}
  end

  @impl true
  def handle_event("unfavorite", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id)
    {:ok, post} = Posts.unfavorite_post(socket.assigns.current_user, post)

    {:noreply, assign(socket, :post, post |> Repo.preload([:user, :post_favorites]))}
  end


end
