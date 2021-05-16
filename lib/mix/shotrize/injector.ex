defmodule Mix.Shotrize.Injector do
  @moduledoc """
  Code injector for Shotrize
  """

  @doc """
  Inject code into xxx_web.ex.
  """
  def inject_web_view(file) do
    anchor_line = "use Phoenix.View,"
    inject_code = ~s|pattern: "**/*",|
    indent = "  "

    try_inject(
      file,
      inject_code,
      fn file ->
        Regex.replace(
          ~r/^(\s*)#{anchor_line}.*(\r\n|\n|$)/Um,
          file,
          "\\0\\1#{indent}#{inject_code}\\2",
          global: false
        )
      end
    )
  end

  @doc """
  Delete default page index route.
  """
  def delete_page_index_route(file) do
    delete_code = ~s|get "/", PageController, :index|

    {:ok,
     Regex.replace(
       ~r/^[ \t]*#{delete_code}.*(\r\n|\n|$)/Um,
       file,
       "",
       global: false
     )}
  end

  @doc """
  Inject Shotrize page GET route.
  """
  def inject_page_get_route(file, module_name) do
    inject_page_route(file, ~s|get "/*path_", PageController, :index|, module_name)
  end

  @doc """
  Inject Shotrize page POST route.
  """
  def inject_page_post_route(file, module_name) do
    inject_page_route(file, ~s|post "/*path_", PageController, :index|, module_name)
  end

  defp inject_page_route(file, inject_code, module_name) do
    anchor_line_start = ~s|scope "/", #{module_name} do|
    anchor_line_end = ~s|end|
    indent = "  "
    line_endings = get_line_ending(file)

    try_inject(
      file,
      inject_code,
      fn file ->
        Regex.replace(
          ~r/([ \t]*)(#{anchor_line_start})(.*)([ \t]*#{anchor_line_end})/Us,
          file,
          "\\1\\2\\3\\1#{indent}#{inject_code}#{line_endings}\\4",
          global: false
        )
      end
    )
  end

  @doc """
  Inject Shotrize REST API routes.
  """
  def inject_rest_api_routes(file, module_name, api_path) do
    inject_code =
      ~s"""
        scope "/#{api_path}/rest/", #{module_name} do
          pipe_through :api

          get "/*path_", RestApiController, :index
          post "/*path_", RestApiController, :create
          put "/*path_", RestApiController, :update
          delete "/*path_", RestApiController, :delete
        end
      """
      |> normalize_line_endings_to_file(file)

    inject_after_api_pipeline(file, inject_code)
  end

  @doc """
  Inject Shotrize API routes.
  """
  def inject_api_routes(file, module_name, api_path) do
    inject_code =
      ~s"""
        scope "/#{api_path}/", #{module_name} do
          pipe_through :api

          get "/*path_", ApiController, :index
          post "/*path_", ApiController, :index
          put "/*path_", ApiController, :index
          delete "/*path_", ApiController, :index
        end
      """
      |> normalize_line_endings_to_file(file)

    inject_after_api_pipeline(file, inject_code)
  end

  defp inject_after_api_pipeline(file, inject_code) do
    anchor_line_start = ~s|pipeline :api do|
    anchor_line_end = ~s|end|
    line_endings = get_line_ending(file)

    [inject_code_piece | _] = String.split(inject_code, line_endings)

    try_inject(
      file,
      inject_code_piece,
      fn file ->
        Regex.replace(
          ~r/#{anchor_line_start}.*#{anchor_line_end}#{line_endings}/Us,
          file,
          "\\0#{line_endings}#{inject_code}",
          global: false
        )
      end
    )
  end

  defp try_inject(file, inject_code_piece, injector_fn) do
    if already_injected?(file, inject_code_piece) do
      :already_injected
    else
      {:ok, injector_fn.(file)}
    end
  end

  defp already_injected?(file, inject_code_piece) do
    String.contains?(file, inject_code_piece)
  end

  defp normalize_line_endings_to_file(code, file) do
    String.replace(code, "\n", get_line_ending(file))
  end

  defp get_line_ending(file) do
    case Regex.run(~r/\r\n|\n|$/, file) do
      [line_ending] -> line_ending
      [] -> "\n"
    end
  end
end
