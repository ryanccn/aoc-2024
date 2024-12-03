let
  sources = import ./npins;
  nixpkgs-lib = import "${sources.nixpkgs}/lib";

  inherit (builtins)
    add
    elemAt
    genList
    isList
    isString
    length
    stringLength
    ;
in
nixpkgs-lib.fix (
  nixpkgs-lib.extends (lib: _: {
    aoc = {
      abs = a: if a > 0 then a else (-a);
      eq = a: b: a == b;

      sum = lib.foldr add 0;
      indices =
        l:
        let
          lengthFn =
            if isList l then
              length
            else if isString l then
              stringLength
            else
              throw "${toString l} is neither a list nor a string";
        in
        lib.range 0 ((lengthFn l) - 1);

      safeDigitToInt =
        c:
        if c == "0" then
          0
        else if c == "1" then
          1
        else if c == "2" then
          2
        else if c == "3" then
          3
        else if c == "4" then
          4
        else if c == "5" then
          5
        else if c == "6" then
          6
        else if c == "7" then
          7
        else if c == "8" then
          8
        else if c == "9" then
          9
        else
          null;

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
