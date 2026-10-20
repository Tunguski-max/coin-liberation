/*
    File: fn_isNestSpotAllowed.sqf
    Author: COIN Liberation

    Description:
        Placement rules that apply to every nest, building or terrain (ticket 2.2, DESIGN 5):
        land, at least COIN_nestMinDistMapEdge from the map edge, COIN_nestMinDistStartBase from the start base,
        COIN_nestMinDistCapital from the capital and COIN_nestMinDistSector from every sector centre, so guards never
        stand inside the 175 m Liberation evaluates for capture and loss (ADR 0018).
        Distances to other nests are checked by the caller, they are lowered step by step.

    Parameter(s):
        _pos - Position [ARRAY]

    Returns:
        Position is allowed [BOOL]
*/

params [
    ["_pos", [], [[]]]
];

private _edge = COIN_nestMinDistMapEdge;
_pos params ["_posX", "_posY"];

_posX >= _edge && {_posX <= worldSize - _edge} && {_posY >= _edge} && {_posY <= worldSize - _edge}
&& {!(surfaceIsWater _pos)}
&& {(_pos distance2D startbase) >= COIN_nestMinDistStartBase}
&& {(sectors_bigtown findIf {(_pos distance2D (markerPos _x)) < COIN_nestMinDistCapital}) < 0}
&& {(sectors_allSectors findIf {(_pos distance2D (markerPos _x)) < COIN_nestMinDistSector}) < 0}
