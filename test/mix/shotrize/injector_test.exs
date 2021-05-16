defmodule Mix.Shotrize.InjectorTest do
  use ExUnit.Case

  alias Mix.Shotrize.Injector

  defp convert_windows_line_endings(file) do
    file |> String.replace("\n", "\r\n")
  end

  describe "web view file" do
    setup do
      file = """
      defmodule PhoenixSampleWeb do
        def view do
          quote do
            use Phoenix.View,
              root: "lib/phoenix_sample_web/templates",
              namespace: PhoenixWeb
          end
        end
      end
      """

      [web_view_file: file]
    end

    test "Success: inject code", context do
      file = context[:web_view_file]

      injected_file = """
      defmodule PhoenixSampleWeb do
        def view do
          quote do
            use Phoenix.View,
              pattern: "**/*",
              root: "lib/phoenix_sample_web/templates",
              namespace: PhoenixWeb
          end
        end
      end
      """

      {:ok, result} = Injector.inject_web_view(file)

      assert result == injected_file
    end

    test "Success: already injected", context do
      file = context[:web_view_file]

      {:ok, result} = Injector.inject_web_view(file)

      assert :already_injected == Injector.inject_web_view(result)
    end

    test "Success: inject when CRLF line endings", context do
      file = context[:web_view_file] |> convert_windows_line_endings()

      injected_file = """
      defmodule PhoenixSampleWeb do\r
        def view do\r
          quote do\r
            use Phoenix.View,\r
              pattern: "**/*",\r
              root: "lib/phoenix_sample_web/templates",\r
              namespace: PhoenixWeb\r
          end\r
        end\r
      end\r
      """

      {:ok, result} = Injector.inject_web_view(file)

      assert result == injected_file
    end
  end

  describe "router.ex delete_page_index_route" do
    setup do
      file = """
      defmodule ShotrizeWeb.Router do
        use ShotrizeWeb, :router

        scope "/", ShotrizeWeb do
          pipe_through(:browser)

          get "/", PageController, :index
        end
      end
      """

      [route_file: file]
    end

    test "Success: delete page index route", context do
      file = context[:route_file]

      deleted_file = """
      defmodule ShotrizeWeb.Router do
        use ShotrizeWeb, :router

        scope "/", ShotrizeWeb do
          pipe_through(:browser)

        end
      end
      """

      {:ok, result} = Injector.delete_page_index_route(file)

      assert result == deleted_file
    end

    test "Success: delete when CRLF line endings", context do
      file = context[:route_file] |> convert_windows_line_endings()

      deleted_file = """
      defmodule ShotrizeWeb.Router do\r
        use ShotrizeWeb, :router\r
      \r
        scope "/", ShotrizeWeb do\r
          pipe_through(:browser)\r
      \r
        end\r
      end\r
      """

      {:ok, result} = Injector.delete_page_index_route(file)

      assert result == deleted_file
    end
  end

  describe "router.ex page route" do
    setup do
      file = """
      defmodule ShotrizeWeb.Router do
        use ShotrizeWeb, :router

        scope "/", ShotrizeWeb do
          pipe_through(:browser)

        end
      end
      """

      [route_file: file]
    end

    test "Success: inject_page_get_route", context do
      file = context[:route_file]

      injected_file = """
      defmodule ShotrizeWeb.Router do
        use ShotrizeWeb, :router

        scope "/", ShotrizeWeb do
          pipe_through(:browser)

          get "/*path_", PageController, :index
        end
      end
      """

      {:ok, result} = Injector.inject_page_get_route(file, "ShotrizeWeb")

      assert result == injected_file
    end

    test "Success: inject_page_get_route already injected", context do
      file = context[:route_file]

      {:ok, result} = Injector.inject_page_get_route(file, "ShotrizeWeb")

      assert :already_injected == Injector.inject_page_get_route(result, "ShotrizeWeb")
    end

    test "Success: inject_page_get_route when CRLF line endings", context do
      file = context[:route_file] |> convert_windows_line_endings()

      injected_file = """
      defmodule ShotrizeWeb.Router do\r
        use ShotrizeWeb, :router\r
      \r
        scope "/", ShotrizeWeb do\r
          pipe_through(:browser)\r
      \r
          get "/*path_", PageController, :index\r
        end\r
      end\r
      """

      {:ok, result} = Injector.inject_page_get_route(file, "ShotrizeWeb")

      assert result == injected_file
    end

    test "Success: inject_page_post_route", context do
      file = context[:route_file]

      injected_file = """
      defmodule ShotrizeWeb.Router do
        use ShotrizeWeb, :router

        scope "/", ShotrizeWeb do
          pipe_through(:browser)

          post "/*path_", PageController, :index
        end
      end
      """

      {:ok, result} = Injector.inject_page_post_route(file, "ShotrizeWeb")

      assert result == injected_file
    end

    test "Success: inject_page_post_route already injected", context do
      file = context[:route_file]

      {:ok, result} = Injector.inject_page_post_route(file, "ShotrizeWeb")

      assert :already_injected == Injector.inject_page_post_route(result, "ShotrizeWeb")
    end

    test "Success: inject_page_post_route when CRLF line endings", context do
      file = context[:route_file] |> convert_windows_line_endings()

      injected_file = """
      defmodule ShotrizeWeb.Router do\r
        use ShotrizeWeb, :router\r
      \r
        scope "/", ShotrizeWeb do\r
          pipe_through(:browser)\r
      \r
          post "/*path_", PageController, :index\r
        end\r
      end\r
      """

      {:ok, result} = Injector.inject_page_post_route(file, "ShotrizeWeb")

      assert result == injected_file
    end
  end

  describe "router.ex api route" do
    setup do
      file = """
      defmodule ShotrizeWeb.Router do
        use ShotrizeWeb, :router

        pipeline :api do
          plug :accepts, ["json"]
        end
      end
      """

      [route_file: file]
    end

    test "Success: inject_rest_api_routes", context do
      file = context[:route_file]

      injected_file = """
      defmodule ShotrizeWeb.Router do
        use ShotrizeWeb, :router

        pipeline :api do
          plug :accepts, ["json"]
        end

        scope "/api/rest/", ShotrizeWeb do
          pipe_through :api

          get "/*path_", RestApiController, :index
          post "/*path_", RestApiController, :create
          put "/*path_", RestApiController, :update
          delete "/*path_", RestApiController, :delete
        end
      end
      """

      {:ok, result} = Injector.inject_rest_api_routes(file, "ShotrizeWeb", "api")

      assert result == injected_file
    end

    test "Success: inject_rest_api_routes already injected", context do
      file = context[:route_file]

      {:ok, result} = Injector.inject_rest_api_routes(file, "ShotrizeWeb", "api")

      assert :already_injected == Injector.inject_rest_api_routes(result, "ShotrizeWeb", "api")
    end

    test "Success: inject_rest_api_routes when CRLF line endings", context do
      file = context[:route_file] |> convert_windows_line_endings()

      injected_file = """
      defmodule ShotrizeWeb.Router do\r
        use ShotrizeWeb, :router\r
      \r
        pipeline :api do\r
          plug :accepts, ["json"]\r
        end\r
      \r
        scope "/api/rest/", ShotrizeWeb do\r
          pipe_through :api\r
      \r
          get "/*path_", RestApiController, :index\r
          post "/*path_", RestApiController, :create\r
          put "/*path_", RestApiController, :update\r
          delete "/*path_", RestApiController, :delete\r
        end\r
      end\r
      """

      {:ok, result} = Injector.inject_rest_api_routes(file, "ShotrizeWeb", "api")

      assert result == injected_file
    end

    test "inject_api_routes", context do
      file = context[:route_file]

      injected_file = """
      defmodule ShotrizeWeb.Router do
        use ShotrizeWeb, :router

        pipeline :api do
          plug :accepts, ["json"]
        end

        scope "/api/", ShotrizeWeb do
          pipe_through :api

          get "/*path_", ApiController, :index
          post "/*path_", ApiController, :index
          put "/*path_", ApiController, :index
          delete "/*path_", ApiController, :index
        end
      end
      """

      {:ok, result} = Injector.inject_api_routes(file, "ShotrizeWeb", "api")

      assert result == injected_file
    end

    test "Success: inject_api_routes already injected", context do
      file = context[:route_file]

      {:ok, result} = Injector.inject_api_routes(file, "ShotrizeWeb", "api")

      assert :already_injected == Injector.inject_api_routes(result, "ShotrizeWeb", "api")
    end

    test "Success: inject_api_routes when CRLF line endings", context do
      file = context[:route_file] |> convert_windows_line_endings()

      injected_file = """
      defmodule ShotrizeWeb.Router do\r
        use ShotrizeWeb, :router\r
      \r
        pipeline :api do\r
          plug :accepts, ["json"]\r
        end\r
      \r
        scope "/api/", ShotrizeWeb do\r
          pipe_through :api\r
      \r
          get "/*path_", ApiController, :index\r
          post "/*path_", ApiController, :index\r
          put "/*path_", ApiController, :index\r
          delete "/*path_", ApiController, :index\r
        end\r
      end\r
      """

      {:ok, result} = Injector.inject_api_routes(file, "ShotrizeWeb", "api")

      assert result == injected_file
    end
  end
end
