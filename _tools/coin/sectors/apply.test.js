// Tests for writing the sector selection into mission.sqm (ticket #5, ADR 0016).
// Run: node --test "_tools/coin/**/*.test.js"
const test = require('node:test');
const assert = require('node:assert/strict');
const { applySelection } = require('./apply');

// Eden-style excerpt: sector markers sit directly in Mission > Entities next to groups
// (with their own nested Entities) and enemy spawn points.
const SQM = `version=54;
class Mission
{
	class Entities
	{
		items=6;
		class Item0
		{
			dataType="Marker";
			position[]={1,0,1};
			name="bigtown_2";
			text="Capital";
			type="n_service";
			id=10;
		};
		class Item1
		{
			dataType="Marker";
			position[]={2,0,2};
			name="tower_1";
			text="Tower";
			type="loc_Transmitter";
			id=11;
		};
		class Item2
		{
			dataType="Group";
			side="West";
			class Entities
			{
				items=1;
				class Item0
				{
					dataType="Object";
					name="commandant";
					type="B_officer_F";
					id=12;
				};
			};
			id=13;
		};
		class Item3
		{
			dataType="Marker";
			position[]={3,0,3};
			name="bigtown_1";
			text="Town A";
			type="n_service";
			id=14;
		};
		class Item4
		{
			dataType="Marker";
			position[]={4,0,4};
			name="capture_4";
			text="Dropped";
			type="n_art";
			id=15;
		};
		class Item5
		{
			dataType="Marker";
			position[]={5,0,5};
			name="opfor_point_1";
			type="Empty";
			id=16;
		};
	};
};
`;

const select = (...entries) => ({ selected: entries.map(([name, role]) => ({ name, role })) });

test('unselected sectors and towers are removed, everything else stays and is renumbered', () => {
    const expected = `version=54;
class Mission
{
	class Entities
	{
		items=3;
		class Item0
		{
			dataType="Marker";
			position[]={1,0,1};
			name="bigtown_2";
			text="Capital";
			type="n_service";
			id=10;
		};
		class Item1
		{
			dataType="Group";
			side="West";
			class Entities
			{
				items=1;
				class Item0
				{
					dataType="Object";
					name="commandant";
					type="B_officer_F";
					id=12;
				};
			};
			id=13;
		};
		class Item2
		{
			dataType="Marker";
			position[]={5,0,5};
			name="opfor_point_1";
			type="Empty";
			id=16;
		};
	};
};
`;
    assert.equal(applySelection(SQM, select(['bigtown_2', 'capital'])).text, expected);
});

test('a downgraded capital becomes a town: capture_ prefix and town icon, map name kept', () => {
    const { text, renamed } = applySelection(SQM, select(['bigtown_2', 'capital'], ['bigtown_1', 'downgradedCapital']));
    assert.match(text, /name="capture_bigtown_1";\n\t\t\ttext="Town A";\n\t\t\ttype="n_art";/);
    assert.match(text, /name="bigtown_2";\n\t\t\ttext="Capital";\n\t\t\ttype="n_service";/);
    assert.match(text, /items=4;/);
    assert.deepEqual(renamed, [['bigtown_1', 'capture_bigtown_1']]);
});

test('applying the same selection twice changes nothing, CRLF line endings are kept', () => {
    const selection = select(['bigtown_2', 'capital'], ['bigtown_1', 'downgradedCapital']);
    const once = applySelection(SQM.replace(/\n/g, '\r\n'), selection);
    const twice = applySelection(once.text, selection);
    assert.equal(twice.text, once.text);
    assert.deepEqual([twice.removed, twice.renamed], [[], []]);
    assert.equal(once.text.split('\r\n').length, once.text.split('\n').length);
});

test('a selected sector missing from the mission.sqm stops the run', () => {
    assert.throws(() => applySelection(SQM, select(['bigtown_2', 'capital'], ['capture_99', 'town'])), /capture_99/);
});

test('a connection to a marker that would be removed stops the run', () => {
    const linked = SQM.replace(/\};\n$/, `};
class Connections
{
	class Links
	{
		items=1;
		class Item0
		{
			linkID=0;
			item0=12;
			item1=15;
		};
	};
};
`);
    assert.throws(() => applySelection(linked, select(['bigtown_2', 'capital'])), /capture_4/);
});

test('multi-line arrays (like addons[]) do not confuse the block structure', () => {
    const withArrays = `addons[]=
{
	"A3_Characters_F",
	"A3_Signs_F"
};
` + SQM.replace('\t\t\ttext="Dropped";', '\t\t\ttext="Dropped";\n\t\t\tdrawLine[]=\n\t\t\t{\n\t\t\t\t1,\n\t\t\t\t2\n\t\t\t};');
    const { text, removed } = applySelection(withArrays, select(['bigtown_2', 'capital']));
    assert.deepEqual(removed, ['tower_1', 'bigtown_1', 'capture_4']);
    assert.match(text, /^addons\[\]=\n\{\n\t"A3_Characters_F",\n\t"A3_Signs_F"\n\};\n/);
    assert.match(text, /items=3;/);
});
