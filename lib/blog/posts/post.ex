defmodule Blog.Posts.Post do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :description, :string
    field :title, :string
    field :image, Blog.Uploaders.ImageUploader.Type
    field :likes_count, :integer

    belongs_to :user, Blog.Accounts.User
    has_many :post_likes, Blog.Posts.PostLike
    has_many :liked_users, through: [:post_likes, :user]
    has_many :post_favorites, Blog.Posts.PostFavorite
    has_many :favorited_users, through: [:post_favorites, :user]

    timestamps(type: :utc_datetime)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :description, :likes_count])
    |> cast_attachments(attrs, [:image], allow_paths: true)
    |> validate_required([:title, :description])
    |> assoc_constraint(:user)
    |> validate_length(:title, max: 100)
  end
end
