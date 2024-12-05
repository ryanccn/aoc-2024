set unstable := true

eval day part="":
    nix eval --impure --option max-call-depth 1000000 --show-trace --json --expr \
    "((import ./day{{ day }}.nix) { lib = import ./_lib.nix; input = builtins.readFile ./inputs/day{{ day }}.txt; }){{ if part != "" { ".part" + part } else { "" } }}"
