/*
0 = no NVG
1 = found NVG during NT or found during DT and readed during NT
2 = found NVG during DT and removed
*/

if ( isNil "T1_NVG_loop" ) then { T1_NVG_loop = true; };

_MCC_check_NVG_day =
{
	private ["_NVG", "_unit"];
	
	_NVG = _this select 0;
	_unit = _this select 1;

	if ( _unit getVariable ["Tier1_NVG", 1] == 1 ) then
	{	
		if ( _NVG in (assignedItems _unit) ) then
		{
			//diag_log str ["REMOVE NVG: ", _unit, _NVG];
			//if ( (isPlayer _unit) && !(backpack _unit == "") ) then // players
			//{
			//	_unit unlinkItem _NVG;
			//	_unit addItemToBackpack _NVG;
			//}
			//else //AI
			//{
				_unit unlinkItem _NVG;
			//};
						
			_unit setVariable ["Tier1_NVG", 2];
		}
		else
		{
			_unit setVariable ["Tier1_NVG", 0]; // no NVGs
		};
	};
};


_MCC_check_NVG_night = 
{
	private ["_NVG", "_unit"];
	
	_NVG = _this select 0;
	_unit = _this select 1;
	
	if !( _unit getVariable ["Tier1_NVG", 1] == 0 ) then
	{	
		if ( !( _NVG in (assignedItems _unit)) && (_unit getVariable ["Tier1_NVG", 0] == 2) ) then
		{
			//diag_log str ["ADD NVG: ", _unit, _NVG];			
			_unit linkItem _NVG;
			
			//if ( (isPlayer _unit) && !(backpack _unit == "") ) then
			//{
			//	_unit removeItemFromBackpack _NVG;
			//};
		};
		
		if ( _NVG in (assignedItems _unit) ) then
		{
			_unit setVariable ["Tier1_NVG", 1]; // NVG
		}
		else
		{
			_unit setVariable ["Tier1_NVG", 0]; // No NVG
		};
	};
};


while { T1_NVG_loop } do
{
	
	sleep 71;
	
	if ( sunOrMoon > 0.5 ) then 
	{	
		// Daytime		
		{
			if ( (_x getVariable ["Tier1_NVG", 1]) == 1 ) then 
			{
				if ( side _x == east ) exitWith
				{
					["NVGoggles_OPFOR", _x] spawn _MCC_check_NVG_day;
				};

				if ( side _x == west ) exitWith
				{
					["NVGoggles", _x] spawn _MCC_check_NVG_day;
				};
							
				if ( side _x == resistance ) exitWith
				{
					["NVGoggles_INDEP", _x] spawn _MCC_check_NVG_day;
				};
			};
		} forEach allUnits;
	}
	else
	{
		// Night time
		{
			if ( (_x getVariable ["Tier1_NVG", 2]) > 1) then 
			{
				if ( side _x == east ) exitWith
				{
					["NVGoggles_OPFOR", _x] spawn _MCC_check_NVG_night;
				};

				if ( side _x == west ) exitWith
				{
					["NVGoggles", _x] spawn _MCC_check_NVG_night;
				};
				
				if ( side _x == resistance ) exitWith
				{
					["NVGoggles_INDEP", _x] spawn _MCC_check_NVG_night;
				};
			};
		} forEach allUnits;
	};
};
