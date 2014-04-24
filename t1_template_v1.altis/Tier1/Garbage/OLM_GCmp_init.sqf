/*
======================================================
	Author: Joris-Jan van 't Land & Karel Moricky
	MP update: Ollem
======================================================
*/

/*	
======================================================
	Function OLM_fnc_GCmp Description:
	Sends an entity to the garbage collection mp_queue.

	Parameter(s):
	_this select 0: the entity
	
	Returns:
	Success flag (Boolean).
======================================================
*/
OLM_fnc_GCmp = 
{
	private ["_object", "_mp_queue", "_timeToDie"];
	_object = [[_this]] call bis_fnc_param;

	_mp_queue = bis_functions_mainscope getVariable "mp_queue";

	//--- Multiple Items
	if ((typeName _object) == (typename [])) exitwith {
		{
			_x call OLM_fnc_GCmp;
		} count _object;
		true
	};

	switch (typeName _object) do
	{
		//--- Object
		case (typeName objNull):
		{
			_timeToDie = time + 240;
		};

		//--- Group
		case (typeName grpNull):
		{
			_timeToDie = time + 60;
		};

		//--- Everything else
		default
		{
			_timeToDie = time;
		};
	};

	_mp_queue = _mp_queue + [[_object, _timeToDie]];
	bis_functions_mainscope setVariable ["mp_queue", _mp_queue];

	//["%1 %2 marked for deletion",typename _object,_object] call bis_fnc_logFormat;
	diag_log format ["%1 - Garbage Collect: %2 %3 marked for deletion",time, typename _object,_object];

	true
};

/*
==========================================================================
main Garbage Collect Loop
Checks every 2 minutes for dead units + gear and adds it to garbase queue
==========================================================================
*/
OLM_fnc_GCmp_mainloop =
{
	diag_log format ["%1 - Starting MP Garbage Collect main loop", time];
	
	//clean up using garbage collector
	while {true} do
	{
		sleep 300;
		{
			if (!(_x getVariable ["garbage",false]) && !(isPlayer _x)) then 
			{
				_x setVariable ["garbage",true];
				//diag_log format ["%1 - Garbage Collect: added unit '%2' to GC mp_queue", diag_ticktime, _x]; 
				[_x] call OLM_fnc_GCmp;
			};
		} count allDead;
		
		{
			if ((count units _x)==0) then 
			{
				deleteGroup _x;
			};
		} count allGroups;		
	};
};


// Start main GC process
if (isnil {bis_functions_mainscope getvariable "mp_queue"}) then
{
	OLM_fnc_initGC = [] execFSM "Tier1\Garbage\OLM_GCmp.fsm";

	waituntil {!isnil {bis_functions_mainscope getvariable "mp_queue"}};
	[] spawn OLM_fnc_GCmp_mainloop;
};


