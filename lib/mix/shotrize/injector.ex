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
      fn ->
        Regex.replace(
          ~r/^(\s*)#{anchor_line}.*(\r\n|\n|$)/Um,
          file,
          "\\0\\1#{indent}#{inject_code}\\2",
          global: false
        )
      end
    )
  end

  defp try_inject(file, inject_code, injector_func) do
    if already_injected?(file, inject_code) do
      :already_injected
    else
      {:ok, injector_func.()}
    end
  end

  defp already_injected?(file, inject_code) do
    String.contains?(file, inject_code)
  end
end
