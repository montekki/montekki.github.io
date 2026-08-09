#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="${TMPDIR:-/tmp}/montekki-tikz"
out_dir="$repo_root/static/generated"

if ! command -v pdflatex >/dev/null 2>&1; then
  echo "error: pdflatex is required to render TikZ files" >&2
  exit 1
fi

if ! command -v dvisvgm >/dev/null 2>&1; then
  echo "error: dvisvgm is required to render TikZ files" >&2
  exit 1
fi

mkdir -p "$tmp_dir" "$out_dir"

for src in "$repo_root"/tikz/*.tex; do
  [ -e "$src" ] || continue

  name="$(basename "$src" .tex)"
  work_dir="$tmp_dir/$name"
  mkdir -p "$work_dir"

  for variant in light dark; do
    if [ "$variant" = "light" ]; then
      foreground="black"
    else
      foreground="white"
    fi

    job_name="$name-$variant"

    pdflatex \
      -interaction=nonstopmode \
      -halt-on-error \
      -jobname="$job_name" \
      -output-directory="$work_dir" \
      "\\def\\circuitcolor{$foreground}\\input{$src}" >/dev/null

    dvisvgm \
      --pdf \
      --exact \
      --font-format=woff \
      --output="$out_dir/$job_name.svg" \
      "$work_dir/$job_name.pdf" >/dev/null

    echo "rendered static/generated/$job_name.svg"
  done
done
