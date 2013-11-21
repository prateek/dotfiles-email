pkg notmuch

bork_pkg_mutt_kz () {
  name="mutt-kz"
  version="1.5.22"
  dependencies="pkg: notmuch"
  github_loc="karelzak/mutt-kz"
  git_ref="master"
  case $1 in
    depends) echo "$dependencies" ;;
    status)
      has_exec "env MAILDIR=~ mutt -v" "$version" "--enable-notmuch"
      [ "$?" -eq 0 ] && return 0 || return 10
      ;;
    install)
      cd $(mktemp -d -t mutt)
      github $github_loc
      cd mutt-kz
      prefix=$(command brew diy --set-version $version)
      ./prepare
      ./configure $prefix --enable-notmuch
      make
      make install
      command brew link mutt-kz
  esac
}
pkg mutt_kz

pkg sqlite
pkg offline-imap
pkg contacts
pkg urlview
pkg msmtp
pkg lynx
pkg gnupg
pkg gpgme

cd $HOME
symlink 'configs/*' --tmpl=".\$f"
permissions .msmtprc 600
directories .mail .mutt/cache .mutt/tmpdir .offlineimap

