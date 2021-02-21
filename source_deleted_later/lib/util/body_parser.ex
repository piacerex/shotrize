defmodule BodyParser do
	@moduledoc """
	Parser for POST method Body.
	"""

	@doc """
	Parse map to body (string format).

	## Examples
	iex>  BodyParser.parse(%{grant_type: "password", username: "jxh51408xs2md2@print.epsonconnect.com", password: ""})
	"grant_type=password&password=&username=jxh51408xs2md2@print.epsonconnect.com"

	iex>  BodyParser.parse(%{"grant_type" => "password", "username" => "jxh51408xs2md2@print.epsonconnect.com", "password" => ""})
	"grant_type=password&password=&username=jxh51408xs2md2@print.epsonconnect.com"
	"""
	def parse(map) do
		map
		|> Enum.map(fn {key, val} -> format(key, val) end)
		|> Enum.sort()
		|> Enum.join("&")
	end
	defp format(key, val) when is_atom(key) do
		"#{Atom.to_string(key)}=#{val}"
	end
	defp format(key, val) when is_binary(key) do
		"#{key}=#{val}"
	end

	@doc """
	Parse map to body (json format).

	## Examples
	iex>  BodyParser.parse_to_json(%{password: "", user: "koyo"})
	~S|{"password":"","user":"koyo"}|
	"""
	def parse_to_json(map) do
		Jason.encode!(map)
	end
end
