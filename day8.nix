{ input, lib }:
let
  inherit (builtins)
    foldl'
    elemAt
    filter
    concatLists
    length
    ;

  mapp = map lib.stringToCharacters (lib.aoc.lines input);
  lx = length mapp;
  ly = length (elemAt mapp 0);

  calculate =
    updatedModel:
    foldl'
      (
        acc: loc:
        let
          ch = elemAt (elemAt mapp loc.x) loc.y;
        in
        if ch == "." then
          acc
        else
          {
            antennae = acc.antennae // {
              ${ch} = (acc.antennae.${ch} or [ ]) ++ [ loc ];
            };

            antinodes =
              acc.antinodes
              ++ filter ({ x, y }: x >= 0 && x < lx && y >= 0 && y < ly) (
                concatLists (
                  map (
                    loc':
                    let
                      dx = loc'.x - loc.x;
                      dy = loc'.y - loc.y;

                      muls =
                        if updatedModel then
                          let
                            bound1 = -(lib.max (loc.x / dx) (loc.y / dy));
                            bound2 = lib.max ((lx - loc.x - 1) / dx) (ly - loc.y - 1) / dy;
                          in
                          lib.range (lib.min bound1 bound2) (lib.max bound1 bound2)
                        else
                          [
                            (-1)
                            2
                          ];
                    in
                    map (mul: {
                      x = loc.x + dx * mul;
                      y = loc.y + dy * mul;
                    }) muls
                  ) (acc.antennae.${ch} or [ ])
                )
              );
          }
      )
      {
        antennae = { };
        antinodes = [ ];
      }
      (
        lib.cartesianProduct {
          x = lib.range 0 (lx - 1);
          y = lib.range 0 (ly - 1);
        }
      );
in
{
  part1 = length (lib.unique (calculate false).antinodes);
  part2 = length (lib.unique (calculate true).antinodes);
}
