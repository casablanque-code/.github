#!/usr/bin/env bash
# Create a new GitHub repository from one of the templates in ../templates.
#
#   scripts/new-repo.sh <rust|go|node-ts> <name> "<description>" [--private]
#   scripts/new-repo.sh <rust|go|node-ts> <name> "<description>" --out DIR
#                                   (render files only: no git, no GitHub)
#
# Creates ./<name>, fills in name/description everywhere, creates the GitHub repo,
# pushes `main` and applies scripts/setup-repo.sh. Needs: git, gh (logged in).
# If the push is rejected for workflow files: gh auth refresh -s workflow
set -euo pipefail

OWNER=casablanque-code
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

die() { echo "error: $*" >&2; exit 1; }
usage() { sed -n '2,9p' "${BASH_SOURCE[0]}" >&2; exit 2; }

(( $# >= 3 )) || usage
lang=$1 name=$2 desc=$3
shift 3
visibility=--public
out=""
while (( $# )); do
  case $1 in
    --private) visibility=--private ;;
    --out) out=${2:?--out needs a directory}; shift ;;
    *) usage ;;
  esac
  shift
done

case $lang in
  go) ci=go-ci ;;
  rust) ci=rust-ci ;;
  node-ts) ci=node-ci ;;
  *) die "unknown template '$lang' (rust | go | node-ts)" ;;
esac

[[ $name =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "bad repository name '$name'"
[[ $lang != rust || $name =~ ^[A-Za-z][A-Za-z0-9_-]*$ ]] || die "'$name' is not a valid Cargo package name"
[[ $lang != node-ts || $name =~ ^[a-z0-9][a-z0-9._-]*$ ]] || die "npm package names must be lowercase"
case $desc in
  '' | *'"'* | *\\* | *$'\n'*) die "description must be non-empty and contain no quotes, backslashes or newlines" ;;
esac

dest=${out:-$PWD/$name}
[[ ! -e $dest ]] || die "$dest already exists"
if [[ -z $out ]]; then
  gh repo view "$OWNER/$name" >/dev/null 2>&1 && die "$OWNER/$name already exists on GitHub"
fi

esc() { printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'; }

mkdir -p "$dest"
cp -a "$ROOT/templates/_common/." "$dest/"
cp -a "$ROOT/templates/$lang/." "$dest/"
[[ -d $dest/cmd/__NAME__ ]] && mv "$dest/cmd/__NAME__" "$dest/cmd/$name"
find "$dest" -type f -exec sed -i.bak \
  -e "s|__NAME__|$(esc "$name")|g" \
  -e "s|__DESC__|$(esc "$desc")|g" \
  -e "s|__YEAR__|$(date +%Y)|g" \
  -e "s|__CI__|$ci|g" {} +
find "$dest" -name '*.bak' -type f -delete

if [[ -n $out ]]; then
  echo "rendered $lang template into $dest"
  exit 0
fi

git -C "$dest" init -q -b main
git -C "$dest" add -A
git -C "$dest" commit -q -m "chore: initial commit from templates/$lang"
gh repo create "$OWNER/$name" "$visibility" --description "$desc" --source "$dest" --remote origin --push
"$ROOT/scripts/setup-repo.sh" "$OWNER/$name"

echo
echo "Done: https://github.com/$OWNER/$name"
echo "Local copy: $dest"
