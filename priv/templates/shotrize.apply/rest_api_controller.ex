defmodule <%= @module %>.RestApiController do
  use <%= @module %>, :controller

  def index(conn, params) do
    {no_id_path, id} = Rest.separate_id(params["path_"])

    {new_params, template} =
      if id == nil do
        {
          params,
          "index.json"
        }
      else
        {
          params |> Map.put("id", id),
          "show.json"
        }
      end

    caller = "index()"

    try do
      result = execute("#{no_id_path}#{template}", caller, params: new_params)

      if is_tuple(result) do
        response(conn, caller, elem(result, 0), elem(result, 1) |> Jason.encode!())
      else
        response(conn, caller, :ok, result |> Jason.encode!())
      end
    rescue
      err ->
        response(conn, caller, :internal_server_error, err |> inspect |> Rest.error_body())
    end
  end

  def create(conn, params) do
    {no_id_path, _} = Rest.separate_id(params["path_"])

    # TODO：data.json.eexと列突合チェック
    caller = "create() on show"

    try do
      result = execute("#{no_id_path}create.json", "create() on write", params: params)

      if elem(result, 0) == :ok do
        new_params = params |> Map.put("id", elem(result, 1))

        response = execute("#{no_id_path}show.json", caller, params: new_params)
        response(conn, caller, :created, response |> Jason.encode!())
      else
        response(
          conn,
          caller,
          :internal_server_error,
          elem(result, 1) |> inspect |> Rest.error_body()
        )
      end
    rescue
      err ->
        response(conn, caller, :internal_server_error, err |> inspect |> Rest.error_body())
    end
  end

  def update(conn, params) do
    {no_id_path, id} = Rest.separate_id(params["path_"])

    if id == nil do
      response(conn, "update() on check", :not_found, %{error: "Not Found"} |> Jason.encode!())
    else
      new_params = params |> Map.put("id", id)

      # TODO：data.json.eexと列突合チェック
      caller = "update() on show"

      try do
        result = execute("#{no_id_path}update.json", "update() on write", params: new_params)

        if elem(result, 0) == :ok do
          response = execute("#{no_id_path}show.json", caller, params: new_params)
          response(conn, caller, :ok, response |> Jason.encode!())
        else
          response(
            conn,
            caller,
            :internal_server_error,
            elem(result, 1) |> inspect |> Rest.error_body()
          )
        end
      rescue
        err ->
          response(conn, caller, :internal_server_error, err |> inspect |> Rest.error_body())
      end
    end
  end

  def delete(conn, params) do
    # 未解決：[ "data" ]で渡しているが、paramsにはルートに格納されている（もう1階層[ "data" ]を入れても同じ）…何故？

    {no_id_path, id} = Rest.separate_id(params["path_"])

    if id == nil do
      response(conn, "update() on check", :not_found, "Not Found" |> Rest.error_body())
    else
      new_params = params |> Map.put("id", id)

      # TODO：data.json.eexと列突合チェック
      caller = "delete()"

      try do
        _result = execute("#{no_id_path}delete.json", caller, params: new_params)
        response(conn, caller, :no_content, "")
      rescue
        err ->
          response(conn, caller, :internal_server_error, err |> inspect |> Rest.error_body())
      end
    end
  end

  def execute(path, caller, params: params) do
    IO.puts("")
    IO.puts("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
    IO.puts("------------------------------")
    IO.puts("#{caller} > execute()")
    IO.puts("------------------------------")
    IO.inspect(params)
    IO.puts("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

    File.read!("lib/<%= @web_dir_name %>/templates/api/rest/#{path}.eex")
    |> Code.eval_string(params: params, data: params["data"])
    |> elem(0)
  end

  def response(conn, caller, status, body) do
    IO.puts("")
    IO.puts("============================================================")
    IO.puts("------------------------------")
    IO.puts("#{caller} > response() status:#{status}")
    IO.puts("------------------------------")
    IO.inspect(body)
    IO.puts("============================================================")

    conn
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(status, body)
  end
end
