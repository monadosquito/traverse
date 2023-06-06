helpMsg="
Traverse git repositories using a command.

traverse
    [--amending-prefix <amending_prefix>]
    [-h | --help]
    [-k | --keep <revision>]
    [-p | --prefix <prefix>]
    [-q | --quiet]
    [-v | --verbose]
    <amended_repository_path>
    -- {<amending_repository_path>...}
    -- <command>

At each <amended_repository_path> commit \
that has a <prefix><body> subject \
check out each <amending_repository_path> commit \
whose subject contains a <body> substring, \
execute a <command> command, and amend the former.

--amending-prefix (feat.*:)
    a subject pattern to select <amending_repository_paths> commits by

-h, --help (0)
    whether to print the help message and then exit

-k, --keep (<root>)
    a parent revision up to which to traverse a currently checked out revision

-p, --prefix (feat.*:)
    a subject pattern to select <amended_repository_path> commits by

-q, --quiet (0)
    whether to suppress output

-v, --verbose (0)
    whether to execute the git diff command at each iteration\
"
noAmendedPathErr='<amended_repository_path> argument not passed'
noFlagOrOptErr () {
    echo "$1 flag or option undefined"
}
iterMsg () {
    echo "at '$1' in ${@:2}"
}
verbIterMsg () {
    bold=$(tput bold)
    echo -e "$bold$(iterMsg $1 ${@:2})\n\n$(git diff --color)"
}

amendingPaths=()
args=()
cmdBits=()
amendedPfx=feat.*:
help=0
readAmendingPaths=0
keep=$(git log --pretty=%h | tail -1)
out=/dev/stdout
quiet=0
vbs=0
amendingPfx=$amendedPfx
amendingPfxPassed=0
while (( $# > 0 ))
do
    case $1 in
        --)
            if (( $readAmendingPaths == 0 ))
            then
                readAmendingPaths=1
                shift
            else
                shift
                cmdBits=("$@")
                break
            fi
            ;;
        -h | --help)
            echo "$helpMsg"
            exit
            ;;
        -p | --prefix)
            amendedPfx=$2
            if (( $amendingPfxPassed == 0 ))
            then
                amendingPfx="$amendedPfx"
            fi
            shift
            shift
            ;;
        -k | --keep)
            keep=$2
            shift
            shift
            ;;
        -q | --quiet)
            out=/dev/null
            quiet=1
            shift
            ;;
        -v | --verbose)
            vbs=1
            out=/dev/null
            shift
            ;;
        --amending-prefix)
            amendingPfx=$2
            amendingPfxPassed=1
            shift
            shift
            ;;
        *)
            if (( $readAmendingPaths == 0 ))
            then
                case $1 in
                    -* | --*)
                        echo "$noFlagOrOptErr"
                        exit 1
                        ;;
                    *)
                        args+=("$1")
                        ;;
                esac
            else
                amendingPaths+=("$1")
            fi
            shift
            ;;
    esac
done
set -- "${args[@]}"

: ${1:?"$noAmendedPathErr"}

amendedPath=$1

cd $amendedPath
IFS=$'\n'
amendedSubs=($(git log --reverse --grep="$amendedPfx" --pretty=%s $keep.. \
              | sed "s/$amendedPfx *//g"
              )
            )
unset $IFS
git \
    -c "core.editor\
            =\
            sed \
                --in-place \
                --regexp-extended \
                '/$keep/,$ s/pick (.* $amendedPfx.*)/edit \1/g'\
       " \
    rebase \
        --interactive \
        --root \
        --strategy-option=theirs \
        &> /dev/null
initAmendedPath=$(pwd)
initAmendingRevs=()
for amendingPath in "${amendingPaths[@]}"
do
    cd "$amendingPath"
    initAmendingRev=$(git name-rev --name-only @)
    if [[ $initAmendingRev == undefined ]]
    then
        initAmendingRev=$(git rev-parse @)
    fi
    initAmendingRevs+=($initAmendingRev)
done
cd "$initAmendedPath"
conflWithPrevCmt=0
for amendedSubIx in "${!amendedSubs[@]}"
do
    smlrSubAmendingPaths=()
    sameAmendedSubAheadNum=$(echo -e "${amendedSubs[*]:$amendedSubIx}" \
                            | grep "${amendedSubs[$amendedSubIx]}" \
                            | wc --lines
                            )
    for amendingPath in "${amendingPaths[@]}"
    do
        cd "$amendingPath"
        amendingSubPtrn="$amendingPfx *${amendedSubs[$amendedSubIx]}"
        amendingHashes=($(git log \
                              --reverse \
                              --grep="$amendingSubPtrn" \
                              --pretty=%H
                         )
                       )
        if (( ${#amendingHashes[@]} ))
        then
            smlrSubAmendingPaths+=("$amendingPath")
            amendingHashIx=$(( ${#amendingHashes[@]} - $sameAmendedSubAheadNum ))
            git checkout --quiet ${amendingHashes[$amendingHashIx]}
        fi
    done
    cd "$initAmendedPath"
    git checkout --theirs --quiet .
    "${cmdBits[@]}"
    if (( $? > 0 ))
    then
        git rebase --abort
        exit 1
    fi
    for amendingPathIx in ${!amendingPaths[@]}
    do
        cd "${amendingPaths[$amendingPathIx]}"
        git checkout --quiet ${initAmendingRevs[$amendingPathIx]}
    done
    cd "$initAmendedPath"
    if (( $vbs == 1 ))
    then
        echo -e \
            "$(verbIterMsg \
                   ${amendedSubs[$amendedSubIx]} \
                   ${smlrSubAmmendingPaths[@]}
              )
            "
    fi
    git add .
    iterMsg "${amendedSubs[$amendedSubIx]}" "${smlrSubAmendingPaths[@]}" > $out
    if (( $amendedSubIx == ${#amendedSubs[@]} - 1 ))
    then
        git -c core.editor=true rebase --continue | sed '/^[.*,^[^ ].*/d' > $out
        break
    fi
    if (( $conflWithPrevCmt == 0 ))
    then
        git commit --amend --no-edit --quiet
    fi
    git -c core.editor=true rebase --continue &> /dev/null
    conflWithPrevCmt=$?
done
