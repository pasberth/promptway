
## なにこれ

プロンプトの味気ないパスをかっこ良く表示するよ  
カレントディレクトリは太字に popd で戻るディレクトリに下線を引いたりできます。  


## Usage

まずは設定をする

```sh

  source path/to/promptway/promptway.zsh

  zstyle ':prompt:dir' formats "%B%a%b"
  zstyle ':prompt:way' formats "%a"
  zstyle ':prompt:backward' enable t
  zstyle ':prompt:backward:dir' formats "%U%a%u"
  zstyle ':prompt:backward:way' formats "%a"
```

add-zsh-hook の chpwd とかでプロンプトを更新    
`promptway` 関数を呼ぶと `$_prompt_way` ってグローバル変数に情報が入ります。  

```sh

setopt prompt_subst
PROMPT='$PROMTPT_WAY'

function _update_prompt_way () {
  promptway
  PROMPT_WAY=$_prompt_way
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _update_prompt_way
```