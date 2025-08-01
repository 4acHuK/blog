#defmodule BlogWeb.PostLiveTest do
#  use BlogWeb.ConnCase
#
#  import Phoenix.LiveViewTest
#  import Blog.PostsFixtures
#
#  @create_attrs %{description: "some description", title: "some title"}
#  @update_attrs %{description: "some updated description", title: "some updated title"}
#  @invalid_attrs %{description: nil, title: nil}
#
#  defp create_post(_) do
#    post = post_fixture()
#    %{post: post}
#  end
#
#  describe "Index" do
#    setup [:create_post]
#
#    test "lists all posts", %{conn: conn, post: post} do
#      {:ok, _index_live, html} = live(conn, ~p"/posts")
#
#      assert html =~ "Listing Posts"
#      assert html =~ post.description
#    end
#
#    test "saves new post", %{conn: conn} do
#      {:ok, index_live, _html} = live(conn, ~p"/posts")
#
#      assert index_live |> element("a", "New Post") |> render_click() =~
#               "New Post"
#
#      assert_patch(index_live, ~p"/posts/new")
#
#      assert index_live
#             |> form("#post-form", post: @invalid_attrs)
#             |> render_change() =~ "can&#39;t be blank"
#
#      assert index_live
#             |> form("#post-form", post: @create_attrs)
#             |> render_submit()
#
#      assert_patch(index_live, ~p"/posts")
#
#      html = render(index_live)
#      assert html =~ "Post created successfully"
#      assert html =~ "some description"
#    end
#
#    test "updates post in listing", %{conn: conn, post: post} do
#      {:ok, index_live, _html} = live(conn, ~p"/posts")
#
#      assert index_live |> element("#posts-#{post.id} a", "Edit") |> render_click() =~
#               "Edit Post"
#
#      assert_patch(index_live, ~p"/posts/#{post}/edit")
#
#      assert index_live
#             |> form("#post-form", post: @invalid_attrs)
#             |> render_change() =~ "can&#39;t be blank"
#
#      assert index_live
#             |> form("#post-form", post: @update_attrs)
#             |> render_submit()
#
#      assert_patch(index_live, ~p"/posts")
#
#      html = render(index_live)
#      assert html =~ "Post updated successfully"
#      assert html =~ "some updated description"
#    end
#
#    test "deletes post in listing", %{conn: conn, post: post} do
#      {:ok, index_live, _html} = live(conn, ~p"/posts")
#
#      assert index_live |> element("#posts-#{post.id} a", "Delete") |> render_click()
#      refute has_element?(index_live, "#posts-#{post.id}")
#    end
#  end
#
#  describe "Show" do
#    setup [:create_post]
#
#    test "displays post", %{conn: conn, post: post} do
#      {:ok, _show_live, html} = live(conn, ~p"/posts/#{post}")
#
#      assert html =~ "Show Post"
#      assert html =~ post.description
#    end
#
#    test "updates post within modal", %{conn: conn, post: post} do
#      {:ok, show_live, _html} = live(conn, ~p"/posts/#{post}")
#
#      assert show_live |> element("a", "Edit") |> render_click() =~
#               "Edit Post"
#
#      assert_patch(show_live, ~p"/posts/#{post}/show/edit")
#
#      assert show_live
#             |> form("#post-form", post: @invalid_attrs)
#             |> render_change() =~ "can&#39;t be blank"
#
#      assert show_live
#             |> form("#post-form", post: @update_attrs)
#             |> render_submit()
#
#      assert_patch(show_live, ~p"/posts/#{post}")
#
#      html = render(show_live)
#      assert html =~ "Post updated successfully"
#      assert html =~ "some updated description"
#    end
#  end
#end
