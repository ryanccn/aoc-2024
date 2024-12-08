{ input, lib }:
let
  inherit (builtins)
    elemAt
    length
    elem
    attrNames
    ;

  puzzle = map lib.stringToCharacters (lib.aoc.lines input);

  startX = lib.lists.findFirstIndex (elem "^") null puzzle;
  startY = lib.lists.findFirstIndex (lib.aoc.eq "^") null (elemAt puzzle startX);

  get =
    x: y: forceObstacle:
    if forceObstacle != null && forceObstacle.x == x && forceObstacle.y == y then
      "#"
    else if x >= 0 && x < length puzzle && y >= 0 && y < length (elemAt puzzle 0) then
      elemAt (elemAt puzzle x) y
    else
      null;

  delta = [
    {
      x = -1;
      y = 0;
    }
    {
      x = 0;
      y = 1;
    }
    {
      x = 1;
      y = 0;
    }
    {
      x = 0;
      y = -1;
    }
  ];

  recurse =
    forceObstacle:
    lib.fix (
      self: x: y: direction: history:
      let
        delta' = elemAt delta direction;

        nx = x + delta'.x;
        ny = y + delta'.y;
        nc = get nx ny forceObstacle;

        key =
          if forceObstacle != null then
            "${toString x};${toString y};${toString direction}"
          else
            "${toString x};${toString y}";
      in
      if forceObstacle != null && history.${key} or false then
        false
      else if nc == null then
        if forceObstacle == null then attrNames history ++ [ key ] else true
      else if nc == "#" then
        self x y (if direction == 3 then 0 else direction + 1) (
          history // { ${if forceObstacle != null then key else null} = true; }
        )
      else
        self nx ny direction (history // { ${if forceObstacle == null then key else null} = true; })
    );

  pathPoints = lib.unique (
    map (
      key:
      let
        parts = lib.splitString ";" key;
      in
      {
        x = lib.toInt (elemAt parts 0);
        y = lib.toInt (elemAt parts 1);
      }
    ) (recurse null startX startY 0 { })
  );
in
{
  part1 = length pathPoints;
  part2 = lib.count (
    pt: !(pt.x == startX && pt.y == startY) && !(recurse pt startX startY 0 { })
  ) pathPoints;
}
