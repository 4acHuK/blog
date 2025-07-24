defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts
  alias Blog.Posts.{Post, PostLike}
  import Blog.PostsFixtures
  import Blog.AccountsFixtures

  describe "posts" do
    @invalid_attrs %{description: nil, title: nil, user_id: nil}

    test "list_posts_with_users/0 returns all posts" do
      post = post_fixture()
      assert Posts.list_posts_with_users() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post_with_user!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{description: "some description", title: "some title"}
      user = user_fixture()

      assert {:ok, %Post{} = post} = Posts.create_post(user, valid_attrs)
      assert post.description == "some description"
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(nil, @invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title"}

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.description == "some updated description"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post_with_user!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end

  describe "post likes" do
    setup do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      {:ok, user: user, post: post}
    end

    test "likes a post successfully", %{user: user, post: post} do
      assert {:ok, post} = Posts.like_post(user, post)

      like = Repo.get_by(PostLike, user_id: user.id, post_id: post.id)
      assert like

      updated_post = Repo.get!(Post, post.id)
      assert updated_post.likes_count == 1
    end

    test "does not like a post twice by same user", %{user: user, post: post} do
      assert {:ok, post} = Posts.like_post(user, post)
      assert {:error, _changeset} = Posts.like_post(user, post)

      updated_post = Repo.get!(Post, post.id)
      assert updated_post.likes_count == 1
    end

    test "liking by another user increases count", %{post: post} do
      user1 = user_fixture()
      user2 = user_fixture(%{email: "another@example.com"})

      assert {:ok, post} = Posts.like_post(user1, post)
      assert {:ok, post} = Posts.like_post(user2, post)

      updated_post = Repo.get!(Post, post.id)
      assert updated_post.likes_count == 2
    end

    test "unlikes a liked post and decrements likes_count", %{user: user, post: post} do
      assert {:ok, post} = Posts.like_post(user, post)

      liked_post = Posts.get_post!(post.id)
      assert liked_post.likes_count == 1
      assert {:ok, post} = Posts.unlike_post(user, post)

      updated_post = Posts.get_post!(post.id)
      assert updated_post.likes_count == 0
    end

    test "unlike without liking first returns error", %{user: user, post: post} do
      assert {:error, :not_found} = Posts.unlike_post(user, post)
    end
  end
end
