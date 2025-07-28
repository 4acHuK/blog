defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Blog.Repo
  alias Blog.Posts.{Post, PostLike, PostFavorite}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Returns the list of posts ordered desc by inserted_at and preloaded users.

  ## Examples

      iex> list_posts_with_users()
      [%Post{}, ...]

  """
  def list_posts_with_users do
    Post
    |> order_by(desc: :inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Gets a single post with preloaded user.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post_with_user!(123)
      %Post{}

      iex> get_post_with_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post_with_user!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(user, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc """
  Returns an url to post image.

  ## Examples

      iex> get_post_image_url(post)
      "/uploads/post_images/live_view_upload-1753212949-541889566120-1.jpeg_post%20with%20image_original.jpeg?v=63920432149"

  """
  def get_post_image_url(post) do
    Blog.Uploaders.ImageUploader.url({post.image, post})
  end


  @doc """
  Deletes a post's like.

  ## Examples

      iex> like_post(user, post)
      {:ok, %Post{}}

  """
  def like_post(user, post) do
    %PostLike{}
    |> PostLike.changeset(%{user_id: user.id, post_id: post.id})
    |> Repo.insert()
    |> case do
         {:ok, _like} ->
           post
           |> Ecto.Changeset.change(likes_count: post.likes_count + 1)
           |> Repo.update()
         {:error, _} = err -> err
       end
  end

  @doc """
  Deletes a post's like.

  ## Examples

      iex> unlike_post(post)
      {:ok, %Post{}}

  """
  def unlike_post(user, post) do
    Repo.get_by(PostLike, user_id: user.id, post_id: post.id)
    |> case do
         nil -> {:error, :not_found}
         like ->
           Repo.delete(like)
           post
           |> Ecto.Changeset.change(likes_count: post.likes_count - 1)
           |> Repo.update()
       end
  end


  @doc """
  Checks if user liked the post

  ## Examples

      iex> liked_by_user?(user, post)
      true
      iex> liked_by_user?(user, post)
      false

  """
  def liked_by_user?(user, post) do
    Repo.exists?(from l in PostLike, where: l.user_id == ^user.id and l.post_id == ^post.id)
  end

  @doc """
  Adds post to user's favorites

  ## Examples

      iex> favorite_post(user, post)
      {:ok, %Post{}}

  """
  def favorite_post(user, post) do
    %PostFavorite{}
    |> PostFavorite.changeset(%{user_id: user.id, post_id: post.id})
    |> Repo.insert()
    |> case do
         {:ok, _favorite} -> {:ok, post}
         {:error, _} = err -> err
       end
  end

  @doc """
  Removes post from user's favorites

  ## Examples

      iex> unfavorite_post(user, post)
      {:ok, %Post{}}

  """
  def unfavorite_post(user, post) do
    Repo.get_by(PostFavorite, user_id: user.id, post_id: post.id)
    |> case do
         nil -> {:error, :not_found}
         favorite ->
           Repo.delete(favorite)
           {:ok, post}
       end
  end

  @doc """
  Checks if post in user's favorites

  ## Examples

      iex> favorite?(user, post)
      true
      iex> favorite?(user, post)
      false

  """
  def favorite?(user, post) do
    Repo.exists?(from f in PostFavorite, where: f.user_id == ^user.id and f.post_id == ^post.id)
  end

  @doc """
  Returns the list of user favorite posts

  ## Examples

      iex> list_favorite_posts(user)
      [%Post{}, ...]

  """
  def list_favorite_posts(user) do
    from(p in Post,
      join: f in assoc(p, :favorited_users),
      where: f.id == ^user.id,
      preload: [:user]
    )
    |> Repo.all()
  end
end
