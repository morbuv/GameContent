////////////////////////////////////////////////
// Player Actions
////////////////////////////////////////////////
FAR_Player_Actions =
{
	if (alive player && player isKindOf "Man") then 
	{
		// addAction args: title, filename, (arguments, priority, showWindow, hideOnUse, shortcut, condition)
		player addAction ["<t color=""#C90000"">" + "Revive" + "</t>", "FAR_revive\FAR_handleAction.sqf", ["action_revive"], 10, true, true, "", "call FAR_Check_Revive"];
		player addAction ["<t color=""#C90000"">" + "Stabilise Bleeding" + "</t>", "FAR_revive\FAR_handleAction.sqf", ["action_stabilise"], 9, true, true, "", "call CUP_Check_Stabilise"];
		player addAction ["<t color=""#C90000"">" + "Suicide" + "</t>", "FAR_revive\FAR_handleAction.sqf", ["action_suicide"], 8.9, false, true, "", "call FAR_Check_Suicide"];
		player addAction ["<t color=""#C90000"">" + "Drag" + "</t>", "FAR_revive\FAR_handleAction.sqf", ["action_drag"], 8.9, false, true, "", "call FAR_Check_Dragging"];
		player addAction ["<t color=""#C90000"">" + "Carry" + "</t>", "FAR_revive\FAR_handleAction.sqf", ["action_carry"], 8.9, false, true, "", "call FAR_Check_Dragging"];
		// DEBUGGING ACTIONS (Don't forget to comment out when done debugging, unless you actually WANT players to straight-up cheat. That would be silly. Don't do that. Silly person.)
		/*
		player addAction ["<t color='#00C900'>[DEBUG]Revive self</t>", {player setVariable ["FAR_isUnconscious", 0, true]}, nil, -9001, false, true, "", "(player getVariable 'FAR_isUnconscious' == 1)"];
		player addAction ["<t color='#00C900'>[DEBUG]Stabilise own bleeding</t>", {player setVariable ["CUP_isBleeding", 0, true]}, nil, -9001, false, true, "", "((player getVariable 'FAR_isUnconscious' == 1) && (player getVariable 'CUP_isBleeding' == 1))"];
		//*/
	};
};

////////////////////////////////////////////////
// Handle Death
////////////////////////////////////////////////
FAR_HandleDamage_EH =
{
	private ["_unit", "_killer", "_amountOfDamage", "_isUnconscious", "_lifeCount"];

	_unit = _this select 0;
	_amountOfDamage = _this select 2;
	_killer = _this select 3;
	_isUnconscious = _unit getVariable ["FAR_isUnconscious",0];
	_lifeCount = _unit getVariable ["CUP_lifeCount",99];

	if (alive _unit && {_amountOfDamage >= 1} && {_isUnconscious == 0} && {_lifeCount != CUP_Lives}) then 
	{
		_unit setDamage 0;
		_unit allowDamage false;
		_unit setVariable ["CUP_lifeCount", _lifeCount + 1, true];
		[_unit, _killer] spawn FAR_Player_Unconscious;
		_amountOfDamage = 0;
	};

	_amountOfDamage
};

////////////////////////////////////////////////
// Make Player Unconscious
////////////////////////////////////////////////
FAR_Player_Unconscious =
{
	private["_unit", "_killer"];
	_unit = _this select 0;
	_killer = _this select 1;

	// Death message
	//if (FAR_EnableDeathMessages == 1) then
	if (FAR_EnableDeathMessages) then
	{
		FAR_deathMessage_EH = [_unit, _killer];
		publicVariable "FAR_deathMessage_EH";
		["FAR_deathMessage_EH", [_unit, _killer]] call FAR_public_EH;
	};

	if (isPlayer _unit) then
	{
		disableUserInput true;
		titleText ["", "BLACK FADED"];
	};

	// Eject unit if inside vehicle
	if (vehicle _unit != _unit) then 
	{
		unAssignVehicle _unit;
		_unit action ["eject", vehicle _unit];
		
		sleep 2;
	};

	_unit setDamage 0;
	_unit setVelocity [0,0,0];
	_unit allowDamage false;
	_unit setCaptive true;
	_unit playMove "AinjPpneMstpSnonWrflDnon_rolltoback";

	sleep 4;
	
	if (isPlayer _unit) then
	{
		titleText ["", "BLACK IN", 1];
		disableUserInput false;
	};

	_unit switchMove "AinjPpneMstpSnonWrflDnon";
	_unit enableSimulation false;
	_unit setVariable ["FAR_isUnconscious", 1, true];
	_unit setVariable ["CUP_isBleeding", 1, true];
	//if (CUP_AllowDamage == 1) then {_unit allowDamage true};
	if (CUP_AllowDamage) then {_unit allowDamage true};
	// Call this code only on players
	if (isPlayer _unit) then 
	{
		_bleedOut = time + FAR_BleedOut;
		
		while { !isNull _unit && {alive _unit} && {_unit getVariable "FAR_isUnconscious" == 1} && {(FAR_BleedOut <= 0 || time < _bleedOut || (_unit getVariable "CUP_isBleeding" == 0))} } do
		{
			if (_unit getVariable "CUP_isBleeding" == 1) then
			{
				hintSilent format["Bleedout in %1 seconds\n\n%2", round (_bleedOut - time), call FAR_CheckFriendlies];
				sleep 0.5;
			}
			else
			{
				hintSilent format["Bleeding has been stabilised\n\n%1", call FAR_CheckFriendlies];
				sleep 0.5;
			};
		};
		
		// Player bled out
		if (FAR_BleedOut > 0 && {time > _bleedOut} && {_unit getVariable "CUP_isBleeding" == 1}) then
		{
			_unit setCaptive false;
			_unit enableSimulation true;
			_unit allowDamage true;
			_unit setDamage 1;
			_unit setVariable ["FAR_isUnconscious", 0, true];
			_unit setVariable ["FAR_isDragged", 0, true];
			_unit setVariable ["CUP_isBleeding", 0, true];
		}
		else
		{
			// Player got revived
			sleep 6;
			// Clear the "medic nearby" hint
			hintSilent "";
			// Warn the player if this is their last life (Added by Professor Cupcake)
			if (((_unit getVariable "CUP_lifeCount") == CUP_Lives)) then
			{
				hint "WARNING: If you get hit again, you will die instantly.";
			};
			
			_unit enableSimulation true;
			_unit allowDamage true;
			_unit setDamage CUP_ReviveDamage;
			_unit setCaptive false;
			
			_unit playMove "amovppnemstpsraswrfldnon";
			_unit playMove "";
		};
	}
	else
	{
		// [Debugging] Bleedout for AI
		_bleedOut = time + FAR_BleedOut;
		
		while { !isNull _unit && {alive _unit} && {_unit getVariable "FAR_isUnconscious" == 1} && {(FAR_BleedOut <= 0 || time < _bleedOut)} } do
		{
			sleep 0.5;
		};
		
		// AI bled out
		if (FAR_BleedOut > 0 && {time > _bleedOut}) then
		{
			_unit setDamage 1;
			_unit setVariable ["FAR_isUnconscious", 0, true];
			_unit setVariable ["FAR_isDragged", 0, true];
		}
	};
};

////////////////////////////////////////////////
// Revive Player
////////////////////////////////////////////////
FAR_HandleRevive =
{
	private ["_target"];
	_target = _this select 0;

	if (alive _target) then
	{
		player playMove "AinvPknlMstpSlayWrflDnon_medic";

		_target setVariable ["CUP_isBleeding", 0, true];
		_target setVariable ["FAR_isUnconscious", 0, true];
		_target setVariable ["FAR_isDragged", 0, true];
		
		sleep (random CUP_ReviveTime + 15);
		
		// [Debugging] Code below is only relevant if revive script is enabled for AI
		if (!isPlayer _target) then
		{
			_target enableSimulation true;
			_target allowDamage true;
			_target setDamage 0;
			_target setCaptive false;
			
			_target playMove "amovppnemstpsraswrfldnon";
		};

		// If revive mode 3 is used and the player has no Medikit (therefore must have at least one FAK, since the action is unavailable otherwise), remove a FAK from the player's inventory. 
		if ( FAR_ReviveMode == 3 && !("Medikit" in (items player)) ) then
		{
			player removeItem "FirstAidKit";
		};
		
	};
};

////////////////////////////////////////////////
// Stabilise Player
////////////////////////////////////////////////
// Added by Professor Cupcake

CUP_HandleStabilise =
{
	private ["_target"];
	_target = _this select 0;

	if (alive _target) then
	{
		player playMove "AinvPknlMstpSlayWrflDnon_medic";
		
		sleep 6;
		
		_target setVariable ["CUP_isBleeding", 0, true];

		player removeItem "FirstAidKit";
		
	};
};

////////////////////////////////////////////////
// Drag Injured Player
////////////////////////////////////////////////
FAR_Drag =
{
	private ["_target", "_id"];

	FAR_isDragging = true;

	_target = _this select 0;

	_target attachTo [player, [0, 1.1, 0.092]];
	_target setDir 180;
	_target setVariable ["FAR_isDragged", 1, true];

	player playMoveNow "AcinPknlMstpSrasWrflDnon";

	// Rotation fix
	FAR_isDragging_EH = _target;
	publicVariable "FAR_isDragging_EH";

	// Add release action and save its id so it can be removed
	_id = player addAction ["<t color=""#C90000"">" + "Release" + "</t>", "FAR_revive\FAR_handleAction.sqf", ["action_release"], 10, true, true, "", "true"];

	hint "Press 'C' if you can't move.";

	// Wait until release action is used
	waitUntil 
	{ 
		!alive player || player getVariable "FAR_isUnconscious" == 1 || !alive _target || _target getVariable "FAR_isUnconscious" == 0 || !FAR_isDragging || _target getVariable "FAR_isDragged" == 0 
	};

	// Handle release action
	FAR_isDragging = false;

	if (!isNull _target && alive _target) then
	{
		_target switchMove "AinjPpneMstpSnonWrflDnon";
		_target setVariable ["FAR_isDragged", 0, true];
		detach _target;
	};

	player removeAction _id;
};

////////////////////////////////////////////////
// Release Dragged Injured Player
////////////////////////////////////////////////
FAR_Release =
{
	// Switch back to default animation
	player playMove "amovpknlmstpsraswrfldnon";

	FAR_isDragging = false;
};

////////////////////////////////////////////////
// Carry Injured Player
////////////////////////////////////////////////
FAR_carry =
{
	private ["_injured","_act","_men","_healer","_veh_selected","_array","_array_veh","_name_veh","_text_action","_action_id"];
	
	_act = 0;
	_veh_selected = objNull;
	
	_array_veh = [];
	//_men = nearestObjects [player, ["CaManBase"], 2];
	//if (count _men > 1) then {_injured = _men select 1;};
	//if (format ["%1",_injured getVariable "FAR_need_revive"] != "1") exitWith {};
	
	FAR_isDragging = true;
	
	_injured = _this select 0;	
	_healer = player;
	_injured setVariable ["FAR_isDragged",1,true];
	detach _injured;

systemChat format ["%1 - START", time];
	
	_injured switchMove "ainjpfalmstpsnonwrfldnon_carried_up";
	player playMoveNow "acinpknlmstpsraswrfldnon_acinpercmrunsraswrfldnon";

	// Add release action and save its id so it can be removed
	_id = player addAction ["<t color=""#C90000"">" + "Release" + "</t>", "FAR_revive\FAR_handleAction.sqf", ["action_release"], 10, true, true, "", "true"];

	FAR_carry_EH = [_injured,_healer];
	publicVariable "FAR_carry_EH";

systemChat format ["%1 - WAIT CARRY UP", time];
	
	WaitUntil {!alive player || ((animationstate player == "acinpercmstpsraswrfldnon") || (animationstate player == "acinpercmrunsraswrfldf") || (animationstate player == "acinpercmrunsraswrfldr") || (animationstate player == "acinpercmrunsraswrfldl"))};

systemChat format ["%1 - CARRY UP", time];

	_injured switchMove "AinjPfalMstpSnonWnonDf_carried_dead";

	_injured setVelocity [0,0,0];	
	_injured enableSimulation false;
	_injured attachTo [player,[-0.3,-0.1,0]];

systemChat format ["%1 - CARRY DEAD", time];
	
	while {
			!(isNull player) && 
			{ (alive player) } && 
			{ !(isNull _injured) } && 
			{ (alive _injured) } && 
			{ (_injured getVariable ["FAR_isUnconscious", 0] == 1) } && 
			{ FAR_isDragging } 
		} do
	{
		_injured setVelocity [0,0,0];
		_array = nearestObjects [player, ["Air","LandVehicle"], 5];
		_array_veh = [];
		{if (_x emptyPositions "cargo" != 0) then {_array_veh = _array_veh + [_x];};} foreach _array;
		if (count _array_veh == 0) then {_veh_selected = objNull;};
		if (count _array_veh > 0 && _veh_selected != _array_veh select 0) then 
		{
			_veh_selected    = _array_veh select 0;
			_name_veh        = getText (configFile >> "cfgVehicles" >> typeof _veh_selected >> "displayName");
			_text_action     = ("<t color=""#ED2744"">" + "Load wounded in " + (_name_veh) + "</t>");
			_action_id = player addAction [_text_action,"FAR_revive\FAR_handleAction.sqf",["action_load",[_injured,_veh_selected]], 7, true, true];
			_act  = 1;
		};
		if (count _array_veh == 0 && _act == 1) then {player removeAction _action_id;_act = 0;};
		sleep 0.1;
	};
	
	_injured enableSimulation true;
	if (_act == 1) then {player removeAction _action_id;};
	player playAction "released";
	_injured switchMove "AinjPfalMstpSnonWrflDnon_carried_down";
	
	FAR_carryDrop_EH = [_injured];
	publicVariable "FAR_carryDrop_EH";
	
	detach _injured;
	_injured setVariable ["FAR_isDragged",0,true];
	
	player removeAction _id;
	FAR_dragging = false;
};

////////////////////////////////////////////////
// Load Injured Player into vehicle
////////////////////////////////////////////////
FAR_load_in = 
{
	private ["_injured","_vehicle"];
	_injured = _this select 0;
	_veh     = _this select 1;
	FAR_dragging = false;
	FAR_load_EH = [_injured,_vehicle];
	publicVariable "FAR_load_EH";
};

////////////////////////////////////////////////
// Event handler for public variables
////////////////////////////////////////////////
FAR_public_EH =
{
	if(count _this < 2) exitWith {};

	private ["_target", "_injured", "_healer", "_EH"];
	
	_EH  = _this select 0;
	_target = _this select 1;

	// FAR_isDragging
	if (_EH == "FAR_isDragging_EH") then
	{
		//_target setDir 180;
		_target setDir ((getDir _healer - 90) % 360);
	};
	
	// FAR_carry
	if (_EH == "FAR_carry_EH") then
	{
		_injured = _target select 0;
		_healer = _target select 1;

		_injured setDir (((getDir _healer) + 180) % 360);
		_injured setPos (_healer modelToWorld [0,1,0]);				

//systemChat "Starting waituntil animation state";
player sideChat format ["%1 - CARRIED UP: %2", time, _healer];	

		WaitUntil {!alive _healer || ((animationstate _healer == "acinpercmstpsraswrfldnon") || (animationstate _healer == "acinpercmrunsraswrfldf") || (animationstate _healer == "acinpercmrunsraswrfldr") || (animationstate _healer == "acinpercmrunsraswrfldl"))};

systemChat "Ended waituntil animation state";

		_injured switchMove "AinjPfalMstpSnonWnonDf_carried_dead";
systemChat "Start setpos";
		_injured setPos (_healer modelToWorld [-1,0,0]);	
player sideChat format ["%1 - CARRY DEAD", time];
	};

	// FAR_carryDrop
	if (_EH == "FAR_carryDrop_EH") then
	{
		_injured = _target select 0;
		
		_injured switchMove "AinjPfalMstpSnonWrflDnon_carried_down";
		sleep 3;
		if (format ["%1",_injured getVariable "BTC_need_revive"] == "1") then 
		{
			_injured switchMove "ainjppnemstpsnonwrfldnon";
		};
	};
	
	// FAR_load
	if (_EH == "FAR_load_EH") then
	{
		_injured = _target select 0;
		_vehicle = _target select 1;
		if (name _injured == name player) then 
		{
			_injured moveInCargo _vehicle;
		};
	};
	
	// FAR_deathMessage
	if (_EH == "FAR_deathMessage_EH") then
	{
		_killed = _target select 0;
		_killer = _target select 1;

		if (isPlayer _killed && isPlayer _killer) then
		{
			systemChat format["%1 was injured by %2", name _killed, name _killer];
		};
		if (isPlayer _killed && !isPlayer _killer) then
		{
			systemChat format["%1 was injured", name _killed];
		};
	};
};

////////////////////////////////////////////////
// Revive Action Check
////////////////////////////////////////////////
FAR_Check_Revive = 
{
	private ["_target", "_isTargetUnconscious", "_isDragged"];

	_return = false;

	// Unit that will excute the action
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";
	_isMedic = getNumber (configfile >> "CfgVehicles" >> typeOf player >> "attendant");
	_target = cursorTarget;

	// Make sure player is alive and target is an injured unit
	if( !alive player || _isPlayerUnconscious == 1 || FAR_isDragging || isNil "_target" || !alive _target || (!isPlayer _target && !FAR_Debugging) || (_target distance player) > 2 ) exitWith
	{
		_return
	};

	_isTargetUnconscious = _target getVariable "FAR_isUnconscious";
	_isDragged = _target getVariable "FAR_isDragged"; 

	// Make sure target is unconscious and player is a medic 
	if (_isTargetUnconscious == 1 && _isDragged == 0 && (_isMedic == 1 || FAR_ReviveMode > 0) ) then
	{
		_return = true;

		// [ReviveMode] Check if player has a Medikit
		if ( ((FAR_ReviveMode == 2) || (FAR_ReviveMode == 4)) && !("Medikit" in (items player)) ) then
		{
			_return = false;
		};
		
		// [ReviveMode] Check if player has a Medikit, then a First Aid Kit (added by Professor Cupcake)
		if ( FAR_ReviveMode == 3 && !("Medikit" in (items player)) ) then
		{
			if !("FirstAidKit" in (items player)) then
			{
				_return = false;
			};
		};
	};

	_return
};

////////////////////////////////////////////////
// Stabilise Action Check (Revive Mode 4)
////////////////////////////////////////////////
// Added by Professor Cupcake

CUP_Check_Stabilise = 
{
	private ["_target", "_isTargetUnconscious", "_isDragged", "_isTargetBleeding"];

	_return = false;

	// Unit that will excute the action
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";
	_isMedic = getNumber (configfile >> "CfgVehicles" >> typeOf player >> "attendant");
	_target = cursorTarget;

	// Make sure player is alive, target is an injured unit and revive mode 4 is selected
	if( !alive player || _isPlayerUnconscious == 1 || FAR_isDragging || isNil "_target" || !alive _target || (!isPlayer _target && !FAR_Debugging) || (_target distance player) > 2 || FAR_ReviveMode != 4) exitWith
	{
		_return
	};

	_isTargetUnconscious = _target getVariable "FAR_isUnconscious";
	_isTargetBleeding = _target getVariable "CUP_isBleeding";
	_isDragged = _target getVariable "FAR_isDragged"; 

	// Make sure target is unconscious and bleeding and player has a FAK
	if (_isTargetUnconscious == 1 && _isTargetBleeding == 1 && _isDragged == 0 && ("FirstAidKit" in (items player))) then
	{
		_return = true;
	};

	_return
};

////////////////////////////////////////////////
// Suicide Action Check
////////////////////////////////////////////////
FAR_Check_Suicide =
{
	_return = false;
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";

	if (alive player && _isPlayerUnconscious == 1) then 
	{
		_return = true;
	};

	_return
};

////////////////////////////////////////////////
// Dragging Action Check
////////////////////////////////////////////////
FAR_Check_Dragging =
{
	private ["_target", "_isPlayerUnconscious", "_isDragged"];

	_return = false;
	_target = cursorTarget;
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";

	if( !alive player || _isPlayerUnconscious == 1 || FAR_isDragging || isNil "_target" || !alive _target || (!isPlayer _target && !FAR_Debugging) || (_target distance player) > 2 ) exitWith
	{
		_return;
	};

	// Target of the action
	_isTargetUnconscious = _target getVariable "FAR_isUnconscious";
	_isDragged = _target getVariable "FAR_isDragged"; 

	if(_isTargetUnconscious == 1 && _isDragged == 0) then
	{
		_return = true;
	};
	
	_return
};

////////////////////////////////////////////////
// Show Nearby Friendly Medics
////////////////////////////////////////////////
FAR_IsFriendlyMedic =
{
	private ["_unit"];

	_return = false;
	_unit = _this;
	_isMedic = getNumber (configfile >> "CfgVehicles" >> typeOf _unit >> "attendant");
	
	if ( alive _unit && {(isPlayer _unit || FAR_Debugging)} && {side _unit == FAR_PlayerSide} && {_unit getVariable "FAR_isUnconscious" == 0} && {(_isMedic == 1 || FAR_ReviveMode > 0)} ) then
	{
		_return = true;
	};

	_return
};

FAR_CheckFriendlies =
{
	private ["_unit", "_units", "_medics", "_hintMsg"];

	_units = nearestObjects [getpos player, ["Man", "Car", "Air", "Ship"], 800];
	_medics = [];
	_dist = 800;
	_hintMsg = "";

	// Find nearby friendly medics
	if (count _units > 1) then
	{
		{
			if (_x isKindOf "Car" || _x isKindOf "Air" || _x isKindOf "Ship") then
			{
				if (alive _x && count (crew _x) > 0) then
				{
					{
						if (_x call FAR_IsFriendlyMedic) then
						{
							_medics = _medics + [_x];
							
							if (true) exitWith {};
						};
					} forEach crew _x;
				};
			} 
			else 
			{
				if (_x call FAR_IsFriendlyMedic) then
				{
					_medics = _medics + [_x];
				};
			};
			
		} forEach _units;
	};

	// Sort medics by distance
	if (count _medics > 0) then
	{
		{
			if (player distance _x < _dist) then
			{
				_unit = _x;
				_dist = player distance _x;
			};
			
		} forEach _medics;
		
		if (!isNull _unit) then
		{
			_unitName  = name _unit;
			_distance  = floor (player distance _unit);
			
			_hintMsg = format["Nearby Medic:\n%1 is %2m away.", _unitName, _distance];
		};
	} 
	else 
	{
		_hintMsg = "No medic nearby.";
	};

	_hintMsg
};
