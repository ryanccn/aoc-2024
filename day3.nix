{ input, lib }:
let
  inherit (builtins) substring stringLength;

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
              fst = 0;
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
          let
            digit = lib.aoc.safeDigitToInt char;
          in
          if digit != null then
            (self {
              inherit (state) type result;
              fst = state.fst * 10 + digit;
              idx = state.idx + 1;
            })
          else if char == "," then
            (self {
              inherit (state) result fst;
              type = "snd";
              snd = 0;
              idx = state.idx + 1;
            })
          else
            (self {
              inherit (state) result;
              type = "idle";
              idx = state.idx + 1;
            })
        else if state.type == "snd" then
          let
            digit = lib.aoc.safeDigitToInt char;
          in
          if digit != null then
            (self {
              inherit (state) type fst result;
              snd = state.snd * 10 + digit;
              idx = state.idx + 1;
            })
          else if char == ")" then
            (self {
              type = "idle";
              result = state.result + state.fst * state.snd;
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
