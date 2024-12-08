{ input, lib }:
let
  inherit (builtins)
    elemAt
    length
    filter
    getAttr
    genList
    partition
    ;

  data = map (
    line:
    let
      parts = lib.splitString ": " line;
    in
    {
      value = lib.toInt (elemAt parts 0);
      components = map lib.toInt (lib.splitString " " (elemAt parts 1));
    }
  ) (lib.aoc.lines input);

  concatInt =
    a: b:
    if b < 10 then
      a * 10 + b
    else if b < 100 then
      a * 100 + b
    else if b < 1000 then
      a * 1000 + b
    else if b < 10000 then
      a * 10000 + b
    else if b < 100000 then
      a * 100000 + b
    else if b < 1000000 then
      a * 1000000 + b
    else if b < 10000000 then
      a * 10000000 + b
    else if b < 100000000 then
      a * 100000000 + b
    else
      throw "${toString b} is too big";

  test =
    concatOperator:
    lib.fix (
      self:
      { value, components }:
      if length components == 1 then
        elemAt components 0 == value
      else
        let
          fst = elemAt components 0;
          snd = elemAt components 1;
          rest = genList (i: elemAt components (i + 2)) (length components - 2);

          testFn =
            fn:
            let
              result = fn fst snd;
            in
            result <= value
            && self {
              inherit value;
              components = [ result ] ++ rest;
            };
        in
        testFn builtins.add || testFn builtins.mul || concatOperator && testFn concatInt
    );

  part1Results = partition (test false) data;
  part2Right = part1Results.right ++ filter (test true) part1Results.wrong;
in
{
  part1 = lib.aoc.sum (map (getAttr "value") part1Results.right);
  part2 = lib.aoc.sum (map (getAttr "value") part2Right);
}
