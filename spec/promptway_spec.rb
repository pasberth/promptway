def __dir__
  File.dirname(__FILE__)
end

def __zdotdir__
  "%s/%s" % [__dir__, 'zdotdir']
end

def __absdir__
  File.realpath(__dir__).sub(ENV['HOME'], '~')
end

def zsh(script)
  ` ZDOTDIR=#{__zdotdir__} zsh -c '#{script}' `
end

describe "promptway.zsh" do

  example "on the current directory" do
    expect(
      zsh('promptway; echo $_prompt_way').chomp
    ).to eq ("{<%s>}/<zdotdir>" % __absdir__)
  end

  example "cd into an under directory" do
    expect(
      zsh('pushd .vim; promptway; echo $_prompt_way').chomp
    ).to eq ("{<%s>}/_zdotdir_/{__}<.vim>" % __absdir__)
  end

  example "cd into an under symbolic linked directory" do
    expect(
      zsh('pushd .emacs.d; promptway; echo $_prompt_way').chomp
    ).to eq ("{<%s>}/_zdotdir_/{__}<.emacs.d@>" % __absdir__)
  end

  example "cd into an under under directory" do
    expect(
      zsh('pushd dotfiles/emacs.d.entity; promptway; echo $_prompt_way').chomp
    ).to eq ("{<%s>}/_zdotdir_/{_dotfiles_}/<emacs.d.entity>" % __absdir__)
  end

  example "cd into an under directory and return to the parent directory" do
    expect(
      zsh('pushd .vim; pushd ..; promptway; echo $_prompt_way').chomp
    ).to eq ("{<%s>}/<zdotdir>/{__}_.vim_" % __absdir__)
  end

  example "cd into an under symbolic linked directory and return to the parent directory" do
    expect(
      zsh('pushd .emacs.d; pushd ..; promptway; echo $_prompt_way').chomp
    ).to eq ("{<%s>}/<zdotdir>/{__}_.emacs.d@_" % __absdir__)
  end

  example "cd into an under under directory and return to the parent directory" do
    expect(
      zsh('pushd dotfiles/emacs.d.entity; pushd ../..; promptway; echo $_prompt_way').chomp
    ).to eq ("{<%s>}/<zdotdir>/{_dotfiles_}/_emacs.d.entity_" % __absdir__)
  end

  example "cd into an under under directory and return to a parent directory" do
    expect(
      zsh('pushd dotfiles/emacs.d.entity; pushd ..; promptway; echo $_prompt_way').chomp
    ).to eq ("{<%s/zdotdir>}/<dotfiles>/{__}_emacs.d.entity_" % __absdir__)
  end

  context "on a named directory" do

    example "on the named directory" do
      expect(
        zsh('cd named-dir; promptway; echo $_prompt_way').chomp
      ).to eq ("{<>}<~named-dir>")
    end

    example "cd into a under directory" do
      expect(
        zsh('cd named-dir; pushd path; promptway; echo $_prompt_way').chomp
      ).to eq ("{<>}_~named-dir_/{__}<path>")
    end

    example "cd into a under under directory" do
      expect(
        zsh('cd named-dir; pushd path/to; promptway; echo $_prompt_way').chomp
      ).to eq ("{<>}_~named-dir_/{_path_}/<to>")
    end

    example "cd into a under named directory" do
      expect(
        zsh('cd named-dir; pushd path/to/under-named-dir; promptway; echo $_prompt_way').chomp
      ).to eq ("{<>}_~named-dir_/{_path/to_}/<under-named-dir>")
    end

    example "cd into a under directory and return to the parent directory" do
      expect(
        zsh('cd named-dir; pushd path; pushd ..; promptway; echo $_prompt_way').chomp
      ).to eq ("{<>}<~named-dir>/{__}_path_")
    end

    example "cd into a under under directory and return to the parent directory" do
      expect(
        zsh('cd named-dir; pushd path/to; pushd ../..; promptway; echo $_prompt_way').chomp
      ).to eq ("{<>}<~named-dir>/{_path_}/_to_")
    end

    example "cd into a under named directory and return to the parent directory" do
      expect(
        zsh('cd named-dir; pushd path/to/under-named-dir; pushd ../../..; promptway; echo $_prompt_way').chomp
      ).to eq ("{<>}<~named-dir>/{_path/to_}/_under-named-dir_")
    end
  end
end