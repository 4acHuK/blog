defmodule Blog.Posts.Post do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :description, :string
    field :title, :string
    belongs_to :user, Blog.Accounts.User
    field :image, Blog.Uploaders.ImageUploader.Type

    timestamps(type: :utc_datetime)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :description])
    |> cast_attachments(attrs, [:image], allow_paths: true)
    |> validate_required([:title, :description])
    |> assoc_constraint(:user)
    |> validate_length(:title, max: 100)
  end
end
