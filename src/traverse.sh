helpMsg="
Traverse git repositories using a command.

traverse
    [-h | --help]
    [-p | --prefix <prefix>]
    <amended_repository_path>
    -- {<amending_repository_path>...}
    -- <command>

At each <amended_repository_path> commit \
that has a <prefix><body> subject \
check out each <amending_repository_path> commit \
whose subject contains a <body> substring, \
execute a <command> command, and amend the former.

-h, --help (0)
    whether to print the help message and then exit

-p, --prefix (feat.*:)
    a subject pattern to select <amended_repository_path> commits by\
"
noAmendedPathErr='<amended_repository_path> argument not passed'
noFlagOrOptErr () {
    echo "$1 flag or option undefined"
}

amendingPaths=()
args=()
cmdBits=()
help=0
pfx=feat.*:
readAmendingPaths=0
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
            pfx=$2
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
amendedSubs=($(git log --reverse --grep="$pfx" --pretty=%s | sed "s/$pfx *//g"))
unset $IFS

git \
    -c "core.editor\
            =\
            sed \
                --in-place \
                --regexp-extended \
                's/pick (.* $pfx.*)/edit \1/g'\
       " \
    rebase \
        --interactive \
        --root \
        --strategy-option=theirs \
        &> /dev/null

initAmendedPath=$(pwd)
initAmendingSymRefs=()
for amendingPath in "${amendingPaths[@]}"
do
    cd "$amendingPath"
    initAmendingSymRefs+=($(git name-rev --name-only @))
done
cd "$initAmendedPath"
for amendedSub in "${amendedSubs[@]}"
do
    for amendingPath in "${amendingPaths[@]}"
    do
        cd "$amendingPath"
        amendingHash=$(git log --grep="$pfx *$amendedSub" --pretty=%H -1)
        if [[ -n $amendingHash ]]
        then
            git checkout --quiet $amendingHash
        fi
    done
    cd "$initAmendedPath"
    "${cmdBits[@]}"
    for amendingPathIx in ${!amendingPaths[@]}
    do
        cd "${amendingPaths[$amendingPathIx]}"
        git checkout --quiet ${initAmendingSymRefs[$amendingPathIx]}
    done
    cd "$initAmendedPath"
    git add .
    git commit --amend --no-edit --quiet
    if [[ $amendedSub == ${amendedSubs[-1]} ]]
    then
        git -c core.editor=true rebase --continue | sed '/^[.*,^[^ ].*/d'
        break
    fi
    git -c core.editor=true rebase --continue &> /dev/null
done
