defmodule Blog.Uploaders.ImageUploader do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @allowed_extensions ~w(.png .jpg .jpeg)

#  def storage_dir(_version, {_file, _post}) do
#    "uploads/post_images"
#  end

  def filename(version, {file, post}) do
    "#{file.file_name}_#{post.title}_#{version}"
  end

  def validate(_version, {file, _scope}) do
    file_extension =
      file.file_name
      |> Path.extname()
      |> String.downcase()

    Enum.member?(@allowed_extensions, file_extension)
  end
end
