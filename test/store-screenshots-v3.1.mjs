// Provisional 3.1 capture pipeline. Run only from a clean committed candidate.
// It runs the deterministic browser suite, then stages four host fixtures outside
// release assets. The release packet records SHA and timestamps before anyone
// can copy reviewed files into store-assets/v3.0/real/.
import { spawnSync } from "node:child_process";
import { copyFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = join(HERE, "..");
const OUT = join(HERE, "out", "store-v3.1-provisional");
const status = spawnSync(process.execPath, [join(HERE, "phase2-e2e.mjs")], { cwd: ROOT, encoding: "utf8" });
if (status.status !== 0) {
  process.stderr.write(status.stdout || "");
  process.stderr.write(status.stderr || "");
  throw new Error("phase2 must pass before provisional screenshot capture");
}
const report = readFileSync(join(HERE, "out", "phase2-report.md"), "utf8");
if (/ConnectScore/i.test(report)) throw new Error("rendered browser report still contains ConnectScore");
rmSync(OUT, { recursive: true, force: true });
mkdirSync(OUT, { recursive: true });
const shots = {
  "store-1-united-1280x800.png": "SFO-DEN-positive.png",
  "store-2-googleflights-1280x800.png": "figure-disclosure-google-alaska-source.png",
  "store-3-alaska-1280x800.png": "alaska-no-united-action.png",
  "store-4-navan-1280x800.png": "navan-prioritize-explicit-action.png",
};
for (const [target, source] of Object.entries(shots)) {
  const input = join(HERE, "out", "shots", source);
  if (!existsSync(input)) throw new Error("missing required browser shot: " + source);
  copyFileSync(input, join(OUT, target));
}
writeFileSync(join(OUT, "PROVENANCE.md"),
  "# Provisional v3.1 Store screenshots\n\n" +
  "Generated from a clean committed candidate by `node test/store-screenshots-v3.1.mjs`.\n" +
  "These files are not final Store assets. Record the source SHA, exact model pin, capture time, and Claude receipt before promotion.\n");
process.stderr.write("wrote provisional 3.1 screenshots to test/out/store-v3.1-provisional/\n");
