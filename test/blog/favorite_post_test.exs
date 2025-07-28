defmodule Blog.Posts.FavoritePostTest do
  use Blog.DataCase

  alias Blog.Posts
  alias Blog.Posts.{PostFavorite}
  alias Blog.Repo

  import Blog.AccountsFixtures
  import Blog.PostsFixtures

  describe "favorites" do
    setup do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      {:ok, user: user, post: post}
    end

    test "favorites a post", %{user: user, post: post} do
      assert {:ok, post} = Posts.favorite_post(user, post)

      favorite = Repo.get_by(PostFavorite, user_id: user.id, post_id: post.id)
      assert favorite
    end

    test "unfavorites a post", %{user: user, post: post} do
      {:ok, _} = Posts.favorite_post(user, post)

      assert {:ok, post} = Posts.unfavorite_post(user, post)
      assert Repo.get_by(PostFavorite, user_id: user.id, post_id: post.id) == nil
    end

    test "favorite?/2 returns true if post is favorited", %{user: user, post: post} do
      assert Posts.favorite?(user, post) == false

      {:ok, _} = Posts.favorite_post(user, post)

      assert Posts.favorite?(user, post) == true
    end

    test "does not duplicate favorites", %{user: user, post: post} do
      {:ok, _} = Posts.favorite_post(user, post)
      assert {:error, _} = Posts.favorite_post(user, post)

      count =
        from(f in PostFavorite, where: f.user_id == ^user.id and f.post_id == ^post.id)
        |> Repo.aggregate(:count, :id)

      assert count == 1
    end
  end
end
