# JJ helpers
jje() { # edit
  jj edit "${1}"
}
jjrb() { # make rebase easier
  jj rebase -s "${1}" -d "${2}"
}
_lstrip_blanks() {
  sed '/[^[:space:]]/,$!d'
  #     |             ||\
  #     |             |\ delete
  #     |             | negate (everything NOT in range)
  #     |             create a range ending at the last line
  #     match any line with a non-space character
}
_stacked_tag="stacked-commit: true"

jjd() {
  jj diff -r ${1}
}
jju() {
  REV="${1:-this}"
  revs="$(jj log -r "$REV" --no-graph -T 'self.change_id().short()')"
  # Update revs to reflect stacked state
  for rev in "$revs"; do
    message="$(jj log -r $rev --no-graph -T 'self.description()')"
    mutparents="$(jj log -r "(immutable()..$rev)-&mutable()" --no-graph -T 'self.change_id().short()')"
    has=$([[ "$message" == *"$_stacked_tag" ]]; echo $((1 - $?)))
    needs=$([[ "$mutparents" != "" ]]; echo $((1 - $?)))
    if (( $needs && ! $has )); then
      message=$(echo "$message"; echo; echo "$_stacked_tag")
      jj describe -r $rev -m "$message"
    fi
    if (( $has && ! $needs )); then
      message=$(echo "$message" | sed "s/$_stacked_tag//g" | tac | _lstrip_blanks | tac)
      jj describe -r $rev -m "$message"
    fi
  done
  # Push each rev
  for rev in "$revs"; do
    remote="$(jj log -r $rev --no-graph -T 'self.remote_bookmarks().map(|b| b.name())')"
    if [[ $remote == "" ]]; then
      jj git push -c $rev
    else
      jj git push -r $rev
    fi
  done
}
jjua() {
  jj git push --all-remotes
}
jjpr() { # creates a new PR using the current branch
  REV="${1:-this}"
  branch="$(jj log -r "${REV}" --no-graph -T 'coalesce(self.remote_bookmarks().map(|s| s.name()))' | cut -d' ' -f1)"
  if [[ "$branch" == "" ]] ; then
    echo 'No branch'
    return 1
  fi
  remoteaddr=$(jj git remote list | rg "^origin " | cut -d' ' -f2)
  if [[ "$remoteaddr" == "" ]] || [[ "$remoteaddr" != git@github.com:* ]]; then
    echo 'No/bad remoteaddr'
    return 1
  fi
  repoid="${remoteaddr#git@github.com:}"
  user="${repoid%%/*}"
  title=$(jj log -r "${REV}" --no-graph -T 'self.description().first_line()')
  if [[ "$title" == "" ]] ; then
    echo 'No description'
    return 1
  fi
  body=$(jj log -r "${REV}" --no-graph -T 'self.description()' | tail -n +2 | _lstrip_blanks | sed "s/$_stacked_tag//g" | tac | _lstrip_blanks | tac)
  GIT_DIR=.git/ gh pr create --head "${user}:${branch}" --title "${title}" --body "${body}"
}
jjrbc() { # rebase all children
  jjrb "all:${1}+~immutable()" "${2}"
}
jjsb() { # submit specified change
  if [[ "$(jj log --no-graph -T 'change_id ++ "\n"' -r ${1} | wc -l)" != "1" ]]; then
    echo 'Revset more than one change_id'
    return 1
  fi
  REV="$(jj log --no-graph -T 'change_id' -r ${1})"
  if [[ "$REV" == "" ]]; then
    echo 'Usage: jjsb <REV>'
    return 1
  fi
  parent="$(jj log --no-graph -T 'change_id' -r ${1}-)"
  if [[ "$parent" == "" ]] ; then
    echo 'Missing parent'
    return 1
  fi
  branch="$(jj log -r "${REV}" --no-graph -T 'coalesce(self.remote_bookmarks().map(|s| s.name()))' | cut -d' ' -f1)"
  if [[ "$branch" == "" ]] ; then
    echo 'No branch'
    return 1
  fi
  if [[ "$(jj git push --dry-run -b $branch 2>&1)" != *"Nothing changed."* ]] ; then
    echo 'Unpushed changes'
    return 1
  fi
  remoteaddr=$(jj git remote list | rg "^origin " | cut -d' ' -f2)
  if [[ "$remoteaddr" == "" ]] || [[ "$remoteaddr" != git@github.com:* ]]; then
    echo 'No/bad remoteaddr'
    return 1
  fi
  repoid="${remoteaddr#git@github.com:}"
  repoid="${repoid%.git}"
  user="${repoid%%/*}"
  # NOTE: This assumes the remote is a fork from upstream.
  upstreamid=$(gh repo view "${repoid}" --json parent --jq '"\(.parent.owner.login)/\(.parent.name)"')
  if [[ "$upstreamid" == "" ]]; then
    echo 'No upstreamid'
    return 1
  fi
  gh pr merge --repo "${upstreamid}" --squash "${user}:${branch}" && \
    gh repo sync "${repoid}" -b "main" && \
    jj git fetch && \
    jjrbc ${parent} main && \
    jj bookmark delete "${branch}" && \
    jj git push --bookmark "${branch}" && \
    jj abandon $REV
}
jjsync() { # sync fork to upstream
  remoteaddr=$(jj git remote list | rg "^origin " | cut -d' ' -f2)
  if [[ "$remoteaddr" == "" ]] || [[ "$remoteaddr" != git@github.com:* ]]; then
    echo 'No/bad remoteaddr'
    return 1
  fi
  repoid="${remoteaddr#git@github.com:}"
  repoid="${repoid%.git}"
  gh repo sync "${repoid}" -b "main"
  jj git fetch
}
jjs() { # sync a branch
  REV="${1:-this}"
  jj git fetch
  jjrb "all:roots(immutable()..(${REV}))&mutable()" "local_heads()"
  jj abandon -r 'empty() ~ @ ~ root()'
}
jjsh() { # sync here
  jjs 'mutable()&children(latest(immutable()&ancestors(@)))'
}
jjbd() { # delete bookmark
  branch="${1}"
  jj bookmark delete "${branch}" && jj git push --bookmark "${branch}"
}
