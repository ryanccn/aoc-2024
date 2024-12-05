{ input, lib }:
let
  inherit (builtins)
    elemAt
    length
    ;

  xy = x: {
    inherit x;
    y = x;
  };

  chars = map lib.stringToCharacters (lib.aoc.lines input);
  indices = lib.cartesianProduct {
    x = lib.aoc.indices chars;
    y = lib.aoc.indices (elemAt chars 0);
  };

  getc =
    x: y:
    if x >= 0 && x < length chars && y >= 0 && y < length (elemAt chars 0) then
      elemAt (elemAt chars x) y
    else
      null;

  deltas1 = lib.remove (xy 0) (lib.cartesianProduct (xy (lib.range (-1) 1)));

  sol1 =
    { x, y }:
    lib.count (
      d:
      getc x y == "X"
      && getc (x + d.x) (y + d.y) == "M"
      && getc (x + d.x * 2) (y + d.y * 2) == "A"
      && getc (x + d.x * 3) (y + d.y * 3) == "S"
    ) deltas1;

  deltas2 = lib.cartesianProduct (xy (lib.remove 0 (lib.range (-1) 1)));

  sol2 =
    { x, y }:
    getc x y == "A"
    && (lib.count (d: getc (x + d.x) (y + d.y) == "M" && getc (x - d.x) (y - d.y) == "S") deltas2) == 2;
in
{
  part1 = lib.aoc.sum (map sol1 indices);
  part2 = lib.count sol2 indices;
}
