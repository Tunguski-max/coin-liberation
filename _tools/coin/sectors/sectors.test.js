// Tests for the sector selection (ticket #4, ADR 0016). Run: node --test "_tools/coin/**/*.test.js"
const test = require('node:test');
const assert = require('node:assert/strict');
const { parseMarkers, selectSectors, renderList } = require('./sectors');

// Minimal mission.sqm excerpt in Eden format: dataType comes before position,
// sector markers can sit inside layers, objects also carry a name.
const SQM = `
class Mission
{
	class Entities
	{
		class Item0
		{
			dataType="Marker";
			position[]={4157.9302,0,842.84497};
			name="startbase_marker";
			text="Operation Base";
			type="mil_start";
		};
		class Item1
		{
			dataType="Layer";
			name="Sectors";
			class Entities
			{
				class Item0
				{
					dataType="Marker";
					position[]={1000.5,12,2000.25};
					name="capture_3";
					text="Sar Kandah";
					type="Empty";
				};
				class Item1
				{
					dataType="Object";
					class PositionInfo
					{
						position[]={5,0,5};
					};
					name="littlebird_0";
					type="Land_HelipadCircle_F";
				};
			};
		};
		class Item2
		{
			dataType="Marker";
			position[]={3000,0,4000};
			name="bigtown";
			text="Kalae Noowi";
			type="Empty";
		};
	};
};
`;

test('parseMarkers reads every marker with name, text and 2D map position', () => {
    assert.deepEqual(parseMarkers(SQM), [
        { name: 'startbase_marker', text: 'Operation Base', x: 4157.9302, y: 842.84497 },
        { name: 'capture_3', text: 'Sar Kandah', x: 1000.5, y: 2000.25 },
        { name: 'bigtown', text: 'Kalae Noowi', x: 3000, y: 4000 },
    ]);
});

// --- selectSectors -----------------------------------------------------------

const m = (name, text, xKm, yKm) => ({ name, text, x: xKm * 1000, y: yKm * 1000 });
const START = m('startbase_marker', 'Operation Base', 0, 0);

const RULES = {
    capital: 'Capital',
    startBaseMarker: 'startbase_marker',
    capitalClearRadius: 1000,
    towns: { count: 3, minDistance: 2500 },
    supplyPoints: { count: 0, minDistance: 1500 },
    militaryPosts: { count: 0, minDistance: 1500, minDistanceToCapital: 2000 },
    raus: [],
    rein: [],
};

const roles = (result, role) => result.selected.filter(s => s.role === role).map(s => s.text).sort();

test('the capital stays a capital, the other capitals become towns unless removed', () => {
    const markers = [
        START,
        m('bigtown', 'Capital', 10, 10),
        m('bigtown_1', 'North', 10, 18),
        m('bigtown_2', 'Arobster', 18, 10),
    ];
    const result = selectSectors(markers, { ...RULES, raus: ['Arobster'] });
    assert.deepEqual(roles(result, 'capital'), ['Capital']);
    assert.deepEqual(roles(result, 'downgradedCapital'), ['North']);
    assert.equal(result.selected.some(s => s.text === 'Arobster'), false);
});

test('towns fill up to the count, keep their minimum distance and leave the capital radius free', () => {
    const markers = [
        START,
        m('bigtown', 'Capital', 10, 10),
        m('capture_1', 'InsideCapitalRadius', 10.5, 10), // 0.5 km to the capital
        m('capture_2', 'TooCloseToCapital', 12, 10),     // 2 km < 2.5 km town distance
        m('capture_3', 'C', 16.5, 10),                   // farthest from the capital, picked first
        m('capture_4', 'D', 14.5, 10),                   // 2 km to C, so it drops out
        m('capture_5', 'E', 4, 10),
        m('capture_6', 'F', 10, 4.5),
    ];
    const result = selectSectors(markers, RULES);
    assert.deepEqual(roles(result, 'town'), ['C', 'E', 'F']);
});

test('supply points and military posts spread out, military posts avoid the capital, towers drop', () => {
    const markers = [
        START,
        m('bigtown', 'Capital', 10, 10),
        m('factory_1', 'SP-A', 10.5, 10.5),  // inside the capital radius
        m('factory_2', 'SP-B', 1, 0),        // 1 km to the start base
        m('factory_3', 'SP-C', 18, 18),      // farthest from capital and start base
        m('factory_4', 'SP-D', 18, 17),      // 1 km to SP-C
        m('factory_5', 'SP-E', 0, 10),
        m('military_1', 'MP-A', 11.5, 10),   // 1.5 km < 2 km to the capital
        m('military_2', 'MP-B', 10, 14),
        m('military_3', 'MP-C', 5, 5),       // farthest from capital and start base
        m('tower_1', 'Tower', 15, 2),
    ];
    const result = selectSectors(markers, {
        ...RULES,
        supplyPoints: { count: 2, minDistance: 1500 },
        militaryPosts: { count: 1, minDistance: 1500, minDistanceToCapital: 2000 },
    });
    assert.deepEqual(roles(result, 'supplyPoint'), ['SP-C', 'SP-E']);
    assert.deepEqual(roles(result, 'militaryPost'), ['MP-C']);
    assert.equal(result.selected.some(s => s.text === 'Tower'), false);
});

test('a forced sector ("rein") is always selected, counts towards the total and warns when too close', () => {
    const markers = [
        START,
        m('bigtown', 'Capital', 10, 10),
        m('capture_1', 'Far', 18, 10),     // 8 km to the capital
        m('capture_2', 'Other', 3, 10),    // 7 km to the capital, 9 km to Forced
        m('capture_3', 'Forced', 12, 10),  // 2 km to the capital, below the town distance
    ];
    const rules = { ...RULES, towns: { count: 2, minDistance: 2500 } };
    assert.deepEqual(roles(selectSectors(markers, rules), 'town'), ['Far', 'Other']);

    const result = selectSectors(markers, { ...rules, rein: ['Forced'] });
    assert.deepEqual(roles(result, 'town'), ['Forced', 'Other']);
    assert.equal(result.warnings.length, 1);
    assert.match(result.warnings[0], /Forced/);
});

test('a swap by an ambiguous name fails with the marker names to use instead', () => {
    const markers = [
        START,
        m('bigtown', 'Capital', 10, 10),
        m('capture_1', 'Twin', 2, 2),
        m('factory_7', 'Twin', 18, 18),
    ];
    assert.throws(() => selectSectors(markers, { ...RULES, raus: ['Twin'] }), /capture_1, factory_7/);
    const result = selectSectors(markers, { ...RULES, raus: ['capture_1'] });
    assert.deepEqual(roles(result, 'town'), []);
});

test('towers cannot be forced in, they are removed by ADR 0016', () => {
    const markers = [START, m('bigtown', 'Capital', 10, 10), m('tower_1', 'Tower', 2, 2)];
    assert.throws(() => selectSectors(markers, { ...RULES, rein: ['Tower'] }), /tower/i);
});

test('candidates list every sector that was not selected, except towers', () => {
    const markers = [
        START,
        m('bigtown', 'Capital', 10, 10),
        m('bigtown_1', 'Arobster', 18, 10),
        m('capture_1', 'InsideCapitalRadius', 10.5, 10),
        m('tower_1', 'Tower', 2, 2),
    ];
    const result = selectSectors(markers, { ...RULES, raus: ['Arobster'] });
    assert.deepEqual(result.candidates.map(c => [c.text, c.kind, c.removed]), [
        ['Arobster', 'capital', true],
        ['InsideCapitalRadius', 'town', false],
    ]);
});

// --- renderList --------------------------------------------------------------

test('the list names every selected sector and shows what changed since the last proposal', () => {
    const markers = [
        START,
        m('bigtown', 'Capital', 10, 10),
        m('capture_3', 'C', 16.5, 10),
        m('capture_5', 'E', 4, 10),
        m('factory_1', 'Depot', 18, 18),
    ];
    const result = selectSectors(markers, { ...RULES, supplyPoints: { count: 1, minDistance: 1500 } });
    const previous = { selected: [{ name: 'capture_3', text: 'C' }, { name: 'capture_9', text: 'Old' }] };
    const list = renderList(result, previous);
    for (const name of ['Capital', 'C', 'E', 'Depot']) assert.match(list, new RegExp(`\| ${name} \|`));
    assert.match(list, /Neu:.*E.*Depot|Neu:.*Depot.*E/);
    assert.match(list, /Entfallen:.*Old/);
});

// --- rule breaks surface as warnings or errors ---------------------------------

test('downgraded capitals closer than the town distance are kept but warned about', () => {
    const markers = [
        START,
        m('bigtown', 'Capital', 10, 10),
        m('bigtown_1', 'West', 3, 10),
        m('bigtown_2', 'WestNeighbour', 4, 10), // 1 km to West
    ];
    const result = selectSectors(markers, RULES);
    assert.deepEqual(roles(result, 'downgradedCapital'), ['West', 'WestNeighbour']);
    assert.equal(result.warnings.length, 2); // the pair, plus too few towns (2 of 3)
    assert.match(result.warnings.join('\n'), /WestNeighbour/);
});

test('a count that cannot be reached is reported', () => {
    const markers = [START, m('bigtown', 'Capital', 10, 10), m('capture_1', 'Only', 2, 2)];
    const result = selectSectors(markers, RULES);
    assert.deepEqual(result.warnings, ['only 1 of 3 towns found that keep the distance rules']);
});

test('a sector in both "raus" and "rein" is an error', () => {
    const markers = [START, m('bigtown', 'Capital', 10, 10), m('capture_1', 'Both', 2, 2)];
    assert.throws(() => selectSectors(markers, { ...RULES, raus: ['Both'], rein: ['Both'] }), /both "raus" and "rein"/);
});

test('sectors removed by design never appear, not even as candidates', () => {
    const markers = [START, m('bigtown', 'Capital', 10, 10), m('bigtown_1', 'Arobster', 18, 10)];
    const result = selectSectors(markers, { ...RULES, removedByDesign: ['Arobster'] });
    assert.equal(result.selected.some(s => s.text === 'Arobster'), false);
    assert.equal(result.candidates.some(s => s.text === 'Arobster'), false);
});

test('sectors added on top ("dazu") ignore all distance rules and leave the rule-based pick unchanged', () => {
    const markers = [
        START,
        m('bigtown', 'Capital', 10, 10),
        m('capture_1', 'Far', 18, 10),
        m('capture_2', 'Other', 3, 10),
        m('capture_3', 'NextToFar', 17, 10),    // 1 km to Far
        m('military_1', 'Barracks', 10.5, 10),  // inside the capital radius
    ];
    const rules = { ...RULES, towns: { count: 2, minDistance: 2500 } };
    const result = selectSectors(markers, { ...rules, dazu: ['NextToFar', 'Barracks'] });
    assert.deepEqual(roles(result, 'town'), ['Far', 'NextToFar', 'Other']);
    assert.deepEqual(roles(result, 'militaryPost'), ['Barracks']);
    assert.deepEqual(result.selected.filter(s => s.added).map(s => s.text), ['NextToFar', 'Barracks']);
    assert.deepEqual(result.warnings, []);
});
