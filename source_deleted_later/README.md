# Shotrize�v���g�ł̃T���v��PJ�\�z

���L�R�}���h��Phoenix PJ������āA�{�t�H���_��lib�z���ɏ㏑��

mix phx.new basic --no-ecto

deps�ɉ��L�ǉ����ăr���h

```
{ :smallex, "~> 0.0" }, 
```

# EPSON�v�����^���b�p�[API�̓���m�F

�u���E�U�� http://ocalhost:4000/api/rest/epson/v1/ ������ƁA���L���Ԃ��Ă���

```
{ index: ok }
```

Postman����API�N���C�A���g�� http://ocalhost:4000/api/rest/epson/v1/ �ɉ��Lbody��POST�𑗂�ƁA�v�����^�ł̈�����Ăяo����
�idata�Ɏw�肳�ꂽURL���ANeosVR���瑗���Ă���摜�t�@�C����NeosVR���p�X�j

```
{
  "data": "local://hoge/a.png"
}
```

# Shotrize���񋟂���API�J���x��

��LEPSON�v�����^���b�p�[API�̃\�[�X�R�[�h�́A���L�̒ʂ�

- templates/api/rest/epson/v1/index.json.eex
- templates/api/rest/epson/v1/create.json.eex

Shotrize�́A.exs�t�@�C�����l�AElixir���W���[������Elixir���s���ł��AJSON�Ɠ�����Elixir�f�[�^��ԋp����ƁAJSON��API�߂�Ƃł���

�܂�API�́A�uREST�v�Ɓu�v���[���v��2��ނ�����

���uneos_real�v�usphere�v�́A����m�F���o���Ȃ��Ǝv���̂ŁA�������̎Q�l���x��

## �@REST API

���L�t�H���_�z���ɒu���ƍ���

- templates/api/rest/

HTTP���\�b�h��JSON�t�@�C�����̃}�b�s���O�͉��L�̒ʂ�

HTTP���\�b�h | JSON�t�@�C���� | �ԋp | �����ߑ�
:-|:-|:-
GET�i�ꗗ�j | index.json.eex | JSON�ɑ�������Elixir�f�[�^�i�}�b�v���X�g�A�}�b�v�A������A���l�j��ԋp | id�w��s�v
GET�i�ʁj | show.json.eex | JSON�ɑ�������Elixir�f�[�^�i�}�b�v�A������A���l�j��ԋp | id�w��ł��̃f�[�^�̂ݕԋp
POST | create.json.eex | { :ok, �y�C�Ӂz }��{ :error, �y�C�Ӂz }��ԋp | id�w��s�v�A�ǉ����show.json.eex���ĂсAGET�i�ʁj�Ɠ����f�[�^�ԋp
PUT | update.json.eex | { :ok, �y�C�Ӂz }��{ :error, �y�C�Ӂz }��ԋp | id�w��K�{�A�ǉ����show.json.eex���ĂсAGET�i�ʁj�Ɠ����f�[�^�ԋp
DELETE | delete.json.eex | { :ok, �y�C�Ӂz }��{ :error, �y�C�Ӂz }��ԋp | id�w��K�{

�Ȃ�REST API�̏ꍇ�A�G���h�|�C���g������JSON�t�@�C�����́A���L�̂悤�Ȏw�肪�ł����A��L�Œ�ƂȂ�

http://ocalhost:4000/api/rest/epson/v1/index

## �A�v���[��API

���L�t�H���_�z���ɒu���ƍ���

- templates/api/

REST API�̂悤�Ȕ���͖����̂ŁA�u���E�U��API�N���C�A���g�ł́A���L�̂悤�ɁA�G���h�|�C���g������JSON�t�@�C�����̎w�肪�K�v

http://ocalhost:4000/api/mnesia/start

## �Öق̃p�����[�^

.json.eex���ł́A.html.eex���l�A�N�G���[�X�g�����O��POST�p�����[�^���󂯎�邱�Ƃ��ł���

�������A@�����́uparams�v�ɂȂ�

# Shotrize OSS���Ɍ�����TODO

���L��mix�R�}���h�imix.shotrize apply�j�Ƃ��č\������imix�R�}���h���`��Github�ɂ���ʂ�j

- �t�@�C���ǉ�
 - basic_web/controllers/api_controller.ex
 - basic_web/controllers/rest_api_controller.ex
 - util/rest.ex
- �����t�@�C����������
 - router.ex�@�������㏑���ɂ��邩�H����Ƃ�phx.gen.json�̂悤��mix�R�}���h���s���̃K�C�h�o�͂Ƃ��邩�H
 - controllers/page_controller.ex
- �@�\�ǉ��E���C�@��������koyo����̑Ώ۔͈͊O
 - phx.routes�����̒ǉ�

# EPSON�v�����^���b�p�[API�̃��t�@�N�^�����OTODO

- �eJson.post��body�w��i��3�����j��������ꔭ�œǂ݂ɂ��߂���
 - JSON������Ŏw�肵�Ă�Ƃ���́AElixir�}�b�v�ł̑g�ݗ��ā{Jason.encode�ɕύX
 - POST�p�����[�^�w�肵�Ă�Ƃ���́AElixir�}�b�v�ł̑g�ݗ��ā{�Ǝ��p�[�T�ɕύX
- �eJson.post��header�w��i��4�����ȍ~�j���L�[���[�h���X�g�w��Ȃ̂𐶂��������ʉ��Ȃ�
- ���̑��A���W���[������֐������������L���C�ɂȂ�Ȃ�
 - .json.eex�́A.exs���l�A������defmodule���𓯋��ł���
