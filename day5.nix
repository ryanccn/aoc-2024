{ input, lib }:
let
  inherit (builtins)
    elemAt
    all
    sort
    length
    partition
    elem
    foldl'
    ;

  center = l: elemAt l (((length l) - 1) / 2);

  sections = lib.splitString "\n\n" (lib.trim input);
  rules = map (l: map lib.toInt (lib.splitString "|" l)) (lib.aoc.lines (elemAt sections 0));
  updates = map (l: map lib.toInt (lib.splitString "," l)) (lib.aoc.lines (elemAt sections 1));

  findFirstIndexes =
    val1: val2:
    foldl'
      (state: el: {
        fst = if state.fst < 0 then if el == val1 then -state.fst - 1 else state.fst - 1 else state.fst;
        snd = if state.snd < 0 then if el == val2 then -state.snd - 1 else state.snd - 1 else state.snd;
      })
      {
        fst = -1;
        snd = -1;
      };

  outcomes = partition (
    update:
    all (
      rule:
      let
        idxs = findFirstIndexes (elemAt rule 0) (elemAt rule 1) update;
      in
      idxs.fst < 0 || idxs.snd < 0 || idxs.fst < idxs.snd
    ) rules
  ) updates;
in
{
  part1 = lib.aoc.sum (map center outcomes.right);
  part2 = lib.aoc.sum (map center (map (sort (a: b: elem [ a b ] rules)) outcomes.wrong));
}
