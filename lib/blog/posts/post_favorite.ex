defmodule Blog.Posts.PostFavorite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_favorites" do
    belongs_to :user, Blog.Accounts.User
    belongs_to :post, Blog.Posts.Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post_favorite, attrs) do
    post_favorite
    |> cast(attrs, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
    |> unique_constraint(:user_id, name: :post_favorites_user_id_post_id_index)
  end
end
