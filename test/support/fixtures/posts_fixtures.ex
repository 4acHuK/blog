defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  import Blog.AccountsFixtures, only: [user_fixture: 0, valid_user_attributes: 0]

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, post} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title",
        user_id: user.id
      })
      |> Blog.Posts.create_post()

    post
  end
end
