defmodule Blog.PostCommentsTest do
  use Blog.DataCase

  alias Blog.{Posts, PostComments, Accounts}
  alias Blog.Posts.PostComment

  import Blog.PostsFixtures
  import Blog.AccountsFixtures

  describe "comments" do
    setup do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      {:ok, user: user, post: post}
    end

    test "create_comment/2 with valid data creates a comment", %{user: user, post: post} do
      valid_attrs = %{body: "this is a comment"}

      assert {:ok, comment} = PostComments.create_comment(user, post, valid_attrs)
      assert comment.body == "this is a comment"
      assert comment.user_id == user.id
      assert comment.post_id == post.id
    end

    test "create_comment/2 with invalid data returns error changeset", %{user: user, post: post} do
      invalid_attrs = %{body: ""}

      assert {:error, %Ecto.Changeset{}} =
               PostComments.create_comment(user, post, invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment", %{user: user, post: post} do
      {:ok, comment} = PostComments.create_comment(user, post, %{body: "comment for update"})
      update_attrs = %{body: "updated comment"}

      assert {:ok, %PostComment{} = comment} = PostComments.update_comment(comment, update_attrs)
      assert comment.body == "updated comment"
    end

    test "update_comment/2 with invalid data returns error changeset", %{user: user, post: post} do
      {:ok, comment} = PostComments.create_comment(user, post, %{body: "comment for update"})
      invalid_attrs = %{body: ""}

      assert {:error, %Ecto.Changeset{}} = PostComments.update_comment(comment, invalid_attrs)
      assert comment.body == PostComments.get_comment!(comment.id).body
    end

    test "list_comments_for_post/1 returns all comments for the post", %{user: user, post: post} do
      {:ok, comment1} = PostComments.create_comment(user, post, %{body: "first"})
      {:ok, comment2} = PostComments.create_comment(user, post, %{body: "second"})

      comments = PostComments.list_comments_for_post(post.id)

      assert Enum.map(comments, & &1.id) |> Enum.sort() ==
               [comment1.id, comment2.id] |> Enum.sort()
    end

    test "delete_comment/1 deletes the comment", %{user: user, post: post} do
      {:ok, comment} = PostComments.create_comment(user, post, %{body: "delete me"})
      assert {:ok, %PostComment{}} = PostComments.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> PostComments.get_comment!(comment.id) end
    end
  end
end
