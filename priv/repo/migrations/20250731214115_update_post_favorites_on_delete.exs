defmodule Blog.Repo.Migrations.UpdatePostFavoritesOnDelete do
  use Ecto.Migration

  def change do
    alter table(:post_favorites) do
      modify :post_id, references(:posts, on_delete: :delete_all), null: false, from: references(:posts, on_delete: :nothing), null: false
      modify :user_id, references(:users, on_delete: :delete_all), null: false, from: references(:users, on_delete: :nothing), null: false
    end
  end
end
