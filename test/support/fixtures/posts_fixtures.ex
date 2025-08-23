defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  import Blog.AccountsFixtures

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    user = user_fixture()

    post_attrs =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title",
        user_id: user.id,
        likes_count: 0
      })

    {:ok, post} = Blog.Posts.create_post(user, post_attrs)

    post |> Blog.Repo.preload(:post_comments)
  end
end
