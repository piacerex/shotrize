defmodule Shotrize.Helper.Type do
  @moduledoc """
  Type library.
  """

  @doc """
  Type check

  ## Examples
      iex> Shotrize.Helper.Type.is( nil )
      "nil"
      iex> Shotrize.Helper.Type.is( "v1" )
      "String"
      iex> Shotrize.Helper.Type.is( "2" )
      "Integer"
      iex> Shotrize.Helper.Type.is( 2 )
      "Integer"
      iex> Shotrize.Helper.Type.is( "true" )
      "Boolean"
      iex> Shotrize.Helper.Type.is( true )
      "Boolean"
      iex> Shotrize.Helper.Type.is( "false" )
      "Boolean"
      iex> Shotrize.Helper.Type.is( false )
      "Boolean"
      iex> Shotrize.Helper.Type.is( "12.34" )
      "Float"
      iex> Shotrize.Helper.Type.is( 12.34 )
      "Float"
      iex> Shotrize.Helper.Type.is( %{ "cs" => "v1", "ci" => "2", "cb" => "true", "cf" => "12.34" } )
      %{ "cs" => "String", "ci" => "Integer", "cb" => "Boolean", "cf" => "Float" }
      iex> Shotrize.Helper.Type.is( %{ "cs" => "v1", "ci" => 2, "cb" => true, "cf" => 12.34 } )
      %{ "cs" => "String", "ci" => "Integer", "cb" => "Boolean", "cf" => "Float" }
      iex> Shotrize.Helper.Type.is( [ "v1", 2, true, 12.34 ] )
      [ "String", "Integer", "Boolean", "Float" ]
  """
  def is(map) when is_map(map),
    do: map |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, is(v)) end)

  def is(list) when is_list(list), do: list |> Enum.map(&is(&1))
  def is(nil), do: "nil"

  def is(value) when is_binary(value) do
    cond do
      is_boolean_include_string(value) -> "Boolean"
      is_float_include_string(value) -> "Float"
      is_integer_include_string(value) -> "Integer"
      true -> "String"
    end
  end

  def is(value) when is_boolean(value), do: "Boolean"
  def is(value) when is_float(value), do: "Float"
  def is(value) when is_integer(value), do: "Integer"

  def is_boolean_include_string(value) when is_binary(value) do
    String.downcase(value) == "true" || String.downcase(value) == "false"
  end

  def is_boolean_include_string(value), do: is_boolean(value)

  def is_float_include_string(value) when is_binary(value) do
    try do
      if String.to_float(value), do: true, else: false
    catch
      _, _ -> false
    end
  end

  def is_float_include_string(value), do: is_float(value)

  def is_integer_include_string(value) when is_binary(value) do
    try do
      if String.to_integer(value), do: true, else: false
    catch
      _, _ -> false
    end
  end

  def is_integer_include_string(value), do: is_integer(value)

  @doc """
  Convert some types to number

  ## Examples
      iex> Shotrize.Helper.Type.to_number( nil )
      nil
      iex> Shotrize.Helper.Type.to_number( "123" )
      123
      iex> Shotrize.Helper.Type.to_number( "12.34" )
      12.34
      iex> Shotrize.Helper.Type.to_number( 123 )
      123
      iex> Shotrize.Helper.Type.to_number( 12.34 )
      12.34
      iex> Shotrize.Helper.Type.to_number( "" )
      nil
      iex> Shotrize.Helper.Type.to_number( "abc" )
      nil
  """
  def to_number(nil), do: nil
  def to_number(value) when is_number(value), do: value

  def to_number(value) when is_binary(value) do
    case is(value) do
      "Float" -> value |> String.to_float()
      "Integer" -> value |> String.to_integer()
      _ -> nil
    end
  end
end
