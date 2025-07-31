defmodule BlogWeb.Components.CommentFormComponent do
  use BlogWeb, :live_component

  alias Blog.PostComments
  alias Blog.Posts.PostComment

  @impl true
  def update(assigns, socket) do
    changeset = PostComments.change_comment(%PostComment{})
    {:ok, assign(socket, assigns) |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"comment" => comment_params}, socket) do
    changeset =
      %PostComment{}
      |> PostComments.change_comment(comment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"comment" => comment_params}, socket) do
    case PostComments.create_comment(socket.assigns.current_user, socket.assigns.post, comment_params) do
      {:ok, _comment} ->
        send(self(), {:comment_created, socket.assigns.post.id})
        {:noreply, push_navigate(socket, to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.modal return_to={@return_to}>
        <h2 class="text-lg font-bold">New Comment</h2>
        <.form
          for={@changeset}
          id="comment-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input field={@changeset[:body]} type="textarea" label="Your comment" />
          <.button>Submit</.button>
        </.form>
      </.modal>
    </div>
    """
  end
end
