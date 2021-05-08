defmodule Mix.Shotrize.InjectorTest do
  use ExUnit.Case

  describe "inject_web_view" do
    test "Success: inject code" do
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

      {:ok, result} = Mix.Shotrize.Injector.inject_web_view(file)

      assert result == injected_file
    end

    test "Success: already injected" do
      file = """
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

      assert :already_injected == Mix.Shotrize.Injector.inject_web_view(file)
    end

    test "Success: inject when Windows line endings" do
      file = """
      defmodule PhoenixSampleWeb do\r
        def view do\r
          quote do\r
            use Phoenix.View,\r
              root: "lib/phoenix_sample_web/templates",\r
              namespace: PhoenixWeb\r
          end\r
        end\r
      end\r
      """

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

      {:ok, result} = Mix.Shotrize.Injector.inject_web_view(file)

      assert result == injected_file
    end
  end
end
