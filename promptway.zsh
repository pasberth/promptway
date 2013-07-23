source `dirname $0`/lib/promptway.zsh

## TODO: 各項目の説明
#
zstyle ':prompt:dir' formats "%B%a%b"
zstyle ':prompt:dir:symlink' formats "%B%F{cyan}%a@%f%b"
zstyle ':prompt:way' formats "%a"
zstyle ':prompt:backward' enable t
zstyle ':prompt:backward:dir' formats "%U%a%u"
zstyle ':prompt:backward:dir:symlink' formats "%U%F{cyan}%a@%f%u"
zstyle ':prompt:backward:way' formats "%a"

## パス省略表示
# パス省略を有効 (default: 無効)
zstyle ':prompt:truncate' enable ""

# 省略記号 (default: ...)
zstyle ':prompt:truncate' symbol '...'

# パス最大長 (default: 30)
zstyle ':prompt:truncate' max_length 30

# カレントディレクトリの親ディレクトリを表示する (default: 無効)
zstyle ":prompt:truncate" show_working_parent ""

# 前ディレクトリの親ディレクトリを表示する (default: 無効)
zstyle ":prompt:truncate" show_backward_parent ""

# "/" 直下のディレクトリを表示する (default: 無効)
zstyle ":prompt:truncate" show_slash_second_root ""

# "~/" 直下のディレクトリを表示する (default: 無効)
zstyle ":prompt:truncate" show_home_second_root ""




if ! (( $+functions[add-zsh-hook] )); then
  autoload -U add-zsh-hook
fi

function __promptway-init-in-first () {
  promptway
  add-zsh-hook -d precmd __promptway-init-in-first
  unfunction __promptway-init-in-first
}

add-zsh-hook chpwd promptway
add-zsh-hook precmd __promptway-init-in-first