defmodule Markdown do
	def dispatch( relative_path, body, creator, updater ) do
		case body do
			""       -> Markdown.new(    creator, updater )
			"folder" -> Markdown.folder( creator, updater )
			_        -> 
				case Path.extname( relative_path ) do
					".png"  -> Markdown.image( relative_path, creator, updater )
					".jpg"  -> Markdown.image( relative_path, creator, updater )
					".gif"  -> Markdown.image( relative_path, creator, updater )
					".gif"  -> Markdown.image( relative_path, creator, updater )
					".ico"  -> Markdown.unsupported(          creator, updater )
					".md"   -> Markdown.markdown( body,       creator, updater )
					".html" -> Markdown.plane(    body,       creator, updater )
					_       -> 
						Markdown.plane(    body,       creator, updater )
						|> Map.merge(
							%{
								"naked" => true, 
							} )
				end
		end
		|> Map.merge(
			%{
				"path" => relative_path, 
			} )
	end

	def plane(    body, creator, updater ), do: parse( body, creator, updater, true,  true )
	def markdown( body, creator, updater ), do: parse( body, creator, updater, false, true )
	def parse(    body, creator, updater, raw, savable ) do
		pattern = 
			"<!--\n" <>
			"Title: "		<> "(?<title>.*)"		<> "\n" <>
			"CreateDate: "	<> "(?<create_date>.*)"	<> "\n" <>
			"Creator: "		<> "(?<creator>.*)"		<> "\n" <>
			"UpdateDate: "	<> ".*"					<> "\n" <>
			"Updater: "		<> "(?<updater>.*)"		<> "\n" <>
			"-->\n" <>
			"\n" <>
			"(?<body>(.|\n)*)"
		regex = Regex.compile!( pattern )
		result = Regex.named_captures( regex, body )
		if result == nil, do: init( body, creator, updater, raw, savable ), else: result
		|> Map.merge(
			%{
				"raw"		=> raw, 
				"savable"	=> savable, 
			} )
	end

	def new(         creator, updater ), do: init( "",                           creator, updater, true, true  )
	def image( path, creator, updater ), do: init( "<img src=\"#{ path }\">",    creator, updater, true, false )
	def folder(      creator, updater ), do: init( "（フォルダです）",           creator, updater, true, false )
	def unsupported( creator, updater ), do: init( "（サポートされていません）", creator, updater, true, false )
	def init( body, creator, updater, raw, savable ) do
		%{
			"title"			=> "", 
			"create_date"	=> Dt.to_ymdhms( Timex.now ), 
			"creator"		=> creator, 
			"update_date"	=> "", 
			"updater"		=> updater, 
			"body"			=> body, 
			"raw"			=> raw, 
			"savable"		=> savable, 
		}
	end
end
