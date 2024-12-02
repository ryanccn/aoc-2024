let
  sources = import ./npins;
  nixpkgs-lib = import "${sources.nixpkgs}/lib";

  inherit (builtins)
    add
    elemAt
    genList
    length
    ;
in
nixpkgs-lib.fix (
  nixpkgs-lib.extends (lib: _: {
    aoc = {
      abs = a: if a > 0 then a else (-a);
      eq = a: b: a == b;

      sum = lib.foldr add 0;
      indices = l: lib.range 0 ((length l) - 1);

      removeIndex =
        lst: idx:
        assert lib.assertMsg (
          idx >= 0 && idx < length lst
        ) "idx ${toString idx} is out of bounds for list ${toString lst}";
        genList (idx': if idx' < idx then elemAt lst idx' else elemAt lst (idx' + 1)) ((length lst) - 1);

      lines = s: lib.filter (a: a != "") (lib.splitString "\n" s);
    };
  }) (_: nixpkgs-lib)
)
