// Write a sector selection into mission.sqm (ticket #5, ADR 0016).
// Pure text transformation; file access lives in write.js. Everything that is not an
// unselected sector marker stays byte for byte, so Eden edits (slots) survive a re-run.

const { parseBlocks, walk } = require('./sqm');
const { SECTOR_PREFIXES } = require('./sectors');

// Liberation treats every marker whose name starts with one of these as a sector (fn_initSectors.sqf).
const SECTOR_PREFIX = new RegExp(`^(${SECTOR_PREFIXES.join('|')})`);
// Marker icon of Liberation's towns in the Lythium mission.sqm (all capture_* markers use it).
const TOWN_ICON = 'n_art';

// A downgraded capital keeps its origin in the name but is a town for Liberation.
const townName = capitalName => `capture_${capitalName}`;

/**
 * Apply a selection ({ selected: [{ name, role }] }) to the mission.sqm text.
 * Removes unselected sector markers (towers included), renames downgraded capitals to
 * capture_<name> with the town icon, renumbers Entities. Running it twice changes nothing.
 * Returns { text, removed: [names], renamed: [[from, to]] }.
 */
function applySelection(sqmText, selection) {
    const eol = sqmText.includes('\r\n') ? '\r\n' : '\n';
    const lines = sqmText.split(/\r?\n/);
    const root = parseBlocks(lines);

    const downgraded = new Set(selection.selected.filter(s => s.role === 'downgradedCapital').map(s => s.name));
    const keep = new Set(selection.selected.map(s => (downgraded.has(s.name) ? townName(s.name) : s.name)));
    const deletedBlocks = new Set();
    const removedNames = [];
    const renamed = [];
    const seen = new Set();

    walk(root, block => {
        const name = block.props.name;
        if (block.props.dataType !== 'Marker' || !name || !SECTOR_PREFIX.test(name)) return;
        if (downgraded.has(name)) {
            lines[block.propLines.name] = lines[block.propLines.name].replace(`"${name}"`, `"${townName(name)}"`);
            lines[block.propLines.type] = lines[block.propLines.type].replace(/"[^"]*"/, `"${TOWN_ICON}"`);
            renamed.push([name, townName(name)]);
            return;
        }
        if (keep.has(name)) {
            seen.add(name);
            return;
        }
        deletedBlocks.add(block);
        removedNames.push(name);
    });
    for (const [, to] of renamed) seen.add(to);
    const missing = [...keep].filter(name => !seen.has(name));
    if (missing.length) throw new Error(`selected sectors not found in mission.sqm: ${missing.join(', ')}`);

    // Eden links (sync lines) point at entity ids; never cut one by removing its marker.
    const deletedById = new Map([...deletedBlocks].map(block => [block.props.id, block.props.name]));
    walk(root, block => {
        if (block.parent && block.parent.cls === 'Links') {
            for (const end of [block.props.item0, block.props.item1]) {
                if (deletedById.has(end)) throw new Error(`marker ${deletedById.get(end)} (id ${end}) is linked in Connections, not removing it`);
            }
        }
    });

    // Renumber the direct children of every Entities block and fix its item count.
    walk(root, block => {
        if (block.cls !== 'Entities') return;
        const items = block.children.filter(child => /^Item\d+$/.test(child.cls) && !deletedBlocks.has(child));
        items.forEach((child, index) => {
            lines[child.start] = lines[child.start].replace(/class\s+Item\d+/, `class Item${index}`);
        });
        if (block.propLines.items !== undefined) {
            lines[block.propLines.items] = lines[block.propLines.items].replace(/items=\d+/, `items=${items.length}`);
        }
    });

    const dropLines = new Set();
    for (const block of deletedBlocks) {
        for (let i = block.start; i <= block.end; i++) dropLines.add(i);
    }
    const text = lines.filter((_, i) => !dropLines.has(i)).join(eol);
    return { text, removed: removedNames, renamed };
}

module.exports = { applySelection };
