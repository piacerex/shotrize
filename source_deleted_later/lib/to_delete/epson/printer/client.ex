defmodule Epson.Printer.Client do
  @moduledoc """
  EpsonConnect API wrapper

  For details, refer to the API document below:
  https://developer.cp.epson.com/ecapi/downloads/?lang=ja
  """

  @host "https://api.epsonconnect.com"
  @root "/api/1/printing"

  @doc """
  Build data for EpsonConnect authorize API

  ## Examples
    iex> Epson.Printer.Client.build_authorize(%{username: "dummy_user", password: "dummy_pw", basic_credentials: "dummy_credencials"})
    %{"body" => "grant_type=password&password=dummy_pw&username=dummy_user", "header" => ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8", Authorization: "Basic dummy_credencials"], "host" => "https://api.epsonconnect.com", "path" => "/api/1/printing/oauth2/auth/token?subject=printer"}
  """
  def build_authorize( %{ username: username, password: password, basic_credentials: basic_credentials } ) do
    %{
      "host"   => @host, 
      "path"   => Path.join( @root, "/oauth2/auth/token?subject=printer" ), 
      "body"   => %{
        "grant_type" => "password", 
        "username"   => username, 
        "password"   => password, 
      } |> URI.encode_query, 
      "header" => [
        "Content-Type":  "application/x-www-form-urlencoded; charset=utf-8",
        "Authorization": "Basic #{basic_credentials}"
      ], 
    }
  end

  @doc """
  Build data for EpsonConnect create job API

  ## Examples
    iex> Epson.Printer.Client.build_create_job(%{"dummy_job_key"=>"dummy_job_value"}, %{ "subject_id" => "dummy_printer_id", "access_token" => "dummy_access_token" })
    
  """
  def build_create_job( payload, %{ "subject_id" => printer_id, "access_token" => access_token } ) do
    %{
      "host"   => @host, 
      "path"   => Path.join( @root, "/printers/#{ printer_id }/jobs" ), 
      "body"   => payload |> Jason.encode!, 
      "header" => header_json() |> Keyword.merge( header_oauth2( access_token ) ), 
    }
  end

  @doc """
  Build data for EpsonConnect upload file API

  ## Examples
  """
  def upload( %{ "upload_uri" => upload_uri } = job, file, filename ) do
    Json.post_raw_response( "#{ upload_uri }&File=#{ filename }", "", file, "Content-Type": "application/octet-stream" )
    job
  end

  @doc """
  Build data for EpsonConnect execute print API

  ## Examples
  """
  def print( %{ "id" => id } = job, %{ "subject_id" => printer_id, "access_token" => access_token } ) do
    path = Path.join( [ @root, "printers", printer_id, "jobs", id, "print" ] )
    Json.post( @host, path, "", header_json() |> Keyword.merge( header_oauth2( access_token ) ) )
    job
  end

  @doc """
  Build data for get job result API

  ## Examples
  """
  def get_result( %{ "id" => job_id } = job, %{ "subject_id" => printer_id, "access_token" => access_token } ) do
    path = Path.join( [ @root, "printers", printer_id, "jobs", job_id ] )
    Json.get( @host, path, header_oauth2( access_token ) )
    job
  end

  defp header_json, do: [ "Content-Type": "application/json; charset=utf-8" ]
  defp header_oauth2( access_token ), do: [ "Authorization": "Bearer #{ access_token }" ]
end
