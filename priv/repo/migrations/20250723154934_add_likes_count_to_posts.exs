defmodule Blog.Repo.Migrations.AddLikesCountToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :likes_count, :integer, default: 0, null: false
    end
  end
end
