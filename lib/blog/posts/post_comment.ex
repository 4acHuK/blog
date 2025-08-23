defmodule Blog.Posts.PostComment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Accounts.User
  alias Blog.Posts.Post

  schema "post_comments" do
    field :body, :string

    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> assoc_constraint(:user)
    |> assoc_constraint(:post)
    |> validate_length(:body, max: 100)
  end
end
