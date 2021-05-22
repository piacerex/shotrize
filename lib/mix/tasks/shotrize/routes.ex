defmodule Mix.Tasks.Shotrize.Routes do
  @moduledoc """
  Prints Shotrize routes

      mix shotrize.routes
  """

  @shortdoc "Prints Shotrize routes"

  use Mix.Task
  alias Mix.Shotrize

  def run(_args) do
    shotrize_route_context()
    |> expand_paths()
    |> Enum.each(&print_template_routes/1)
  end

  defp shotrize_route_context() do
    dir = web_template_dir()

    paths =
      dir
      |> File.ls!()
      |> Enum.reject(&(&1 == "layout"))
      |> Enum.filter(fn path -> Path.join(dir, path) |> File.dir?() end)

    %{dir: dir, paths: paths, current_path: ""}
  end

  defp print_template_routes(context = %{current_path: "page"}) do
    print_route_title("---Shotrize page routes (Serve HTML)---")

    walk_dir(context, fn context -> walk_page_route(context) end)
    |> print_page_routes()
  end

  defp print_template_routes(context = %{current_path: _api_path}) do
    {rest_context, other_context} =
      context
      |> walk_current_path()
      |> extract_rest_context()

    print_route_title("---Shotrize API routes (Serve JSON)---")

    other_context
    |> walk_paths(fn context -> walk_api_route(context) end)
    |> print_api_routes()

    print_route_title("---Shotrize REST API routes (Serve JSON)---")

    rest_context
    |> walk_paths(fn context -> walk_rest_api_route(context) end)
    |> print_rest_api_routes()
  end

  defp print_route_title(title) do
    Mix.shell().info([:green, title, :reset])
  end

  defp extract_rest_context(context = %{paths: paths}) do
    {rest_path, other_paths} =
      paths
      |> Enum.split_with(&(&1 == "rest"))

    {%{context | paths: rest_path}, %{context | paths: other_paths}}
  end

  defp walk_page_route(context) do
    case current_path_is_dir?(context) do
      true -> walk_dir(context, fn context -> walk_page_route(context) end)
      _ -> page_route(context)
    end
  end

  def page_route(%{dir: dir, current_path: path}) do
    route_with_format = path |> String.split(".") |> Enum.take(2) |> Enum.join(".")

    Path.join(dir, route_with_format)
    |> Path.relative_to(web_template_page_dir())
    |> add_slash_prefix()
    |> normalize_index_html_route()
  end

  defp normalize_index_html_route("/index.html") do
    "/"
  end

  defp normalize_index_html_route(page_route) do
    page_route
  end

  defp print_page_routes(page_routes) do
    page_routes
    |> Enum.sort_by(&String.length/1)
    |> Enum.each(&print_page_route/1)
  end

  defp print_page_route(page_route) do
    Mix.shell().info(["GET  ", :magenta, page_route, :reset])
    Mix.shell().info(["POST ", :magenta, page_route, :reset])
  end

  defp walk_api_route(context) do
    case current_path_is_dir?(context) do
      true -> walk_dir(context, fn context -> walk_api_route(context) end)
      _ -> api_route(context)
    end
  end

  defp api_route(%{dir: dir, current_path: path}) do
    route = path |> String.split(".") |> Enum.at(0) |> String.replace(~r/^index$/, "/")

    Path.join(dir, route)
    |> Path.relative_to(web_template_dir())
    |> add_slash_prefix()
  end

  defp print_api_routes(api_routes) do
    api_routes
    |> Enum.sort_by(&String.length/1)
    |> Enum.each(&print_api_route/1)
  end

  defp print_api_route(api_route) do
    Mix.shell().info(["GET    ", :magenta, api_route, :reset])
    Mix.shell().info(["POST   ", :magenta, api_route, :reset])
    Mix.shell().info(["PUT    ", :magenta, api_route, :reset])
    Mix.shell().info(["DELETE ", :magenta, api_route, :reset])
  end

  defp walk_rest_api_route(context) do
    case current_path_is_dir?(context) do
      true -> walk_dir(context, fn context -> walk_rest_api_route(context) end)
      _ -> rest_api_route(context)
    end
  end

  defp rest_api_route(%{dir: dir, current_path: path}) do
    action = path |> String.split(".") |> Enum.at(0)

    dir
    |> Path.relative_to(web_template_dir())
    |> add_slash_prefix()
    |> build_rest_method_route(action)
  end

  defp build_rest_method_route(dir, action) do
    case action do
      "index" -> %{method: "GET", route: "#{dir}/"}
      "show" -> %{method: "GET", route: "#{dir}/:id"}
      "create" -> %{method: "POST", route: "#{dir}/"}
      "update" -> %{method: "PUT", route: "#{dir}/:id"}
      "delete" -> %{method: "DELETE", route: "#{dir}/:id"}
      _ -> %{}
    end
  end

  defp print_rest_api_routes(rest_api_routes) when length(rest_api_routes) > 0 do
    rest_api_routes
    |> Enum.filter(&Map.has_key?(&1, :route))
    |> Enum.sort_by(fn %{route: route} -> String.length(route) end)
    |> pad_space_to_method()
    |> Enum.each(&print_rest_api_route/1)
  end

  defp print_rest_api_routes(_), do: nil

  defp pad_space_to_method(rest_api_routes) do
    max_length =
      rest_api_routes
      |> Enum.max_by(fn %{method: method} -> String.length(method) end)
      |> Map.get(:method)
      |> String.length()

    rest_api_routes
    |> Enum.map(fn rest_api_route = %{method: method} ->
      %{rest_api_route | method: String.pad_trailing(method, max_length + 1, " ")}
    end)
  end

  defp print_rest_api_route(%{method: method, route: route}) do
    Mix.shell().info([method, :magenta, route, :reset])
  end

  defp print_rest_api_route(_), do: nil

  defp expand_paths(context = %{paths: paths}) do
    paths
    |> Enum.map(fn path -> %{context | current_path: path} end)
  end

  defp add_slash_prefix(str), do: "/" <> str

  defp current_path_is_dir?(%{dir: dir, current_path: current_path}) do
    Path.join(dir, current_path) |> File.dir?()
  end

  defp walk_dir(context, walk_func) do
    context
    |> walk_current_path()
    |> walk_paths(walk_func)
  end

  defp walk_current_path(context = %{dir: dir, current_path: current_path}) do
    new_dir = Path.join(dir, current_path)
    new_paths = File.ls!(new_dir)

    %{context | dir: new_dir, paths: new_paths, current_path: ""}
  end

  defp walk_paths(context, walk_func) do
    context
    |> expand_paths()
    |> Enum.map(&walk_func.(&1))
    |> List.flatten()
  end

  defp web_template_dir(), do: Path.join(["lib", Shotrize.installed_app_web_name(), "templates"])
  defp web_template_page_dir(), do: Path.join([web_template_dir(), "page"])
end
