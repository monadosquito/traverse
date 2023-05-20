# [Unreleased]

## Added

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
