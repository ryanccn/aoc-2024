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

      isDigit =
        c:
        c == "0"
        || c == "1"
        || c == "2"
        || c == "3"
        || c == "4"
        || c == "5"
        || c == "6"
        || c == "7"
        || c == "8"
        || c == "9";

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
