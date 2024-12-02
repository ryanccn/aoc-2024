set unstable := true

eval day part="":
    nix eval --impure --json --expr "(import ./day{{ day }}.nix) { \
        lib = import ./_lib.nix; \
        input = builtins.readFile ./inputs/day{{ day }}.txt; \
    }" \
    | jq '{{ if part != "" { ".part" + part } else { "." } }}'
