
## なにこれ

プロンプトの味気ないパスをかっこ良く表示するよ
カレントディレクトリは太字に popd で戻るディレクトリに下線を引いたりできます。

![Demo](https://raw.github.com/pasberth/promptway/master/demo/promptway.png)

## Requirements

* zsh
* 多少buggyでも耐える心

## Installation

```sh
git clone git://github.com/pasberth/promptway.git --recursive
cd promptway
source promptway.zsh
```

## Usage

まずは設定をする

```sh
## Source promptway.zsh
# zstyle による設定前に読み込むこと
source path/to/promptway/promptway.zsh

zstyle ':prompt:dir' formats "%B%a%b"
zstyle ':prompt:dir:symlink' formats "%B%F{cyan}%a@%f%b"
zstyle ':prompt:way' formats "%a"
zstyle ':prompt:backward' enable t
zstyle ':prompt:backward:dir' formats "%U%a%u"
zstyle ':prompt:backward:dir:symlink' formats "%U%F{cyan}%a@%f%u"
zstyle ':prompt:backward:way' formats "%a"

## パス省略表示
# パス省略を有効 (default: 無効)
zstyle ':prompt:truncate' enable t

# 省略記号 (default: ...)
#zstyle ':prompt:truncate' symbol '… '

# パス最大長 (default: 30)
#zstyle ':prompt:truncate' max_length 40

# カレントディレクトリの親ディレクトリを表示する (default: 無効)
zstyle ":prompt:truncate" show_working_parent t

# 前ディレクトリの親ディレクトリを表示する (default: 無効)
#zstyle ":prompt:truncate" show_backward_parent t

# "/" 直下のディレクトリを表示する (default: 無効)
zstyle ":prompt:truncate" show_slash_second_root t

# "~/" 直下のディレクトリを表示する (default: 無効)
zstyle ":prompt:truncate" show_home_second_root t

## カレントディレクトリの Permission 表示
# Permission のフォーマット
zstyle ':prompt:permission:dir' formats '(%F{yellow}%a%b%f)'
# オーナーが異なる場合に表示されるシンボル
zstyle ':prompt:permission:dir' non_owner_symbol '⭤'

## 前ディレクトリの Permission 表示
# Permission のフォーマット
zstyle ':prompt:permission:backward' formats '(%F{blue}%a%b%f)'
# オーナーが異なる場合に表示されるシンボル
zstyle ':prompt:permission:backward' non_owner_symbol '⭤'
```

`$_prompt_way` 変数にパス情報が設定されるので、`PROMPT` などに設定して利用します。

```sh
setopt prompt_subst
PROMPT='$_prompt_way'
```

たとえば `~/Documents` から `~/Downloads` に移動した場合、 `$_prompt_backward` に情報が入ります。つまり `~/Documents` に `popd` で戻れるディレクトリの位置が保存されます。

![Demo](https://raw.github.com/pasberth/promptway/master/demo/promptbackward.png)

```sh
setopt prompt_subst
PROMPT='$(_print_promptway)'

function _print_promptway () {
  if [ -n "$_prompt_backward" ]; then
    echo ',-- '$_prompt_backward
    echo '`-> '$_prompt_way
  else
    echo '   ['$_prompt_way']'
  fi
}
```
