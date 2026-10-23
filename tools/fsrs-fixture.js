#!/usr/bin/env node
// Regenerates tests/fixtures/fsrs6_ts_fsrs.lua from ts-fsrs, an independent FSRS-6 implementation.
// Run in a scratch directory: nix shell nixpkgs#nodejs -c bash -c "npm install ts-fsrs@5.4.2 && node tools/fsrs-fixture.js"
// Output is the fixture body (wrap it in the header and return { ... } as in the committed file).
const { FSRSAlgorithm, generatorParameters } = require("ts-fsrs");
const a = new FSRSAlgorithm(generatorParameters({ enable_short_term: true }));
let s = 20261023;
const rand = (n) => { s = (s * 48271) % 2147483647; return s % n; };
const out = [];
for (let seq = 0; seq < 40; seq++) {
  let st = null; const steps = [];
  for (let i = 0; i < 12; i++) {
    const days = i === 0 ? 0 : [0, 1, 2, 3, 5, 8, 13, 21, 40][rand(9)];
    const correct = rand(10) < 7;
    st = a.next_state(st, days, correct ? 3 : 1);
    steps.push(`{ ${days}, ${correct}, ${st.stability.toPrecision(17)}, ${st.difficulty.toPrecision(17)} }`);
  }
  out.push("\t{ " + steps.join(", ") + " },");
}
console.log(out.join("\n"));
