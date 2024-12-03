{ input, lib }:
let
  processChar =
    readToggles:
    lib.fix (
      self:
      (
        state:
        let
          char = builtins.substring state.idx 1 input;
        in
        if state.idx >= (builtins.stringLength input) then
          state.history # we're done here
        else if state.type == "idle" then
          if builtins.substring state.idx 4 input == "mul(" then
            (self {
              inherit (state) history;
              type = "fst";
              collected = "";
              idx = state.idx + 4;
            })
          else if readToggles && builtins.substring state.idx 7 input == "don't()" then
            (self {
              inherit (state) history;
              type = "off";
              idx = state.idx + 7;
            })
          else
            (self {
              inherit (state) type history;
              idx = state.idx + 1;
            })
        else if readToggles && state.type == "off" then
          if builtins.substring state.idx 4 input == "do()" then
            (self {
              inherit (state) history;
              type = "idle";
              idx = state.idx + 4;
            })
          else
            (self {
              inherit (state) type history;
              idx = state.idx + 1;
            })
        else if state.type == "fst" then
          if lib.aoc.isDigit char then
            (self {
              inherit (state) type history;
              collected = state.collected + char;
              idx = state.idx + 1;
            })
          else if char == "," then
            (self {
              inherit (state) history;
              type = "snd";
              fst = lib.toInt state.collected;
              collected = "";
              idx = state.idx + 1;
            })
          else
            (self {
              inherit (state) history;
              type = "idle";
              idx = state.idx + 1;
            })
        else if state.type == "snd" then
          if lib.aoc.isDigit char then
            (self {
              inherit (state) type fst history;
              collected = state.collected + char;
              idx = state.idx + 1;
            })
          else if char == ")" then
            (self {
              type = "idle";
              history = state.history ++ [
                {
                  inherit (state) fst;
                  snd = lib.toInt state.collected;
                }
              ];
              idx = state.idx + 1;
            })
          else
            (self {
              inherit (state) history;
              type = "idle";
              idx = state.idx + 1;
            })
        else
          throw "unknown state: ${toString state}"
      )
    );

  initialState = {
    idx = 0;
    type = "idle";
    history = [ ];
  };
in
{
  part1 = lib.aoc.sum (map ({ fst, snd }: fst * snd) (processChar false initialState));
  part2 = lib.aoc.sum (map ({ fst, snd }: fst * snd) (processChar true initialState));
}
