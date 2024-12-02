{ input, lib }:
let
  inherit (builtins)
    length
    elemAt
    all
    any
    ;

  data = map (line: map lib.toInt (lib.filter (a: a != "") (lib.splitString " " line))) (
    lib.aoc.lines input
  );

  isSafe =
    rpt:
    let
      windowed = map (idx: {
        fst = elemAt rpt idx;
        snd = elemAt rpt (idx + 1);
      }) (lib.range 0 ((length rpt) - 2));
    in
    ((all ({ fst, snd }: fst < snd) windowed) || (all ({ fst, snd }: fst > snd) windowed))
    && (all ({ fst, snd }: (lib.aoc.abs (fst - snd)) <= 3) windowed);
in
{
  part1 = lib.count isSafe data;

  part2 = lib.count (
    rpt': any isSafe ((lib.singleton rpt') ++ (map (lib.aoc.removeIndex rpt') (lib.aoc.indices rpt')))
  ) data;
}
