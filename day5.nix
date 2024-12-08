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
    mapAttrs
    groupBy
    ;

  center = l: lib.toInt (elemAt l (((length l) - 1) / 2));

  sections = lib.splitString "\n\n" (lib.trim input);

  rules = mapAttrs (_: foldl' (acc: v: acc ++ [ (elemAt v 1) ]) [ ]) (
    groupBy (v: elemAt v 0) (map (lib.splitString "|") (lib.aoc.lines (elemAt sections 0)))
  );

  updates = map (lib.splitString ",") (lib.aoc.lines (elemAt sections 1));

  constructIndices =
    l: foldl' (acc: { i, v }: acc // { ${v} = i; }) { } (lib.imap0 (i: v: { inherit i v; }) l);

  outcomes = partition (
    update:
    let
      updateIndices = constructIndices update;
    in
    all (
      { name, value }:
      let
        fst = updateIndices.${name} or null;
      in
      fst == null
      || all (
        value':
        let
          snd = updateIndices.${value'} or null;
        in
        snd == null || fst < snd
      ) value
    ) (lib.attrsToList rules)
  ) updates;
in
{
  part1 = lib.aoc.sum (map center outcomes.right);
  part2 = lib.aoc.sum (map center (map (sort (a: b: elem b rules.${a} or [ ])) outcomes.wrong));
}
