{ input, lib }:
let
  inherit (builtins) fromJSON substring stringLength;

  processChar =
    readToggles:
    lib.fix (
      self:
      (
        state:
        let
          char = substring state.idx 1 input;
        in
        if state.idx >= (stringLength input) then
          state.result # we're done here
        else if state.type == "idle" then
          if substring state.idx 4 input == "mul(" then
            (self {
              inherit (state) result;
              type = "fst";
              collected = "";
              idx = state.idx + 4;
            })
          else if readToggles && substring state.idx 7 input == "don't()" then
            (self {
              inherit (state) result;
              type = "off";
              idx = state.idx + 7;
            })
          else
            (self {
              inherit (state) type result;
              idx = state.idx + 1;
            })
        else if readToggles && state.type == "off" then
          if substring state.idx 4 input == "do()" then
            (self {
              inherit (state) result;
              type = "idle";
              idx = state.idx + 4;
            })
          else
            (self {
              inherit (state) type result;
              idx = state.idx + 1;
            })
        else if state.type == "fst" then
          if lib.aoc.isDigit char then
            (self {
              inherit (state) type result;
              collected = state.collected + char;
              idx = state.idx + 1;
            })
          else if char == "," then
            (self {
              inherit (state) result;
              type = "snd";
              fst = fromJSON state.collected;
              collected = "";
              idx = state.idx + 1;
            })
          else
            (self {
              inherit (state) result;
              type = "idle";
              idx = state.idx + 1;
            })
        else if state.type == "snd" then
          if lib.aoc.isDigit char then
            (self {
              inherit (state) type fst result;
              collected = state.collected + char;
              idx = state.idx + 1;
            })
          else if char == ")" then
            (self {
              type = "idle";
              result = state.result + (state.fst * (fromJSON state.collected));
              idx = state.idx + 1;
            })
          else
            (self {
              inherit (state) result;
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
    result = 0;
  };
in
{
  part1 = processChar false initialState;
  part2 = processChar true initialState;
}
