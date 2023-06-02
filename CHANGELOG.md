# [Unreleased]

## Added

- The revisions containing the commits having the same subject can be traversed.
- The subject patterns to select \<amended\_repository\_path\>
and \<amending\_repository\_paths\> commits by can differ
by setting the later as a value of the `--amending-prefix` option.
- If conflicts are occurred,
then a patch of the commit causing them is chosen and modified
by a \<command\> command invocation.
- The `git diff` command can be executed
at each iteration by passing the `--verbose` (`-v`) flag
- Output can be suppressed by passing the `--quiet` (`-q`) flag.
- A current \<amended\_repository\_path\> commit subject
without its \<prefix\> prefix
and \<amending\_repository\_paths\> repositories
sharing it are printed
at each iteration.
- Revisons can be traversed up to an older commit
by passing its hash as a value of the `--keep` (`-k`) flag.
- If a \<command\> command fails,
then an \<amended\_repository\_path\> rebase is aborted.
- An \<amended\_repository\_path\> repository can be traversed
at each \<amended\_repository\_path\> commit
that has a \<prefix\>\<body\> subject
checking out each \<amending\_repository\_path\> commit
whose subject contains a \<body\> substring,
executing a \<command\> command, and amending the former.
