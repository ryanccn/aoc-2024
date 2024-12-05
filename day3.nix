{ input, lib }:
let
  inherit (builtins)
    substring
    stringLength
    foldl'
    isInt
    ;

  initialState = {
    idx = 0;
    type = "idle";
    result = 0;
  };

  processChar =
    readToggles:
    foldl' (
      state: _:
      let
        char = substring state.idx 1 input;
      in
      if isInt state then
        state
      else if state.idx >= stringLength input then
        state.result
      else if state.type == "idle" then
        if substring state.idx 4 input == "mul(" then
          {
            inherit (state) result;
            type = "fst";
            fst = 0;
            idx = state.idx + 4;
          }
        else if readToggles && substring state.idx 7 input == "don't()" then
          {
            inherit (state) result;
            type = "off";
            idx = state.idx + 7;
          }
        else
          {
            inherit (state) type result;
            idx = state.idx + 1;
          }
      else if readToggles && state.type == "off" then
        if substring state.idx 4 input == "do()" then
          {
            inherit (state) result;
            type = "idle";
            idx = state.idx + 4;
          }
        else
          {
            inherit (state) type result;
            idx = state.idx + 1;
          }
      else if state.type == "fst" then
        let
          digit = lib.aoc.safeDigitToInt char;
        in
        if digit != null then
          {
            inherit (state) type result;
            fst = state.fst * 10 + digit;
            idx = state.idx + 1;
          }
        else if char == "," then
          {
            inherit (state) result fst;
            type = "snd";
            snd = 0;
            idx = state.idx + 1;
          }
        else
          {
            inherit (state) result;
            type = "idle";
            idx = state.idx + 1;
          }
      else if state.type == "snd" then
        let
          digit = lib.aoc.safeDigitToInt char;
        in
        if digit != null then
          {
            inherit (state) type fst result;
            snd = state.snd * 10 + digit;
            idx = state.idx + 1;
          }
        else if char == ")" then
          {
            type = "idle";
            result = state.result + state.fst * state.snd;
            idx = state.idx + 1;
          }
        else
          {
            inherit (state) result;
            type = "idle";
            idx = state.idx + 1;
          }
      else
        throw "unknown state: ${state.type}"
    ) initialState (lib.replicate (stringLength input) null);
in
{
  part1 = processChar false;
  part2 = processChar true;
}
