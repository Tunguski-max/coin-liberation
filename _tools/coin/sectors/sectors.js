// Sector selection for the thinned-out Lythium map (ticket #4, ADR 0016).
// Pure functions only; file access lives in propose.js.

/**
 * Read all markers from a mission.sqm text.
 * Every "class ItemN { ... }" block is one entity; nested blocks (layers, PositionInfo)
 * keep their own properties, so a marker only gets the keys written directly inside it.
 * Returns [{ name, text, x, y }] with x = east, y = north (sqm order is x, altitude, y).
 */
function parseMarkers(sqmText) {
    const markers = [];
    const stack = [];
    for (const line of sqmText.split(/\r?\n/)) {
        if (/^\s*class\s+\w+/.test(line)) {
            stack.push({});
            continue;
        }
        if (/^\s*};/.test(line)) {
            const block = stack.pop();
            if (block && block.dataType === 'Marker' && block.name) {
                markers.push({ name: block.name, text: block.text || '', x: block.x, y: block.y });
            }
            continue;
        }
        const block = stack[stack.length - 1];
        if (!block) continue;
        const pos = line.match(/^\s*position\[\]=\{([-\d.e]+),([-\d.e]+),([-\d.e]+)\};/);
        if (pos) {
            block.x = Number(pos[1]);
            block.y = Number(pos[3]);
            continue;
        }
        const prop = line.match(/^\s*(\w+)="((?:[^"]|"")*)";/);
        if (prop) block[prop[1]] = prop[2].replace(/""/g, '"');
    }
    return markers;
}

// Liberation sector kind by marker name prefix (docs/kp-liberation-map.md, sector prefixes).
const KINDS = { bigtown: 'capital', capture: 'town', factory: 'supplyPoint', military: 'militaryPost', tower: 'tower' };
const KIND_PATTERN = new RegExp(`^(${Object.keys(KINDS).join('|')})(_\\d+)?$`);

function sectorKind(markerName) {
    const match = markerName.match(KIND_PATTERN);
    return match ? KINDS[match[1]] : undefined;
}

const COUNT_LABELS = { town: 'towns', supplyPoint: 'supply points', militaryPost: 'military posts' };

/**
 * Propose which Liberation sectors stay on the map.
 * Returns { selected: [{ name, text, x, y, role }], candidates, warnings, startBase }.
 * role: capital | downgradedCapital | town | supplyPoint | militaryPost
 */
function selectSectors(markers, rules) {
    const sectors = markers.filter(mk => sectorKind(mk.name));
    const removedByDesign = new Set((rules.removedByDesign || []).map(ref => resolve(sectors, ref)));
    const removed = new Set(rules.raus.map(ref => resolve(sectors, ref)));
    const forced = rules.rein.map(ref => resolve(sectors, ref));
    for (const f of forced) {
        if (sectorKind(f.name) === 'tower') throw new Error(`"${f.text}" (${f.name}) is a radio tower, towers are removed (ADR 0016)`);
        if (removed.has(f)) throw new Error(`"${f.text}" (${f.name}) is in both "raus" and "rein"`);
        if (removedByDesign.has(f)) throw new Error(`"${f.text}" (${f.name}) is removed by design (ADR 0016)`);
    }
    const available = sectors.filter(s => !removed.has(s) && !removedByDesign.has(s));
    const warnings = [];
    const tooClose = s => warnings.push(`"${s.text}" (${s.name}) is selected although it breaks the distance rules`);

    const capital = resolve(sectors, rules.capital);
    const selected = [{ ...capital, role: 'capital' }];
    // All other capitals stay as towns (ADR 0016); they are not spread, only checked.
    for (const s of available) {
        if (sectorKind(s.name) !== 'capital' || s === capital) continue;
        if (minDistance(s, selected) < rules.towns.minDistance) tooClose(s);
        selected.push({ ...s, role: 'downgradedCapital' });
    }

    const startBase = markers.find(mk => mk.name === rules.startBaseMarker);
    const anchors = startBase ? [capital, startBase] : [capital];
    const outsideCapital = s => distance(s, capital) >= rules.capitalClearRadius;

    // Forced sectors of a kind go in first (with a warning if they break a rule),
    // then the farthest-point pick fills up to the count.
    // nearAnchors (supply points, military posts): keep away from every target and the start base,
    // spread out from capital and start base. Otherwise (towns): keep away from and spread out from the towns so far.
    const fill = (kind, settings, { nearAnchors, allowed }) => {
        const keepAway = () => (nearAnchors ? [...selected, ...anchors] : selected);
        const ownPicks = [];
        for (const s of forced.filter(f => sectorKind(f.name) === kind)) {
            if (!allowed(s) || minDistance(s, keepAway()) < settings.minDistance) tooClose(s);
            selected.push({ ...s, role: kind });
            ownPicks.push(s);
        }
        // Towns: the downgraded capitals count towards the town total.
        const counted = () => (kind === 'town' ? selected.length - 1 : ownPicks.length);
        const pool = available.filter(s => sectorKind(s.name) === kind && !forced.includes(s) && allowed(s));
        const spreadFrom = nearAnchors ? [...anchors, ...ownPicks] : selected;
        for (const s of spreadOut(pool, settings.count - counted(), settings.minDistance, keepAway(), spreadFrom)) {
            selected.push({ ...s, role: kind });
            ownPicks.push(s);
        }
        if (counted() < settings.count) {
            warnings.push(`only ${counted()} of ${settings.count} ${COUNT_LABELS[kind]} found that keep the distance rules`);
        }
    };

    fill('town', rules.towns, { allowed: outsideCapital });
    fill('supplyPoint', rules.supplyPoints, { nearAnchors: true, allowed: outsideCapital });
    fill('militaryPost', rules.militaryPosts, {
        nearAnchors: true,
        allowed: s => outsideCapital(s) && distance(s, capital) >= rules.militaryPosts.minDistanceToCapital,
    });

    // Sectors added on top by hand: no distance rules, not counted, placed after the rule-based pick
    // so they never push other sectors out.
    for (const s of (rules.dazu || []).map(ref => resolve(sectors, ref))) {
        const kind = sectorKind(s.name);
        if (kind === 'tower') throw new Error(`"${s.text}" (${s.name}) is a radio tower, towers are removed (ADR 0016)`);
        if (removed.has(s) || removedByDesign.has(s)) throw new Error(`"${s.text}" (${s.name}) is in "dazu" but removed`);
        if (selected.some(sel => sel.name === s.name)) throw new Error(`"${s.text}" (${s.name}) is in "dazu" but already selected`);
        selected.push({ ...s, role: kind, added: true });
    }

    const selectedNames = new Set(selected.map(s => s.name));
    const candidates = sectors
        .filter(s => !selectedNames.has(s.name) && !removedByDesign.has(s) && sectorKind(s.name) !== 'tower')
        .map(s => ({ ...s, kind: sectorKind(s.name), removed: removed.has(s) }));
    return { selected, candidates, warnings, startBase };
}

/** Names that are new or gone compared with the previous selection.json ({ selected: [{ name, text }] }). */
function diffSelections(previous, selected) {
    const before = new Set(previous.selected.map(s => s.name));
    const now = new Set(selected.map(s => s.name));
    return {
        added: selected.filter(s => !before.has(s.name)).map(s => s.text),
        dropped: previous.selected.filter(s => !now.has(s.name)).map(s => s.text),
    };
}

function distance(a, b) {
    return Math.hypot(a.x - b.x, a.y - b.y);
}

function minDistance(point, others) {
    return Math.min(Infinity, ...others.map(o => distance(point, o)));
}

/**
 * Greedy farthest-point pick: repeatedly take the candidate farthest from `spreadFrom` and
 * the picks so far, skipping anything closer than `spacing` to `keepAwayFrom` or a pick.
 * Ties are broken by marker name so the proposal is repeatable.
 */
function spreadOut(candidates, count, spacing, keepAwayFrom, spreadFrom) {
    const picks = [];
    while (picks.length < count) {
        const pool = candidates.filter(c => !picks.includes(c) && minDistance(c, [...keepAwayFrom, ...picks]) >= spacing);
        if (!pool.length) break;
        const ref = [...spreadFrom, ...picks];
        pool.sort((a, b) => minDistance(b, ref) - minDistance(a, ref) || a.name.localeCompare(b.name));
        picks.push(pool[0]);
    }
    return picks;
}

// Find a sector by marker name or by its unique map text.
function resolve(sectors, ref) {
    const byName = sectors.find(s => s.name === ref);
    if (byName) return byName;
    const byText = sectors.filter(s => s.text === ref);
    if (byText.length === 1) return byText[0];
    if (byText.length > 1) {
        throw new Error(`"${ref}" is ambiguous, use the marker name: ${byText.map(s => s.name).join(', ')}`);
    }
    throw new Error(`no sector named "${ref}"`);
}

const ROLE_LABELS = {
    capital: 'Hauptstadt',
    downgradedCapital: 'Ortschaft (herabgestufte Hauptstadt)',
    town: 'Ortschaft',
    supplyPoint: 'Supply Point',
    militaryPost: 'Militärposten',
};

// Six-digit Arma map grid (100 m squares), as read on the in-game map.
function grid(s) {
    const pad = v => String(Math.floor(v / 100)).padStart(3, '0');
    return `${pad(s.x)} ${pad(s.y)}`;
}

/**
 * Markdown list of the proposal for Niklas (German, like all docs).
 * `previous` is the last selection.json ({ selected: [{ name, text }] }) or null.
 */
function renderList(result, previous) {
    const lines = ['# Sektorauswahl – Vorschlag', ''];
    lines.push('Erzeugt von `_tools/coin/sectors/propose.js` (Ticket #4, ADR 0016). Nicht von Hand ändern;');
    lines.push('tauschen über `raus`/`rein`, ohne Abstandsregeln ergänzen über `dazu` in `_tools/coin/sectors/rules.json`.', '');

    if (previous) {
        const { added, dropped } = diffSelections(previous, result.selected);
        lines.push('## Änderungen zum letzten Vorschlag', '');
        lines.push(`- Neu: ${added.join(', ') || '(keine)'}`);
        lines.push(`- Entfallen: ${dropped.join(', ') || '(keine)'}`, '');
    }

    if (result.warnings.length) {
        lines.push('## Warnungen', '', ...result.warnings.map(w => `- ${w}`), '');
    }

    lines.push('## Gewählte Ziele', '');
    for (const [role, label] of Object.entries(ROLE_LABELS)) {
        const items = result.selected.filter(s => s.role === role);
        if (!items.length) continue;
        lines.push(`### ${label} (${items.length})`, '', '| Name | Marker | Raster | Position (km) | von Hand |', '|---|---|---|---|---|');
        for (const s of items) lines.push(`| ${s.text} | \`${s.name}\` | ${grid(s)} | ${(s.x / 1000).toFixed(1)} / ${(s.y / 1000).toFixed(1)} | ${s.added ? "ergänzt" : ""} |`);
        lines.push('');
    }

    lines.push('## Nicht gewählt (zum Einwechseln)', '');
    // Sector kinds share their keys and labels with the roles.
    for (const kind of ['capital', 'town', 'supplyPoint', 'militaryPost']) {
        const label = ROLE_LABELS[kind];
        const items = result.candidates.filter(c => c.kind === kind);
        if (!items.length) continue;
        const names = items.map(c => `${c.text} (\`${c.name}\`, ${grid(c)}${c.removed ? ', raus' : ''})`);
        lines.push(`- **${label}:** ${names.join(', ')}`);
    }
    lines.push('');
    return lines.join('\n');
}

const ROLE_COLORS = {
    capital: '#c0392b',
    downgradedCapital: '#e67e22',
    town: '#2c7fb8',
    supplyPoint: '#27ae60',
    militaryPost: '#7f3fbf',
    startBase: '#111111',
};

const escapeXml = text => text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

/**
 * SVG map of the proposal: selected targets in colour, unselected candidates in grey,
 * dashed capital radius, 1 km grid with labels every 2 km. North is up.
 */
function renderSvg(result, rules) {
    const { startBase } = result;
    const scale = 0.045;
    const margin = 30;
    const rightMargin = 110; // room for labels of targets at the east edge
    const legendHeight = 40;
    const size = rules.mapSize * scale;
    const px = s => margin + s.x * scale;
    const py = s => margin + size - s.y * scale;
    const out = [];
    out.push(`<svg xmlns="http://www.w3.org/2000/svg" width="${size + margin + rightMargin}" height="${size + 2 * margin + legendHeight}" font-family="sans-serif" font-size="9">`);
    out.push('<rect width="100%" height="100%" fill="#f4efe4"/>');
    for (let km = 0; km * 1000 <= rules.mapSize; km++) {
        const v = margin + km * 1000 * scale;
        out.push(`<line x1="${v}" y1="${margin}" x2="${v}" y2="${margin + size}" stroke="#e2dccd"/>`);
        out.push(`<line x1="${margin}" y1="${v}" x2="${margin + size}" y2="${v}" stroke="#e2dccd"/>`);
        if (km % 2 === 0) {
            out.push(`<text x="${v}" y="${margin - 8}" text-anchor="middle" fill="#888">${km}</text>`);
            out.push(`<text x="${margin - 6}" y="${margin + size - km * 1000 * scale + 3}" text-anchor="end" fill="#888">${km}</text>`);
        }
    }
    for (const c of result.candidates) {
        out.push(`<circle cx="${px(c)}" cy="${py(c)}" r="2.5" fill="#b5ae9f"/>`);
        out.push(`<text x="${px(c) + 4}" y="${py(c) + 3}" font-size="7" fill="#a39c8c">${escapeXml(c.text)}</text>`);
    }
    const capital = result.selected.find(s => s.role === 'capital');
    out.push(`<circle cx="${px(capital)}" cy="${py(capital)}" r="${rules.capitalClearRadius * scale}" fill="none" stroke="${ROLE_COLORS.capital}" stroke-dasharray="3 2"/>`);
    const points = [...result.selected];
    if (startBase) points.push({ ...startBase, text: 'Startbasis', role: 'startBase' });
    for (const s of points) {
        const r = s.role === 'capital' ? 6 : 4.5;
        out.push(`<circle cx="${px(s)}" cy="${py(s)}" r="${r}" fill="${ROLE_COLORS[s.role]}" stroke="${s.added ? "#111" : "#fff"}" stroke-width="${s.added ? 2 : 1}"/>`);
        out.push(`<text x="${px(s) + 7}" y="${py(s) + 3}" font-weight="bold" fill="#222">${escapeXml(s.text)}</text>`);
    }
    // Legend below the map, so it never hides a target (the start base sits in the south-west corner).
    const legend = [...Object.entries(ROLE_LABELS), ['startBase', 'Startbasis'], ['added', 'von Hand ergänzt (Ring)'], ['candidate', 'nicht gewählt (Kandidat)']];
    out.push(`<g transform="translate(${margin},${margin + size + 28})">`);
    let offset = 0;
    for (const [role, label] of legend) {
        const fill = { candidate: '#b5ae9f', added: '#ffffff' }[role] || ROLE_COLORS[role];
        const ring = role === 'added' ? ' stroke="#111" stroke-width="2"' : '';
        out.push(`<circle cx="${offset + 5}" cy="0" r="${role === 'candidate' ? 2.5 : 4.5}" fill="${fill}"${ring}/><text x="${offset + 13}" y="3">${label}</text>`);
        offset += 13 + label.length * 5 + 18;
    }
    out.push('</g></svg>');
    return out.join('\n');
}

module.exports = { parseMarkers, selectSectors, diffSelections, renderList, renderSvg };
