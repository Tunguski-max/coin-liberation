// Write the approved sector selection into the COIN mission base (ticket #5, ADR 0016).
// Usage from the repo root: node _tools/coin/sectors/write.js
// Reads selection.json (from propose.js) and edits rules.targetSqm in place. Safe to re-run.
const fs = require('fs');
const path = require('path');
const { applySelection } = require('./apply');

const repoRoot = path.resolve(__dirname, '..', '..', '..');
const rules = JSON.parse(fs.readFileSync(path.join(__dirname, 'rules.json'), 'utf8'));
const selection = JSON.parse(fs.readFileSync(path.join(__dirname, 'selection.json'), 'utf8'));
const target = path.join(repoRoot, rules.targetSqm);

let result;
try {
    result = applySelection(fs.readFileSync(target, 'utf8'), selection);
} catch (error) {
    console.error(`[COIN] sectors: ERROR - ${error.message}`);
    process.exit(1);
}

fs.writeFileSync(target, result.text);
console.log(`[COIN] sectors: removed ${result.removed.length} sector markers, renamed ${result.renamed.length} capitals to towns`);
for (const [from, to] of result.renamed) console.log(`[COIN] sectors: ${from} -> ${to}`);
console.log(`[COIN] sectors: wrote ${rules.targetSqm}`);
