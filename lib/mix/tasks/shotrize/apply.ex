defmodule Mix.Tasks.Shotrize.Apply do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Apply Shotrize"

  def run(_args) do
    # elixir_app_module = file_app_module |> Macro.camelize
    create_file(web_file_path("router.ex"), spa_template(app_module: file_app_module))

    create_file(
      controller_file_path("page_controller.ex"),
      spa_template(app_module: file_app_module)
    )

    create_file(
      shotrize_file_path("api_controller.ex"),
      spa_template(app_module: file_app_module)
    )

    create_file(
      shotrize_file_path("rest_api_controller.ex"),
      spa_template(app_module: file_app_module)
    )
  end

  defp file_app_module() do
    Mix.Project.config()[:app] |> Atom.to_string()
  end

  defp web_dir_name() do
    file_app_module() <> "_web"
  end

  defp web_dir_path() do
    Path.join(["lib", web_dir_name()])
    |> Path.relative_to(Mix.Project.app_path())
  end

  defp web_file_path(filename) do
    Path.join([web_dir_path(), filename])
  end

  defp shotrize_file_path(filename) do
    Path.join([web_dir_path(), "controllers", "shotrize", filename])
  end

  defp controller_file_path(filename) do
    Path.join([web_dir_path(), "controllers", filename])
  end

  embed_template(:spa, "hoge")
end
