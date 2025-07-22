defmodule BlogWeb.PostLive.FormComponent do
  use BlogWeb, :live_component

  alias Blog.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.live_file_input upload={@uploads[:image]} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
      socket
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png))}
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Posts.change_post(post))
     end)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset = Posts.change_post(socket.assigns.post, post_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        # Add the file extension to the temp file
#        dest = Path.join(Application.app_dir(:my_app, "priv/static/uploads/post_images"), Path.basename(path))
        path_with_extension = path <> String.replace(entry.client_type, "image/", ".")
        File.cp!(path, path_with_extension)
#        File.cp!(path, dest)
        {:ok, path_with_extension}
#        {:ok, dest}
      end)

    file_path = List.first(uploaded_files)

    updated_params =
      if file_path do
        Map.put(post_params, "image", file_path)
      else
        post_params
      end

#    save_post(socket, socket.assigns.action, post_params)
#    save_post(socket, socket.assigns.action, Map.put(post_params, "image", file_path))
    save_post(socket, socket.assigns.action, updated_params)
  end

  defp save_post(socket, :edit, post_params) do
    case Posts.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Posts.create_post(socket.assigns.current_user, post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
