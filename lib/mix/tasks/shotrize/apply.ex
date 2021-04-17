defmodule Mix.Tasks.Shotrize.Apply do
  use Mix.Task

  @moduledoc """
  Apply Shotrize on Phoenix project.

  Override or create some xxx_controller files and router.ex and some template files.

      mix shotrize.apply

   ## Options
     * `--api-path` - specify api template path. Defaults to "api".

  """

  @shortdoc "Apply Shotrize"

  def run(_args) do
    templates()
    |> Enum.each(fn {src, dst, assigns} -> Mix.Generator.copy_template(src, dst, assigns) end)
  end

  defp templates() do
    base_templates() ++ html_api_templates()
  end

  defp base_templates() do
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
  end

  defp html_api_templates() do
    [
      {
        template_path("sample.html.eex"),
        web_template_page_path("sample.html.eex"),
        []
      },
      {
        template_path("sample.json.eex"),
        web_template_api_path("sample.json.eex"),
        []
      },
      {
        template_path("index.json.eex"),
        web_template_api_rest_path("index.json.eex"),
        []
      },
      {
        template_path("show.json.eex"),
        web_template_api_rest_path("show.json.eex"),
        []
      },
      {
        template_path("create.json.eex"),
        web_template_api_rest_path("create.json.eex"),
        []
      },
      {
        template_path("update.json.eex"),
        web_template_api_rest_path("update.json.eex"),
        []
      },
      {
        template_path("delete.json.eex"),
        web_template_api_rest_path("delete.json.eex"),
        []
      }
    ]
  end

  defp file_app_module(), do: Mix.Project.config()[:app] |> Atom.to_string()

  defp file_app_web_module(), do: file_app_module() <> "_web"

  defp elixir_web_app_module(), do: file_app_web_module() |> Macro.camelize()

  defp web_dir_path(), do: Path.join(["lib", file_app_web_module()])

  defp web_path(filename), do: Path.join([web_dir_path(), filename])

  defp controller_path(filename), do: Path.join([web_dir_path(), "controllers", filename])

  defp controller_shotrize_path(filename),
    do: Path.join([web_dir_path(), "controllers", "shotrize", filename])

  defp web_template_page_path(filename),
    do: Path.join([web_dir_path(), "templates", "page", filename])

  defp web_template_api_path(filename),
    do: Path.join([web_dir_path(), "templates", "api", filename])

  defp web_template_api_rest_path(filename),
    do: Path.join([web_dir_path(), "templates", "api", "rest", filename])

  defp template_root_path(), do: :shotrize |> Application.app_dir()

  defp template_path(filename),
    do: Path.join([template_root_path(), "priv", "templates", "shotrize.apply", filename])
end
