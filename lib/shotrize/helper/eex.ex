defmodule Shotrize.Helper.Eex do
  @doc ~S"""
    Convert file string and insert `inspect/1` and delete comments to apply `EEx.eval_string/3`.

  ## Examples
      iex> Shotrize.Helper.Eex.to_eex_string("@param = %{ data: 1 }\n%{ \"sample\" => @params }\n")
      "<%=\n@param = %{ data: 1 }\n%{ \"sample\" => @params } |> inspect\n%>\n"

      iex> Shotrize.Helper.Eex.to_eex_string("@param = %{ data: 1 }\n%{ \"sample\" => @params }  \t\n\n")
      "<%=\n@param = %{ data: 1 }\n%{ \"sample\" => @params } |> inspect\n%>\n"

      iex> Shotrize.Helper.Eex.to_eex_string("#comment\ndata = 1\n@param = %{ data: data }\n%{ \"sample\" => @params } # comment \t\n # comment \n")
      "<%=\n\ndata = 1\n@param = %{ data: data }\n%{ \"sample\" => @params } |> inspect\n%>\n"
  """

  def to_eex_string(file) do
    file
    |> remove_comment()
    |> String.trim_trailing()
    |> add_inspect_and_to_eex()
  end

  defp remove_comment(file) do
    Regex.replace(~r/#.*$/m, file, "")
  end

  defp add_inspect_and_to_eex(file) do
    "<%=\n" <> file <> " |> inspect\n%>\n"
  end
end
