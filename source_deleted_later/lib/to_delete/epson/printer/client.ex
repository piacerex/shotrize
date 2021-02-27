defmodule Epson.Printer.Client do
	@host "https://api.epsonconnect.com"
	@root "/api/1/printing"

	@doc """
	Request tokens
	"""
	def request_tokens( %{ username: username, password: password, basic_credentials: basic_credentials } ) do
		path = Path.join( [ @root, "oauth2", "auth", "token" ] )
					 <> "?"
					 <> URI.encode_query( %{ subject: "printer" } )
		body = %{
			"grant_type" => "password",
			"username"   => username,
			"password"   => password
		}
		header = [
			"Content-Type":  "application/x-www-form-urlencoded; charset=utf-8",
			"Authorization": "Basic #{basic_credentials}"
		]

		Json.post( @host, path, URI.encode_query( body ), header )
	end

	@doc """
	Prepare job
	"""
	def prepare_job( payload, printer_id, access_token ) do
		path   = Path.join( [ @root, "printers", printer_id, "jobs" ] )

		Json.post( @host, path, Jason.encode!( payload ), header_json() |> Keyword.merge( header_oauth2( access_token ) ) )
		|> Map.put( "access_token", access_token )
	end

	@doc """
	Upload file
	"""
	def upload( %{ "upload_uri" => upload_uri } = job, file, filename ) do
		Json.post_raw_response( "#{ upload_uri }&File=#{ filename }", "", file, "Content-Type": "application/octet-stream" )
		job
	end

	@doc """
	Print
	"""
	def print( %{ "id" => id, "access_token" => access_token } = job, printer_id ) do
		path = Path.join( [ @root, "printers", printer_id, "jobs", id, "print" ] )
		Json.post( @host, path, "", header_json() |> Keyword.merge( header_oauth2( access_token ) ) )
		job
	end

	@doc """
	Get job result
	"""
	def get_result( %{ "id" => job_id, "access_token" => access_token } = job, printer_id ) do
		path = Path.join( [ @root, "printers", printer_id, "jobs", job_id ] )
		Json.get( @host, path, header_oauth2( access_token ) )
		job
	end

	defp header_json, do: [ "Content-Type": "application/json; charset=utf-8" ]
	defp header_oauth2( access_token ), do: [ "Authorization": "Bearer #{ access_token }" ]
end
