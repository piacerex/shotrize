defmodule Mix.Tasks.Shotrize.Apply do
  use Mix.Task

  @shortdoc "Apply Shotrize"

  def run(_args) do
    [
      {template_file_path("router.ex"), web_file_path("router.ex"),
       [module: elixir_app_module()]},
      {template_file_path("page_controller.ex"), controller_file_path("page_controller.ex"),
       [module: elixir_app_module()]},
      {template_file_path("api_controller.ex"), shotrize_file_path("api_controller.ex"),
       [module: elixir_app_module(), web_dir_name: web_dir_name()]},
      {template_file_path("rest_api_controller.ex"), shotrize_file_path("rest_api_controller.ex"),
       [module: elixir_app_module(), web_dir_name: web_dir_name()]}
    ]
    |> Enum.each(fn {src, dst, assigns} -> Mix.Generator.copy_template(src, dst, assigns) end)
  end

  defp elixir_app_module() do
    file_app_module() |> Macro.camelize()
  end

  defp file_app_module() do
    Mix.Project.config()[:app] |> Atom.to_string()
  end

  defp web_dir_name() do
    file_app_module() <> "_web"
  end

  defp web_dir_path() do
    Path.join(["lib", web_dir_name()])
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

  defp template_file_path(filename) do
    Path.join([Mix.Project.app_path(), "priv", "templates", "shotrize.apply", filename])
  end
end
