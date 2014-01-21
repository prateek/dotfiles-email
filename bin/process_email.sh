#!/bin/sh

mail_root="$HOME/.mail"
accounts="Lyonheart Sanehatter"
tags_to_rectify="trash spam inbox"

maildir_for () {
  echo "$mail_root/$1"
}

move_to () {
  search=$1
  destination=$2
  result="$(notmuch search --output=files $search)"
  for email in $result; do
    mv -f $email $destination
  done
}

notmuch new
for tag in $tags_to_rectify; do
  emails_for_tag=$(notmuch count tag:$tag and not folder:$tag)
  if [[ $emails_for_tag > 0 ]]; then
    echo "moving $emails_for_tag emails to $tag"
    for account in $accounts; do
      move_to "folder:$account and tag:$tag and not folder:$tag" "$(maildir_for $account)/$tag/cur"
    done
  fi
  emails_for_untag=$(notmuch count not tag:$tag and folder:$tag and not folder:archive)
  if [[ $emails_for_untag > 0 ]]; then
    echo "moving $emails_for_tag emails from $tag"
    for account in $accounts; do
      move_to "folder:$account and not tag:$tag and folder:$tag" "$(maildir_for $account)/archive/cur"
    done
  fi
done

offlineimap
notmuch new

nm=""

alldirs=""
for account in $accounts; do
  nm+="+$(echo "$account" | awk '{print tolower($0)}') -- folder:$account and tag:new\n"
  dir=$(maildir_for $account)
  alldirs+=$(ls $dir)
  alldirs+="\n"
done
alldirs=$(echo "$alldirs" | sort)
dirs=""
hasdir () {
  present=$(echo "$dirs" | grep -e "^$1\$" > /dev/null)
  return $present
}
for dir in $alldirs; do
  if ! hasdir $dir; then
    dirs+="\n$dir"
  fi
done
dirs=$(echo "$dirs" | awk '{print tolower($0)}' | sed -E 's|(archive\|\[gmail\]\.important)||' | sort)
for dir in $dirs; do
  nm+="+$dir -- folder:$dir and tag:new\n"
done
nm+="-new -- tag:new"
echo "$nm" | notmuch tag --batch

mutt="virtual-mailboxes"
tags=$(echo "$dirs" | sed -E 's|(sent\|spam\|trash\|flagged\|drafts\|inbox)||')
for tag in $tags; do
  mutt+=" \"@$tag\" \"notmuch://?query=tag:$tag and not tag:trash\""
done
mutt+="\n"
echo "$mutt" > ~/.mutt/mailboxes

