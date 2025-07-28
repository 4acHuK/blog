defmodule Blog.Repo.Migrations.CreatePostFavorites do
  use Ecto.Migration

  def change do
    create table(:post_favorites) do
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:post_favorites, [:user_id, :post_id])
    create index(:post_favorites, [:user_id])
    create index(:post_favorites, [:post_id])
  end
end
