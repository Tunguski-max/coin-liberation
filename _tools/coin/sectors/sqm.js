// Minimal mission.sqm (Eden class format) parser shared by the sector tools (tickets #4, #5).

/**
 * Parse the class tree of a mission.sqm. Each block knows its line range and the line
 * numbers of its direct properties, so edits can be made line by line.
 */
function parseBlocks(lines) {
    const root = { cls: '', children: [], props: {}, propLines: {} };
    // Frames are class blocks or multi-line arrays (addons[]= { ... };); both close with "};".
    const stack = [root];
    const currentBlock = () => stack.filter(frame => !frame.isArray).pop();
    let pendingClass = null;
    lines.forEach((line, i) => {
        const open = line.match(/^\s*class\s+(\w+)/);
        if (open) {
            const parent = currentBlock();
            const block = { cls: open[1], start: i, children: [], props: {}, propLines: {}, parent };
            parent.children.push(block);
            if (/};\s*$/.test(line)) block.end = i;
            else if (/\{\s*$/.test(line)) stack.push(block);
            else pendingClass = block;
            return;
        }
        if (/^\s*\{\s*$/.test(line)) {
            stack.push(pendingClass || { isArray: true });
            pendingClass = null;
            return;
        }
        if (/^\s*\w+\[\]=\s*\{\s*$/.test(line)) {
            stack.push({ isArray: true });
            return;
        }
        if (/^\s*};/.test(line)) {
            if (stack.length === 1) throw new Error(`unbalanced "};" in mission.sqm line ${i + 1}`);
            stack.pop().end = i;
            return;
        }
        if (stack[stack.length - 1].isArray) return;
        const inlineArray = line.match(/^\s*(\w+)\[\]=\{(.*)\};/);
        if (inlineArray) {
            const block = currentBlock();
            block.props[inlineArray[1] + '[]'] = inlineArray[2];
            block.propLines[inlineArray[1] + '[]'] = i;
            return;
        }
        const prop = line.match(/^\s*(\w+)=(?:"((?:[^"]|"")*)"|([^;]*));/);
        if (prop) {
            const block = currentBlock();
            block.props[prop[1]] = prop[2] !== undefined ? prop[2] : prop[3];
            block.propLines[prop[1]] = i;
        }
    });
    if (stack.length !== 1) throw new Error('mission.sqm ends inside an open block');
    return root;
}

function walk(block, visit) {
    visit(block);
    block.children.forEach(child => walk(child, visit));
}

module.exports = { parseBlocks, walk };
