{ input, lib }:
let
  inherit (builtins)
    sort
    lessThan
    elemAt
    ;

  parsed = map (line: map lib.toInt (lib.filter (a: a != "") (lib.splitString " " line))) (
    lib.aoc.lines input
  );

  mkList = idx: sort lessThan (map (arr: elemAt arr idx) parsed);
  left = mkList 0;
  right = mkList 1;
in
{
  part1 = lib.aoc.sum (map ({ fst, snd }: lib.aoc.abs (fst - snd)) (lib.zipLists left right));
  part2 = lib.aoc.sum (map (fst: fst * (lib.count (lib.aoc.eq fst) right)) left);
}
