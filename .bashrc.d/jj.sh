# JJ helpers
jje() { # edit
  jj edit "${1}"
}
jjrb() { # make rebase easier
  jj rebase -s "${1}" -d "${2}"
}
_lstrip_blanks() {
  sed '/\S/,$!d'
  #     |   ||\
  #     |   |\ delete
  #     |   | negate (everything NOT in range)
  #     |   create a range ending at the last line
  #     match any line with a non-space character
}
_stacked_tag="stacked-commit: true"
jjd() {
  jj diff -r ${1}
}
jju() {
  REV="${1:-this}"
  revs="$(jj log -r "$REV" --no-graph -T 'self.change_id().short() ++ " "')"
  # Update revs to reflect stacked state
  for rev in "$revs"; do
    message="$(jj log -r $rev --no-graph -T 'self.description()')"
    mutparents="$(jj log -r "(immutable()..$rev)-&mutable()" --no-graph -T 'self.change_id().short() ++ " "')"
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
  jjrb "${1}+~immutable()" "${2}"
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
  gh pr checks "${user}:${branch}" --watch -i=1 && \
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
  jjrb "roots(immutable()..(${REV}))&mutable()" "local_heads()"
  jj abandon -r 'empty() ~ @ ~ root()'
}
jjsh() { # sync here
  jjs 'mutable()&children(latest(immutable()&ancestors(@)))'
}
jjbd() { # delete bookmark
  branch="${1}"
  jj bookmark delete "${branch}" && jj git push --bookmark "${branch}"
}
jjdo() { # iterate over a revset
  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <revset> <command>"
    exit 1
  fi
  REVSET=$1
  COMMAND=$2
  # Get the current working-copy commit ID to return to it upon success.
  ORIGINAL_WC_COMMIT=$(jj log -r '@' --no-graph --template 'commit_id')
  # Get the list of commit IDs for the given revset.
  REVISIONS=$(jj log -r "$REVSET" --no-graph -T 'self.change_id().short() ++ " "')
  echo $REVISIONS
  # Iterate over each commit ID in the revset.
  for REV in $REVISIONS; do
    echo "--- Checking out revision: $REV ---"
    jj new "$REV"
    # Execute the command and check its exit status.
    if ! sh -c "$COMMAND"; then
      echo ""
      echo "Error: Command failed on revision $REV. Stopping execution." >&2
      echo "You are now at the broken revision." >&2
      exit 1
    fi
    echo "--- Command succeeded for revision: $REV ---"
    echo ""
  done
  # If the loop completes, return to the original revision.
  echo "Script finished successfully on all revisions."
  echo "--- Returning to original revision ---"
  jj edit "$ORIGINAL_WC_COMMIT"
}
jjfix() { # Misc jj fixes
  jj workspace update-stale
}
jjd() { # Diff
  jj diff -r ${1:-this}
}
jjds() { # Diff summary
  jj diff -r ${1:-this} --summary
}
jjpm() { # Push main branch
  REV="${1:-this}"
  jj bookmark move --allow-backwards --to $REV main
  jj git push --remote origin --bookmark main
}
jjsp() { # smart split: retain change ID and bookmarks on original description
  REV="${1:-this}"
  local orig_id=$(jj log -r "${REV}" -T 'change_id' --no-graph 2>/dev/null)
  if [[ -z "$orig_id" ]]; then
    echo "Error: Could not resolve target '${REV}'."
    return 1
  fi
  local orig_desc=$(jj log -r "$orig_id" -T 'description.first_line()' --no-graph)
  local orig_bookmarks=$(jj log -r "$orig_id" -T 'bookmarks.map(|b| b.name()).join(" ")' --no-graph)
  jj split -r "$orig_id"
  if [[ $? -ne 0 ]]; then
    echo "Split aborted."
    return 1
  fi
  local safe_desc="${orig_desc//\"/\\\"}"
  local match_ids=($(jj log -r "($orig_id | children($orig_id)) & description(substring:\"${safe_desc}\")" -T 'change_id ++ "\n"' --no-graph))
  local match_id=""
  if [[ ${#match_ids[@]} -eq 1 ]]; then
    match_id="${match_ids[0]}"
  elif [[ ${#match_ids[@]} -gt 1 ]]; then
    echo "Warning: Multiple commits matched the original description:"
    echo "  -> '$orig_desc'"
    echo ""
  elif [[ ${#match_ids[@]} -eq 0 ]]; then
    echo "Warning: No resulting commit retained the original description:"
    echo "  -> '$orig_desc'"
    echo ""
  fi
  if [[ -z "$match_id" ]]; then
    echo "Here are the resulting commits and their modified files:"
    echo "--------------------------------------------------------"
    jj log -r "$orig_id | children($orig_id)" --summary
    echo "--------------------------------------------------------"
    while true; do
      read -p "Enter the Change ID to retain original ID/bookmarks (or press Enter to skip): " user_input
      user_input=$(echo "$user_input" | xargs)
      if [[ -z "$user_input" ]]; then
        echo "Skipping Change ID and bookmark cleanup."
        return 0
      fi
      # Validate: Intersect the valid pool of commits with the user's input
      local valid_check=($(jj log -r "($orig_id | children($orig_id)) & ${user_input}" -T 'change_id ++ "\n"' --no-graph 2>/dev/null))
      if [[ ${#valid_check[@]} -eq 1 ]]; then
        match_id="${valid_check[0]}"
        break # Valid input, break out of the loop
      else
        echo "Error: '${user_input}' is not a valid or unique Change ID from this split. Please try again."
      fi
    done
  fi
  if [[ "$match_id" != "$orig_id" ]]; then
    echo "Fixing misaligned Change ID..."
    jj split -r "$orig_id" 'none()' -m ''
    jj rebase -r "$orig_id" --before "$match_id"
    jj squash --from "$match_id" --into "$orig_id"
  fi
  if [[ -n "$orig_bookmarks" ]]; then
    echo "Ensuring bookmarks point to original Change ID..."
    for bm in $orig_bookmarks; do
      jj bookmark move "$bm" --to "$orig_id" --allow-backwards
    done
  fi
}
