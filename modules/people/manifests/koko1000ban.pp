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
  #include charles
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

  #include osxfuse <- OSXFUSE is not compatible 10.9 now..
  include ruby

  package {
      [
        'tmux',
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
        'fswatch',
        'pcre',
        'proctools',
        #'percona-toolkit',
        'pkg-config',
        'readline',
        'reattach-to-user-namespace',
        'redis',
        's3sync',
        'sqlite',
        'sshfs',
        # 'tcpflow', install error...
        'the_silver_searcher',
        'tree',
        'varnish',
        'watch',
        'wget',
        'wireshark',
        'wrk',
        'xz',
        'z',
      ]:
    }

    # Dock
    #include osx::dock::autohide
    #class osx::dock::kill_dashbord{
    # include osx::dock
    #  boxen::osx_defaults { 'kill dashbord':
    #    user   => $::boxen_user,
    #    domain => 'com.apple.dashboard',
    #    key    => 'mcx-disabled',
    #   value  => YES,
    #    notify => Exec['killall Dock'];
    #  }
    #}
    #include osx::dock::kill_dashbord

    # Miscellaneous
    #include osx::no_network_dsstores # disable creation of .DS_Store files on network shares
    #include osx::software_update # download and install software updates
    #include osx::global::enable_keyboard_control_access

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
        source => 'http://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-gpl-5.2.47-osx-i686.dmg',
        provider => appdmg;
    }

    $home     = "/Users/${::luser}"
    $src      = "${home}/src"
    $dotfiles = "${src}/dotfiles"

    # ~/src/dotfilesにGitHub上のdotfilesリポジトリを
    # git-cloneする。そのとき~/srcディレクトリがなければいけない。
    repository { $dotfiles:
      source  => "koko1000ban/dotfiles",
      extra   => "--recurse-submodules",
      require => File[$src]
    }
    # git-cloneしたらインストールする
    exec { "ruby ${dotfiles}/setup.rb":
      cwd => $dotfiles,
      creates => "${home}/.zshrc",
      require => Repository[$dotfiles],
    }

    $sublimetext2_packages = "${src}/sublimetext2-packages"
    repository { $sublimetext2_packages:
      source  => "koko1000ban/sublimetext2-packages",
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

    vagrant::plugin { 'aws':
      license => undef;
    }
    vagrant::plugin { 'vbox-snapshot':
      license => undef;
    }

    $version = "2.0.0"
    class { 'ruby::global':
      version => $version
    }

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
