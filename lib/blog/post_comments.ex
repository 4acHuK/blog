defmodule Blog.PostComments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Blog.Repo
  alias Blog.Posts.PostComment

  @doc """
  Returns the list of comments for a given post ID, preloading the user.
  """
  def list_comments_for_post(post_id) do
    PostComment
    |> where([c], c.post_id == ^post_id)
    |> order_by([c], desc: c.inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Gets a single comment.
  Raises `Ecto.NoResultsError` if the Comment does not exist.
  """
  def get_comment!(id), do: Repo.get!(PostComment, id)

  @doc """
  Creates a comment.
  """
  def create_comment(user, post, attrs \\ %{}) do
    %PostComment{}
    |> PostComment.changeset(attrs)
    |> put_assoc(:user, user)
    |> put_assoc(:post, post)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.
  """
  def update_comment(%PostComment{} = comment, attrs) do
    comment
    |> PostComment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.
  """
  def delete_comment(%PostComment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.
  """
  def change_comment(%PostComment{} = comment, attrs \\ %{}) do
    PostComment.changeset(comment, attrs)
  end

  @doc """
  Checks if comment created by user

  ## Examples

      iex> created_by_user?(user, comment)
      true
      iex> created_by_user?(user, comment)
      false

  """
  def created_by_user?(user, comment) do
    comment.user_id == user.id
  end
end
