class people::koko1000ban {
  include stdlib
  include iterm2::stable
  include chrome
  include chrome::canary
  include mysql
  include sourcetree
  include rubymine
  include evernote
  include mou
  include sublime_text_2
  include charles
  include appcleaner
  include vagrant
  include virtualbox
  include packer
  include keyremap4macbook
  include keyremap4macbook::login_item
  include skype
  include sequel_pro
  include dropbox
  include pow
  include istatmenus3
  include osx
  include osxfuse
  include ruby

  package {
      [
        'tmux',
        'ack',
        'autoconf',
        'automake',
        'cmake',
        'cmigemo',
        'coreutils',
        'ctags',
        'dmd',
        'gettext',
        'git',
        'global',
        'gnu-tar',
        'gnutls',
        'go',
        'htop-osx',
        'jq',
        'jsonpp',
        'keychain',
        'libtool',
        'libxml2',
        'libxslt',
        'libyaml',
        'lv',
        'lynx',
        'moreutils',
        'ngrep',
        'nkf',
        'openssl',
        'parallel',
        'fswatch',
        'pcre',
        'percona-toolkit',
        'pkg-config',
        'readline',
        'reattach-to-user-namespace',
        'redis',
        'rsync',
        's3sync',
        'sqlite',
        'sshfs',
        'tcpflow',
        'the_silver_searcher',
        'tree',
        'varnish',
        'watch',
        'wget',
        'wireshark',
        'xz',
        'z',
        'zlib'
      ]:
    }

    package {
      'zsh':
        install_options => [
          '--disable-etcdir'
        ]
    }

    file_line { 'add zsh to /etc/shells':
      path    => '/etc/shells',
      line    => "${boxen::config::homebrewdir}/bin/zsh",
      require => Package['zsh'],
      before  => Osx_chsh[$::luser];
    }

    osx_chsh { $::luser:
      shell   => "${boxen::config::homebrewdir}/bin/zsh";
    }

    package {
      'GoogleJapaneseInput':
        source => "http://dl.google.com/japanese-ime/latest/GoogleJapaneseInput.dmg",
        provider => pkgdmg;
      'Kobito':
        source   => "http://kobito.qiita.com/download/Kobito_v1.2.0.zip",
        provider => compressed_app;
      'XtraFinder':
        source   => "http://www.trankynam.com/xtrafinder/downloads/XtraFinder.dmg",
        provider => pkgdmg;
      'Shiftit':
        source => "https://github.com/downloads/fikovnik/ShiftIt/ShiftIt-1.5.zip",
        provider => compressed_app;
      'nvALT':
        source => "http://abyss.designheresy.com/nvaltb/nvalt2.2b106.zip",
        provider => compressed_app;
      'MySQLWorkbench':
        source => "http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-6.0.7.1-osx-i686.dmg/from/http://cdn.mysql.com/",
        provider => pkgdmg;
    }

    $home     = "/Users/${::luser}"
    $src      = "${home}/src"
    $dotfiles = "${src}/dotfiles"

    # ~/src/dotfilesにGitHub上のdotfilesリポジトリを
    # git-cloneする。そのとき~/srcディレクトリがなければいけない。
    repository { $dotfiles:
      source  => "koko1000ban/dotfiles",
      extra   => "--recursive",
      require => File[$src]
    }
    # git-cloneしたらインストールする
    exec { "sh ${dotfiles}/setup.sh":
      cwd => $dotfiles,
      creates => "${home}/.zshrc",
      require => Repository[$dotfiles],
    }

    $sublimetext2_packages = "${src}/sublimetext2-packages"
    repository { $sublimetext2_packages:
      source  => "koko1000ban/sublimetext2_packages",
      require => File[$src]
    }

    exec { "ruby ${sublimetext2_packages}/symlink.rb":
      cwd => $sublimetext2_packages,
      creates => "${home}/Library/Application Support/Sublime Text 2/Installed Packages/Package Control.sublime-package",
      require => Repository[$sublimetext2_packages],
    }

    keyremap4macbook::set{
      'repeat.initial_wait':
        value => '50';
      'repeat.wait':
        value => '60';
      'repeat.consumer_initial_wait':
        value => '50';
      'repeat.consumer_wait':
        value => '60';
      'repeat.keyoverlaidmodifier_initial_wait':
        value  => '50';
    }

    vagrant::plugin { 'aws' }
    vagrant::plugin { 'vbox-snapshot' }

    ruby::plugin { 'rbenv-vars':
      ensure => 'v1.2.0',
      source  => 'sstephenson/rbenv-vars'
    }

    $version = "2.0.0"
    ruby::gem{ "bundler for ${version}":
      gem => 'bundler',
      ruby => $version,
      version => '~> 1.2.0'
    }

    ruby::gem{ "powder for ${version}":
      gem => 'powder',
      ruby => $version
    }

}
