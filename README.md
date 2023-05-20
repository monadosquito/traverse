# Description

Traverse git repositories using a command.

```bash
traverse
    [-h | --help]
    [-k | --keep <revision>]
    [-p | --prefix <prefix>]
    [-q | --quiet]
    [-v | --verbose]
    <amended_repository_path>
    -- {<amending_repository_path>...}
    -- <command>
```

## Features

- at each \<amended\_repository\_path\> commit
that has a \<prefix\>\<body\> subject
to check out each \<amending\_repository\_path\> commit
whose subject contains a \<body\> substring,
execute a \<command\> command, and amend the former

# Installation flow

Follow the [`unpath` tool installation flow](https://github.com/monadosquito/unpath#installation-flow).

# Usage flow

1. Set up an environment.
2. Traverse git repositories.

# Set up

1.
    - Enter the nix shell using the `nix-shell` command.
    - Enter \<amended\_repository\_path\>
    and \<amending\_repository\_paths\> repositories
    using the `cd` command.
2. Select \<amended\_repository\_path\>
and \<amending\_repository\_paths\> branches to traverse
using the `git checkout` command.

## Notes

- The `nix-shell` command must be executed either
from a dependee root directory
or with a path to either it
or the `shell.nix` file supplied.

# Traverse

Execute the `traverse <amended_repository_path> -- {<amending_repository_path>...} -- <command>` command.

## Notes

- The `git` tool must be available
in the nix shell in which the command is executed.

# Convention

This tool follows the [convention](https://github.com/monadosquito/bem#convention)
followed by the [`bem` library](https://github.com/monadosquito/bem).

---

## Table 1

the flag and option descriptions

|Flag or option   |Default value|Description                                                               |
|-----------------|-------------|--------------------------------------------------------------------------|
|`-h`, `--help`   |`0`          |whether to print the help message and then exit                           |
|`-k`, `--keep`   |\<root\>     |a parent revision up to which to traverse a currently checked out revision|
|`-p`, `--prefix` |`feat.*:   ` |a subject pattern to select \<amended\_repository\_path\> commits by      |
|`-q`, `--quiet`  |`0`          |whether to suppress output                                                |
|`-v`, `--verbose`|`0`          |whether to execute the `git diff` command at each iteration               |
