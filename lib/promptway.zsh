# -*- sh -*-

zstyle -s ":prompt:pathf" path _cmd_pathf
if [[ -z $_cmd_pathf ]]; then
  _cmd_pathf=$(whence -p pathf)
  if [[ -z $_cmd_pathf ]]; then
    if ! (( $+functions[is-at-least] )); then
      autoload -U is-at-least
    fi
    if is-at-least 4.3.10; then
      _cmd_pathf="${${funcsourcetrace[1]%:*}:A:h}"
    else
      _cmd_pathf="$(cd "${${funcsourcetrace[1]%:*}:h}" > /dev/null 2>&1 && pwd)"
    fi
    _cmd_pathf="${_cmd_pathf}/../.vendor/pathf/bin/pathf"
  fi
  zstyle ":prompt:pathf" path "$_cmd_pathf"
fi

if ! whence -p "$_cmd_pathf" > /dev/null 2>&1; then
  echo "[$0:t] ERROR: pathf command not found: $_cmd_pathf" 1>&2
  echo "[$0:t] Please install patfh (https://github.com/pasberth/pathf)." 1>&2
  echo "[$0:t]   cd promptway && git submodule update --init" 1>&2
  echo "[$0:t]     or" 1>&2
  echo "[$0:t]   git clone git://github.com/pasberth/promptway.git --recursive" 1>&2
  promptway () {
    _prompt_way='%F{red}%~%f'
    return 1
  }
  unset _cmd_pathf
  return 1
fi
unset _cmd_pathf

promptway () {
  _prompt_way=
  local -a _result
  local -a _wwfmt _wdfmt _wdsymfmt
  local -a _is_bwenable _bwdfmt _bwwfmt _bwdsymfmt
  local -a _is_truncate _show_working_parent _show_backward_parent \
    _show_slash_second_root _show_home_second_root _show_named_dir_second_root
  local -a _pdfmt _pbfmt
  local _cmd_pathf _way _bperm _dir_slash _way_slash \
    _symbol _max_length _pdsymbol _pbsymbol
  zstyle -s ":prompt:pathf" path _cmd_pathf
  zstyle -a ":prompt:way" formats _wwfmt
  zstyle -a ":prompt:dir" formats _wdfmt
  zstyle -a ":prompt:dir:symlink" formats _wdsymfmt
  zstyle -a ":prompt:backward" enable _is_bwenable
  zstyle -a ":prompt:backward:dir" formats _bwdfmt
  zstyle -a ":prompt:backward:way" formats _bwwfmt
  zstyle -a ":prompt:backward:dir:symlink" formats _bwdsymfmt
  zstyle -a ":prompt:truncate" enable _is_truncate
  zstyle -s ":prompt:truncate" symbol _symbol
  zstyle -s ":prompt:truncate" max_length _max_length
  zstyle -a ":prompt:truncate" show_working_parent _show_working_parent
  zstyle -a ":prompt:truncate" show_backward_parent _show_backward_parent
  zstyle -a ":prompt:truncate" show_slash_second_root _show_slash_second_root
  zstyle -a ":prompt:truncate" show_home_second_root _show_home_second_root
  zstyle -a ":prompt:truncate" show_named_dir_second_root _show_named_dir_second_root
  zstyle -a ":prompt:permission:dir" formats _pdfmt
  zstyle -s ":prompt:permission:dir" non_owner_symbol _pdsymbol
  zstyle -a ":prompt:permission:backward" formats _pbfmt
  zstyle -s ":prompt:permission:backward" non_owner_symbol _pbsymbol

  _symbol=${_symbol:-...}
  _max_length=${_max_length:-30}

  local BACKWARD_DIR
  # <---(A)--->                     ~~(a)~~
  # /fooo/baaar/piyo_piyo/hoge/fuga/foo-bar/rdi/rsi/raaax
  #             ~~~(b)~~~ <--(B)-->         <-(C)-> ~(c)~
  # A) working-way
  # a) working-dir
  # B) backward-upper-way
  # b) backward-upper-dir
  # C) backward-under-way
  # c) backward-under-dir
  local WORKING_PATH BACKWARD_UPPER_PATH BACKWARD_UNDER_PATH WORKING_WAY BACKWARD_UPPER_DIR BACKWARD_UPPER_WAY WORKING_DIR BACKWARD_UNDER_WAY BACKWARD_UNDER_DIR
  local A

  if [[ -n $_is_bwenable ]] && [[ -n ${dirstack[1]} ]]; then
    BACKWARD_DIR="${dirstack[1]}"

    BACKWARD_UPPER_DIR="$( echo "$BACKWARD_DIR" | "$_cmd_pathf" D )"
    BACKWARD_UPPER_DIR="${(D)BACKWARD_UPPER_DIR}"
    BACKWARD_UPPER_DIR="$(basename "$BACKWARD_UPPER_DIR" | _promptway_filter)"

    BACKWARD_UPPER_WAY="$( echo "$BACKWARD_DIR" | "$_cmd_pathf" d )"
    BACKWARD_UPPER_WAY="${(D)BACKWARD_UPPER_WAY}"
    BACKWARD_UPPER_WAY="$(dirname "$BACKWARD_UPPER_WAY" | _promptway_filter)"

    BACKWARD_UNDER_PATH="$( pwd | "$_cmd_pathf" d "$BACKWARD_DIR" )"
    BACKWARD_UNDER_PATH="${(D)BACKWARD_UNDER_PATH}"

    BACKWARD_UNDER_DIR="$( basename "$BACKWARD_UNDER_PATH" | _promptway_filter )"
    BACKWARD_UNDER_WAY="$( dirname "$BACKWARD_UNDER_PATH" | _promptway_filter )"
  else
    BACKWARD_DIR=
  fi

  WORKING_DIR="$( echo "$BACKWARD_DIR" | "$_cmd_pathf" D | "$_cmd_pathf" d )"
  WORKING_DIR="${(D)WORKING_DIR}"
  WORKING_DIR="$(basename "$WORKING_DIR")"
  WORKING_WAY="${PWD%%$(eval echo "$BACKWARD_UPPER_DIR$BACKWARD_UPPER_WAY$WORKING_DIR")}"

  if [[ $WORKING_WAY != / ]] ; then
    WORKING_WAY="${WORKING_WAY%%/}"
  fi
  WORKING_WAY="${(D)WORKING_WAY}"
  WORKING_DIR="$( echo "$WORKING_DIR" | _promptway_filter )"
  WORKING_WAY="$( echo "$WORKING_WAY" | _promptway_filter )"

  local -a _ww _bupd _bupw _wd _budw _budd

  A=$(_promptway_unslash "$WORKING_WAY")
  zformat -f _ww "$_wwfmt" a:"$A"
  A=$(_promptway_unslash "$WORKING_DIR")
  if [[ -L $PWD ]]; then
    zformat -f _wd "$_wdsymfmt" a:"$A"
  else
    zformat -f _wd "$_wdfmt" a:"$A"
  fi

  _prompt_way="$_prompt_way$_ww"$(_promptway_slash "$WORKING_WAY")

  _wd+=$(_promptway_permission "$PWD" "$_pdfmt" "$_pdsymbol")
  _bperm=$(_promptway_permission "$BACKWARD_DIR" "$_pbfmt" "$_pbsymbol")

  if [[ -n $BACKWARD_UPPER_DIR ]] || [[ -n $BACKWARD_UPPER_WAY ]]; then
    A=$(_promptway_unslash "$BACKWARD_UPPER_DIR")
    if [ -L "$BACKWARD_DIR" ]; then
      zformat -f _bupd "$_bwdsymfmt" a:"$A"
    else
      zformat -f _bupd "$_bwdfmt" a:"$A"
    fi
    A=$(_promptway_unslash "$BACKWARD_UPPER_WAY")
    zformat -f _bupw "$_bwwfmt" a:"$A"

    _way=$_prompt_way
    _dir_slash=$(_promptway_slash "$BACKWARD_UPPER_DIR")
    _way_slash=$(_promptway_slash "$BACKWARD_UPPER_WAY")

    _prompt_way="$_prompt_way$_bupd$_bperm$_dir_slash$_bupw$_way_slash$_wd"

    if [[ -n $_is_truncate ]] \
      && _promptway_is_max_length_over "$_prompt_way" "$_max_length"; then
      _bupw=$(_promptway_truncate "$_bupw" "$_symbol" \
        "$_show_working_parent" "$_show_slash_second_root" "$_show_home_second_root" \
        "$_show_named_dir_second_root")
      _prompt_way=$(_promptway_truncate "$_way" "$_symbol" \
        "$_show_backward_parent" "$_show_slash_second_root" "$_show_home_second_root" \
        "$_show_named_dir_second_root")
      _prompt_way="$_prompt_way$_bupd$_bperm$_dir_slash$_bupw$_way_slash$_wd"
    fi
  elif [[ -n $BACKWARD_UNDER_WAY ]] || [[ -n $BACKWARD_UNDER_DIR ]]; then
    A=$(_promptway_unslash "$BACKWARD_UNDER_WAY")
    zformat -f _budw "$_bwwfmt" a:"$A"
    A=$(_promptway_unslash "$BACKWARD_UNDER_DIR")
    if [ -L "$BACKWARD_DIR" ]; then
      zformat -f _budd "$_bwdsymfmt" a:"$A"
    else
      zformat -f _budd "$_bwdfmt" a:"$A"
    fi

    _way=$_prompt_way
    _dir_slash=$(_promptway_slash "$WORKING_DIR")
    _way_slash=$(_promptway_slash "$BACKWARD_UNDER_WAY")

    _prompt_way="$_prompt_way$_wd$_dir_slash$_budw$_way_slash$_budd$_bperm"
    # _prompt_way=$_prompt_way_$(_promptway_slash "$BACKWARD_UNDER_DIR")

    if [[ -n $_is_truncate ]] \
      && _promptway_is_max_length_over "$_prompt_way" "$_max_length"; then
      _budw=$(_promptway_truncate "$_budw" "$_symbol" \
        "$_show_backward_parent" "$_show_slash_second_root" "$_show_home_second_root" \
        "$_show_named_dir_second_root")
      _prompt_way=$(_promptway_truncate "$_way" "$_symbol" \
        "$_show_working_parent" "$_show_slash_second_root" "$_show_home_second_root" \
        "$_show_named_dir_second_root")
      _prompt_way="$_prompt_way$_wd$_dir_slash$_budw$_way_slash$_budd$_bperm"
    fi
  else
    _way=$_prompt_way
    _prompt_way="$_prompt_way$_wd"
    if [[ -n $_is_truncate ]] \
      && _promptway_is_max_length_over "$_prompt_way" "$_max_length"; then
      _prompt_way=$(_promptway_truncate "$_way" "$_symbol" \
        "$_show_working_parent" "$_show_slash_second_root" "$_show_home_second_root" \
        "$_show_named_dir_second_root")
      _prompt_way="$_prompt_way$_wd"
    fi
  fi

  _promptway_backward
}

_promptway_permission() {
    local _dir="$1" _fmt="$2" _symbol="$3"
    local _perm _ret
    if [[ -z $_dir || -z $_fmt ]]; then
      return 0
    fi
    if [[ -O $_dir ]]; then
      _symbol=
    fi
    if [[ ! -r $_dir ]]; then
      _perm+='r'
    fi
    if [[ ! -w $_dir ]]; then
      _perm+='w'
    fi
    if [[ ! -x $_dir ]]; then
      _perm+='x'
    fi
    _perm="${_perm:+-}$_perm"
    if [[ -z $_symbol && -z $_perm ]]; then
      return 0
    fi
    zformat -f _ret "$_fmt" "a:$_symbol" "b:$_perm"
    echo "$_ret"
}

_promptway_path_length() {
  if [[ -z $1 ]]; then
    echo 0
  fi
  local p
  p=$(echo -E "$1" | sed -e 's/%[^%]{[^}]*}//g' -e 's/%[^%]//g')
  echo ${#p}
}

_promptway_is_max_length_over() {
  if [[ $(_promptway_path_length "$1") -gt $2 ]]; then
    return 0
  fi
  return 1
}

_promptway_truncate() {
  local _path="$1"
  if [[ -z $_path ]]; then
    return
  fi
  local symbol="$2"
  local show_base="$3"
  local show_slash_root="$4"
  local show_home_root="$5"
  local show_named_dir_root="$6"

  local prefix suffix

  if [[ $_path != ${_path%/} ]]; then
    suffix='/'
    _path=${_path%/}
  fi

  if [[ $_path != ${_path#/} ]]; then
    prefix='/'
    _path=${_path#/}
  elif [[ $_path != ${_path#\~/} ]]; then
    prefix='~/'
    _path=${_path#\~/}
  elif [[ $_path != ${_path#\~*/} ]]; then
    prefix="${_path%%/*}/"
    _path=${_path#\~*/}
  elif [[ $_path != ${_path#\~} ]]; then
    prefix="$_path"
    _path=
  fi

  if [[ -n $show_slash_root && $prefix == '/' \
    || -n $show_home_root && $prefix == '~/'  \
    || -n $show_named_dir_root && $prefix =~ '^~[^/]' ]]; then
    if [[ $_path =~ '/' ]]; then
      prefix+="${_path%%/*}/"
      _path=${_path#*/}
    else
      prefix+=$_path
      _path=
    fi
  fi

  base=${_path:t}
  if [[ -z $show_base && \
      ( $base != $_path || ${#base} -gt ${#symbol} ) ]]; then
    base=
  fi
  if [[ $_path != $base ]]; then
    _path="$symbol${base:+/}${base}"
  fi

  echo -E "${prefix}${_path}${suffix}"
}

_promptway_backward () {
  _prompt_backward=
  local _cmd_pathf _pbsymbol _bperm
  local -a _is_bwenable _bwdfmt _bwwfmt _pbfmt
  zstyle -s ":prompt:pathf" path _cmd_pathf
  zstyle -a ":prompt:backward" enable _is_bwenable
  zstyle -a ":prompt:backward:dir" formats _bwdfmt
  zstyle -a ":prompt:backward:way" formats _bwwfmt
  zstyle -a ":prompt:permission:backward" formats _pbfmt
  zstyle -s ":prompt:permission:backward" non_owner_symbol _pbsymbol

  if [[ -z $_is_bwenable ]]; then
    return 0
  fi

  local dirname basename WORKING_DIR BACKWARD_DIR
  local _budw _budd
  local A

  if [ $# -eq 0 ]; then
    WORKING_DIR=$PWD
    BACKWARD_DIR=$dirstack[1]
  fi

  if [[ -z $WORKING_DIR ]] || [[ -z $BACKWARD_DIR ]]; then
    return 0
  fi

  if [[ $WORKING_DIR != ${WORKING_DIR#${BACKWARD_DIR%/}/} \
    || $BACKWARD_DIR != ${BACKWARD_DIR#${WORKING_DIR%/}/} ]]; then
    return 0
  fi

  _bperm=$(_promptway_permission "$BACKWARD_DIR" "$_pbfmt" "$_pbsymbol")

  BACKWARD_DIR="${(D)BACKWARD_DIR}"
  dirname="$( dirname "$BACKWARD_DIR" | _promptway_filter )"
  basename="$( basename "$BACKWARD_DIR" )"
  A=$(_promptway_unslash "$dirname")
  zformat -f _budw "$_bwwfmt" a:"$A"
  A=$(_promptway_unslash "$basename")
  zformat -f _budd "$_bwdfmt" a:"$A"
  _prompt_backward=$_budw$(_promptway_slash "$dirname")$_budd$_bperm
}

_promptway_filter () {
  local w

  if [ $# -eq 0 ]; then
    read w
  else
    w=$1; shift
  fi

  if [ -n "$w" ] && \
     [ "$w" != "." ] && \
     [ "$w" != "/" ]; then
    echo "$w/"
  elif [ "$w" = "/" ]; then
    echo /
  else
    echo ""
  fi
}

_promptway_unslash () {
  local w

  if [ $# -eq 0 ]; then
    read w
  else
    w=$1; shift
  fi

  if [ "$w" = "/" ]; then
    echo /
  else
    echo "${w%%/}"
  fi
}

_promptway_slash () {
  local w

  if [ $# -eq 0 ]; then
    read w
  else
    w=$1; shift
  fi

  if [ -n "$w" ] && \
     [ "$w" != "/" ]; then
    echo /
  elif [ "$w" = "/" ]; then
    echo ""
  else
    echo ""
  fi
}
