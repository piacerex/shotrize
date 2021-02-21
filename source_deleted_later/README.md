# Shotrizeプロト版のサンプルPJ構築

下記コマンドでPhoenix PJを作って、本フォルダをlib配下に上書き

mix phx.new basic --no-ecto

depsに下記追加してビルド

```
{ :smallex, "~> 0.0" }, 
```

# EPSONプリンタラッパーAPIの動作確認

ブラウザで http://ocalhost:4000/api/rest/epson/v1/ を見ると、下記が返ってくる

```
{ index: ok }
```

Postman等のAPIクライアントで http://ocalhost:4000/api/rest/epson/v1/ に下記bodyでPOSTを送ると、プリンタでの印刷を呼び出せる
（dataに指定されたURLが、NeosVRから送られてくる画像ファイルのNeosVR内パス）

```
{
  "data": "local://hoge/a.png"
}
```

# Shotrizeが提供するAPI開発支援

上記EPSONプリンタラッパーAPIのソースコードは、下記の通り

- templates/api/rest/epson/v1/index.json.eex
- templates/api/rest/epson/v1/create.json.eex

Shotrizeは、.exsファイル同様、Elixirモジュール無でElixir実行ができ、JSONと等価なElixirデータを返却すると、JSONをAPI戻りとできる

またAPIは、「REST」と「プレーン」の2種類が作れる

※「neos_real」「sphere」は、動作確認が出来ないと思うので、書き方の参考程度に

## ①REST API

下記フォルダ配下に置くと作れる

- templates/api/rest/

HTTPメソッドとJSONファイル名のマッピングは下記の通り

HTTPメソッド | JSONファイル名 | 返却 | 挙動捕捉
--- | --- | --- | ---
GET（一覧） | index.json.eex | JSONに相当するElixirデータ（マップリスト、マップ、文字列、数値）を返却 | id指定不要
GET（個別） | show.json.eex | JSONに相当するElixirデータ（マップ、文字列、数値）を返却 | id指定でそのデータのみ返却
POST | create.json.eex | { :ok, 【任意】 }か{ :error, 【任意】 }を返却 | id指定不要、追加後はshow.json.eexを呼び、GET（個別）と同じデータ返却
PUT | update.json.eex | { :ok, 【任意】 }か{ :error, 【任意】 }を返却 | id指定必須、追加後はshow.json.eexを呼び、GET（個別）と同じデータ返却
DELETE | delete.json.eex | { :ok, 【任意】 }か{ :error, 【任意】 }を返却 | id指定必須

なおREST APIの場合、エンドポイント末尾のJSONファイル名は、下記のような指定ができず、上記固定となる

http://ocalhost:4000/api/rest/epson/v1/index

## ②プレーンAPI

下記フォルダ配下に置くと作れる

- templates/api/

REST APIのような縛りは無いので、ブラウザやAPIクライアントでは、下記のように、エンドポイント末尾のJSONファイル名の指定が必要

http://ocalhost:4000/api/mnesia/start

## 暗黙のパラメータ

.json.eex内では、.html.eex同様、クエリーストリングやPOSTパラメータを受け取ることができる

ただし、@無しの「params」になる

# Shotrize OSS化に向けたTODO

下記をmixコマンド（mix.shotrize apply）として構成する（mixコマンド雛形はGithubにある通り）

- ファイル追加
 - basic_web/controllers/api_controller.ex
 - basic_web/controllers/rest_api_controller.ex
 - util/rest.ex
- 既存ファイル書き換え
 - router.ex　※強制上書きにするか？それともphx.gen.jsonのようにmixコマンド実行時のガイド出力とするか？
 - controllers/page_controller.ex
- 機能追加・改修　※ここはkoyoさんの対象範囲外
 - phx.routes相当の追加

# EPSONプリンタラッパーAPIのリファクタリングTODO

- 各Json.postのbody指定（第3引数）が文字列一発で読みにく過ぎる
 - JSON文字列で指定してるところは、Elixirマップでの組み立て＋Jason.encodeに変更
 - POSTパラメータ指定してるところは、Elixirマップでの組み立て＋独自パーサに変更
- 各Json.postのheader指定（第4引数以降）をキーワードリスト指定なのを生かした共通化など
- その他、モジュール化や関数化した方がキレイになるなら
 - .json.eexは、.exs同様、内部にdefmodule等を同居できる
