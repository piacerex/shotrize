defmodule Mix.Shotrize do
  @moduledoc """
  Functions Using Mix.Shotrize.XXX modules
  """

  @doc """
    Application name installed Shotrize

  ## Examples
    iex> Mix.Shotrize.installed_app_name
    "shotrize"
  """
  def installed_app_name(), do: Mix.Project.config()[:app] |> Atom.to_string()

  @doc """
    Application web directory name installed Shotrize.

    Shotrize assumes that Phoenix is installed.

  ## Examples
    iex> Mix.Shotrize.installed_app_web_name
    "shotrize_web"
  """
  def installed_app_web_name(), do: installed_app_name() <> "_web"
end
