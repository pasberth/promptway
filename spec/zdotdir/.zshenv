source $ZDOTDIR/../../promptway.zsh

zstyle ':prompt:dir' formats "<%a>"
zstyle ':prompt:dir:symlink' formats "<%a@>"
zstyle ':prompt:way' formats "{<%a>}"
zstyle ':prompt:backward' enable t
zstyle ':prompt:backward:dir' formats "_%a_"
zstyle ':prompt:backward:dir:symlink' formats "_%a@_"
zstyle ':prompt:backward:way' formats "{_%a_}"

hash -d named-dir=$ZDOTDIR/named-dir
hash -d under-named-dir=$ZDOTDIR/named-dir/path/to/under-named-dir

cd $ZDOTDIR
