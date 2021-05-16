defmodule Mix.Tasks.Shotrize.Apply do
  use Mix.Task
  alias Mix.Shotrize.Injector

  @moduledoc """
  Apply Shotrize on Phoenix project.

  Override or create some xxx_controller files and router.ex and some template files.

      mix shotrize.apply

   ## Options
     * `--api-path` - specify api template path. Defaults to "api".

  """

  @shortdoc "Apply Shotrize"

  @default_opts [api_path: "api"]

  def run(args) do
    args
    |> parse()
    |> generate_files()
    |> inject_files()
  end

  defp parse(args) do
    opts = OptionParser.parse(args, switches: [api_path: :string]) |> elem(0)

    Keyword.merge(@default_opts, opts)
    |> Map.new
  end

  defp generate_files(context = %{api_path: api_path}) do
    api_path
    |> templates()
    |> Enum.each(fn {src, dst, assigns} -> Mix.Generator.copy_template(src, dst, assigns) end)

    context
  end

  defp inject_files(context = %{api_path: api_path}) do
    api_path
    |> inject_list()
    |> Enum.each(fn {src, injector_func, note} -> maybe_inject_file(src, injector_func, note) end)

    context
  end

  defp templates(api_path) do
    base_templates(api_path) ++ html_api_templates(api_path)
  end

  defp base_templates(api_path) do
    [
      {
        template_path("page_controller.ex"),
        controller_path("page_controller.ex"),
        [module: elixir_web_app_module()]
      },
      {
        template_path("api_controller.ex"),
        controller_shotrize_path("api_controller.ex"),
        [module: elixir_web_app_module(), web_dir_name: file_app_web_module(), api_path: api_path]
      },
      {
        template_path("rest_api_controller.ex"),
        controller_shotrize_path("rest_api_controller.ex"),
        [module: elixir_web_app_module(), web_dir_name: file_app_web_module(), api_path: api_path]
      }
    ]
  end

  defp html_api_templates(api_path) do
    [
      {
        template_path("sample.html.eex"),
        web_template_page_path("sample.html.eex"),
        []
      },
      {
        template_path("sample.json.eex"),
        web_template_api_path(api_path, "sample.json.eex"),
        []
      },
      {
        template_path("index.json.eex"),
        web_template_api_rest_path(api_path, "index.json.eex"),
        []
      },
      {
        template_path("show.json.eex"),
        web_template_api_rest_path(api_path, "show.json.eex"),
        []
      },
      {
        template_path("create.json.eex"),
        web_template_api_rest_path(api_path, "create.json.eex"),
        []
      },
      {
        template_path("update.json.eex"),
        web_template_api_rest_path(api_path, "update.json.eex"),
        []
      },
      {
        template_path("delete.json.eex"),
        web_template_api_rest_path(api_path, "delete.json.eex"),
        []
      }
    ]
  end

  defp file_app_module(), do: Mix.Project.config()[:app] |> Atom.to_string()

  defp file_app_web_module(), do: file_app_module() <> "_web"

  defp elixir_web_app_module(), do: file_app_web_module() |> Macro.camelize()

  defp web_dir_path(), do: Path.join(["lib", file_app_web_module()])

  defp web_view_path(), do: Path.join(["lib", file_app_web_module() <> ".ex"])

  defp web_path(filename), do: Path.join([web_dir_path(), filename])

  defp controller_path(filename), do: Path.join([web_dir_path(), "controllers", filename])

  defp controller_shotrize_path(filename),
    do: Path.join([web_dir_path(), "controllers", "shotrize", filename])

  defp web_template_page_path(filename),
    do: Path.join([web_dir_path(), "templates", "page", filename])

  defp web_template_api_path(api_path, filename),
    do: Path.join([web_dir_path(), "templates", api_path, filename])

  defp web_template_api_rest_path(api_path, filename),
    do: Path.join([web_dir_path(), "templates", api_path, "rest", filename])

  defp template_root_path(), do: :shotrize |> Application.app_dir()

  defp template_path(filename),
    do: Path.join([template_root_path(), "priv", "templates", "shotrize.apply", filename])

  defp inject_list(api_path) do
    [
      {
        web_view_path(),
        fn file -> Injector.inject_web_view(file) end,
        "#{web_view_path()}"
      },
      {
        web_path("router.ex"),
        fn file -> Injector.delete_page_index_route(file) end,
        "#{web_path("router.ex")} - delete page index route"
      },
      {
        web_path("router.ex"),
        fn file -> Injector.inject_page_get_route(file, elixir_web_app_module()) end,
        "#{web_path("router.ex")} - inject page GET route"
      },
      {
        web_path("router.ex"),
        fn file -> Injector.inject_page_post_route(file, elixir_web_app_module()) end,
        "#{web_path("router.ex")} - inject page POST route"
      },
      {
        web_path("router.ex"),
        fn file -> Injector.inject_api_routes(file, elixir_web_app_module(), api_path) end,
        "#{web_path("router.ex")} - inject API and REST API routes"
      },
    ]
  end

  defp maybe_inject_file(file_path, injector_func, note) do
    print_injecting(note)

    with {:ok, file} <- File.read(file_path),
         {:ok, new_file} <- injector_func.(file) do
      File.write!(file_path, new_file)
    else
      :already_injected ->
        print_already_injected(note)

      {:error, reason} ->
        print_unable_to_read_file_error(file_path, reason)
    end
  end

  defp print_already_injected(note) do
    Mix.shell().info([:yellow, "skip: already_injected ", :reset, note])
  end

  defp print_injecting(note) do
    Mix.shell().info([:green, "* injecting ", :reset, note])
  end

  defp print_unable_to_read_file_error(file_path, reason) do
    Mix.shell().error("#{file_path} Unable to read file: #{reason}")
  end
end
