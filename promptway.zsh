source "`dirname "$0"`/lib/promptway.zsh"

## Working directory
# Format of working directory.
# %a := `basename $PWD`
zstyle ':prompt:dir' formats "%B%a%b"

# Format of working directory (when it is a symlink).
# %a := `basename $PWD`
zstyle ':prompt:dir:symlink' formats "%B%F{cyan}%a@%f%b"

## Working way
# Format of path between `/' and working directory.
# %a := path between `/' and working directory
zstyle ':prompt:way' formats "%a"

# TODO
zstyle ':prompt:backward' enable t

## Backward directory
# Format of backward directory.
# %a := `basename $dirstack[1]`
zstyle ':prompt:backward:dir' formats "%U%a%u"

# Format of backward directory (when it is a symlink).
# %a := `basename $dirstack[1]`
zstyle ':prompt:backward:dir:symlink' formats "%U%F{cyan}%a@%f%u"

## Backward way
# Format of path between working directory and backward-directory.
# %a := path between working directory and backward-directory
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

# 名前付きディレクトリ直下のディレクトリを表示する (default: 無効)
zstyle ':prompt:truncate' show_named_dir_second_root ""

## Permissions of the current directory
# Format of permissions
zstyle ':prompt:permission:dir' formats ""
# Non owner symbol
zstyle ':prompt:permission:dir' non_owner_symbol ""

## Permissions of the backward directory
# Format of permissions
zstyle ':prompt:permission:backward' formats ""
# Non owner symbol
zstyle ':prompt:permission:backward' non_owner_symbol ""




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