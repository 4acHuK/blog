defmodule BlogWeb.Live.PostLive.Components.CommentFormComponent do
  use BlogWeb, :live_component

  alias Blog.PostComments

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="post-comment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:body]} type="text"/>
        <:actions>
          <.button phx-disable-with="Saving...">Save Comment</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{post_comment: post_comment} = assigns, socket) do
    {:ok, assign(socket, assigns) |> assign(:form, to_form(PostComments.change_comment(post_comment)))}
  end

  @impl true
  def handle_event("validate", %{"post_comment" => comment_params}, socket) do
    changeset = PostComments.change_comment(socket.assigns.post_comment, comment_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"post_comment" => comment_params}, socket) do
    save_comment(socket, socket.assigns.action, comment_params)
  end

  defp save_comment(socket, :new_post_comment, comment_params) do
    case PostComments.create_comment(socket.assigns.current_user, socket.assigns.post, comment_params) do
      {:ok, comment} ->
        comment_stream_id = :"post_comments_#{comment.post_id}"
        notify_update_stream(id: "comments-#{comment.post_id}", comment: comment, comment_stream_id: comment_stream_id)

        {:noreply,
          socket
          |> put_flash(:info, "Comment created successfully")
          |> push_patch(to: socket.assigns.patch)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_comment(socket, :edit_post_comment, comment_params) do
    case PostComments.update_comment(socket.assigns.post_comment, comment_params) do
      {:ok, comment} ->
        comment_stream_id = :"post_comments_#{comment.post_id}"
        notify_update_stream(id: "comments-#{comment.post_id}", comment: comment, comment_stream_id: comment_stream_id)

        {:noreply,
          socket
          |> put_flash(:info, "Comment updated successfully")
          |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_update_stream(assigns) do
    send_update(BlogWeb.Live.PostLive.Components.CommentsComponent, assigns)
  end
end
