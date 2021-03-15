defmodule Mix.Tasks.Shotrize.Apply do
  use Mix.Task

  @shortdoc "Apply Shotrize"

  def run(_args) do
    [
      {
        template_path("router.ex"),
        web_path("router.ex"),
        [module: elixir_web_app_module()]
      },
      {
        template_path("page_controller.ex"),
        controller_path("page_controller.ex"),
        [module: elixir_web_app_module()]
      },
      {
        template_path("api_controller.ex"),
        controller_shotrize_path("api_controller.ex"),
        [module: elixir_web_app_module(), web_dir_name: file_app_web_module()]
      },
      {
        template_path("rest_api_controller.ex"),
        controller_shotrize_path("rest_api_controller.ex"),
        [module: elixir_web_app_module(), web_dir_name: file_app_web_module()]
      }
    ]
    |> Enum.each(fn {src, dst, assigns} -> Mix.Generator.copy_template(src, dst, assigns) end)
  end

  defp file_app_module(), do: Mix.Project.config()[:app] |> Atom.to_string()

  defp file_app_web_module(), do: file_app_module() <> "_web"

  defp elixir_web_app_module(), do: file_app_web_module() |> Macro.camelize()

  defp web_dir_path(), do: Path.join(["lib", file_app_web_module()])

  defp web_path(filename), do: Path.join([web_dir_path(), filename])

  defp controller_path(filename), do: Path.join([web_dir_path(), "controllers", filename])

  defp controller_shotrize_path(filename),
    do: Path.join([web_dir_path(), "controllers", "shotrize", filename])

  defp template_root_path(), do: :shotrize |> Application.app_dir()

  defp template_path(filename),
    do: Path.join([template_root_path(), "priv", "templates", "shotrize.apply", filename])
end
