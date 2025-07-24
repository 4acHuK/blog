defmodule Blog.Posts.PostLike do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_likes" do
    belongs_to :user, Blog.Accounts.User
    belongs_to :post, Blog.Posts.Post

    timestamps()
  end

  def changeset(post_like, attrs) do
    post_like
    |> cast(attrs, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
    |> unique_constraint([:user_id, :post_id])
  end
end
