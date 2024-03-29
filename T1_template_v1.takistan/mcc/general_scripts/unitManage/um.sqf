#define MCC_UM_LIST 3069
#define MCC_UM_PIC 3070
#define MCC_MINIMAP 9000

disableSerialization;

private ["_type", "_name", "_worldPos","_dummy", "_unitpos", "_ok", "_markerColor", "_leader", "_markerType", "_tempMarkers", "_tempLines", "_tempVehicles",
		"_targetUnit","_oldUnit","_group","_params","_ctrl","_pressed","_shift","_ctrlKey","_mccdialog","_comboBox","_nul","_dummyUnit","_control","_cam","_side"];

_mccdialog = (uiNamespace getVariable "MCC_groupGen_Dialog");
_comboBox = _mccdialog displayCtrl MCC_UM_LIST;
_type = _this select 0;

	switch (_type) do
	{
		case 0: //Teleport
		{
			mapClick = false; 
			hint "Click on the map"; 
			onMapSingleClick " 	hint format ['%1 teleported', UMName];
								teleportPos = _pos; 
								mapClick = true;
								onMapSingleClick """";";
			waituntil {mapClick};
			if (MCC_UMUnit==0) then 
			{
				{
					[[[netID _x,_x],teleportPos], "MCC_fnc_moveToPos", _x, false] spawn BIS_fnc_MP;
				} foreach MCC_selectedUnits;
			} 
			else 
			{
				{
					{
						[[[netID _x,_x],teleportPos], "MCC_fnc_moveToPos", _x, false] spawn BIS_fnc_MP;
						sleep 0.2; 
					} foreach (units _x);
				} foreach MCC_selectedUnits;
			};
		};
		
		case 1:	//Teleport to LHD
		{
			_worldPos = deck modelToWorld [0,0,0];
			if (MCC_UMUnit==0) then 
			{
				{[[[netID _x,_x],[_worldPos select 0, _worldPos select 1, 15.9]], "MCC_fnc_moveToPos", true, false] spawn BIS_fnc_MP} foreach MCC_selectedUnits;
			} 
			else
			{
				{{[[[netID _x,_x],[_worldPos select 0, _worldPos select 1, 15.9]], "MCC_fnc_moveToPos", true, false] spawn BIS_fnc_MP} foreach (units _x);} foreach MCC_selectedUnits;
			};
		};

		case 2:	//Hijak unit
		{
			if (MCC_UMUnit==0) then 
			{
				_targetUnit = MCC_UMunitsNames select (lbCurSel MCC_UM_LIST);	//Hijacked unit
				if (isplayer _targetUnit) exitwith {hint "Can't hijak other players"};
				MCC_PrevHijacked_Group = netID (group _targetUnit);
				MCC_Prev_HijackedGroupIsLeader = if (leader group _targetUnit == _targetUnit) then {true} else {false}; 
				
				MCC_Prev_Player = player; 
				MCC_Prev_Group = group Player;
				MCC_Prev_GroupIsLeader = if (leader group player == player) then {true} else {false}; 
				MCC_Prev_Side = side player; 
				_oldUnit = player; 
				_group = creategroup (side _targetUnit); 
				[_targetUnit] joinSilent _group;
				
				closeDialog 0;
				private ["_camera","_ppgrain"];
				_camera = "Camera" camcreate [(getpos _targetUnit) select 0, (getpos _targetUnit) select 1,((getpos _targetUnit) select 2) + 100];
				_camera cameraeffect ["internal","back"];
				_camera camPrepareFOV 0.900;
				_camera camsetTarget _targetUnit;
				_camera campreparefocus [-1,-1];
				_camera camCommitPrepared 0;
				_camera camcommit 0.01;
				cameraEffectEnableHUD true;
				
				_ppgrain = ppEffectCreate ["radialBlur", 100];
				_ppgrain ppEffectAdjust [0.5, 0.5, 0.3, 0.3];
				_ppgrain ppEffectCommit 0;
				_ppgrain ppEffectEnable true;
				
				playsound "MCC_woosh"; 
				for "_i" from floor(((getpos _targetUnit) select 2) + 100) to 0 step -3 do 
				{
					_camera camsetpos [(getpos _targetUnit) select 0, (getpos _targetUnit) select 1,_i];
					_camera camcommit 0.01;
					sleep 0.01;
				}; 
				
				_camera cameraEffect ["TERMINATE", "BACK"];
				camdestroy _camera;
				_camera = nil; 
				
				
				
				removeSwitchableUnit _oldUnit;
				_group selectLeader player;
				selectPlayer _targetUnit;
					
				deletegroup _group;
				
				_ppgrain ppEffectEnable false;
				MCC_hijack_effect = ppEffectCreate ["radialBlur", 100];
				MCC_hijack_effect ppEffectAdjust [1, 1, 0.4, 0.4];
				MCC_hijack_effect ppEffectCommit 0;
				MCC_hijack_effect ppEffectEnable true;
				
				MCC_backToplayerIndex = _targetUnit addaction ["<t color=""#CC0000"">Back To Player</t>", MCC_path + "mcc\general_scripts\unitManage\backToPlayer.sqf",[], 0,false, false, "teamSwitch","vehicle _target == vehicle _this"];
				mcc_actionInedx = player addaction ["<t color=""#99FF00"">--= MCC =--</t>", MCC_path + "mcc\dialogs\mcc_PopupMenu.sqf",[], 0,false, false, "teamSwitch","vehicle _target == vehicle _this"];
				_ok = _targetUnit addEventHandler ["Killed", format ["[_this select 0] execVM '%1mcc\general_scripts\unitManage\backToPlayer.sqf'",MCC_path]];
				
				if (MCC_PrevHijacked_Group != "") then
				{
					[player] joinSilent (groupFromNetID MCC_PrevHijacked_Group);
					waituntil {group player == (groupFromNetID MCC_PrevHijacked_Group)};
					if (MCC_Prev_HijackedGroupIsLeader) then 
					{
						if (isMultiplayer) then
						{
							[[2, compile format ["(groupFromNetID '%1') selectLeader objectFromNetId '%2'",netID (group Player), netID player]], "MCC_fnc_globalExecute", true, false] spawn BIS_fnc_MP;
						}
						else
						{
							(group player) selectLeader player;
						}; 
					};
				};
			}
			else
			{hint "Can only hijak units not groups"};
		};
			
		case 3:	//Markers
		{
			MCC_trackMarker = !MCC_trackMarker; 
			
			if (MCC_trackMarker) then
			{
				MCC_trackMarkerHandler = ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9000) ctrladdeventhandler ["draw","_this call MCC_fnc_trackUnits;"];
				MCC_trackMarkerHandlerMap = (findDisplay 12 displayCtrl 51) ctrladdeventhandler ["draw","_this call MCC_fnc_trackUnits; _this call MCC_fnc_mapDrawWP;"];
			}
			else
			{
				if (!isnil "MCC_trackMarkerHandler") then 
				{
					((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9000) ctrlRemoveEventHandler ["draw",MCC_trackMarkerHandler];
				}; 
				
				if (!isnil "MCC_trackMarkerHandlerMap") then 
				{
					(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["draw",MCC_trackMarkerHandlerMap];
				};
			}; 
		};
		
		case 4:	//Indevidual Marker
		{
			if ((lbCurSel MCC_UM_LIST)>=0) then 
			{
				if (MCC_UMisJoining) then //Joining
				{					
					MCC_UMisJoining = false;
					if (MCC_UMUnit==0) then 
					{
						UMName =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST);
						//[UMJoin] joinSilent grpNull;
						[UMJoin] joinSilent (group UMName);
					} 
					else 
					{
						UMName = UMgroupNames select (lbCurSel MCC_UM_LIST);
						//(units UMName) joinSilent grpNull;
						(units UMJoin) joinSilent UMName;
						deletegroup UMName;
					};
				};
				
				private "_name"; 
				if (MCC_UMUnit==0) then 
				{
					_name =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST);
				} 
				else 
				{
					_name = leader (UMgroupNames select (lbCurSel MCC_UM_LIST));
				};
					
				//Do not refresh if we haven't picked another group
				if (isnil "UMName") then {UMName = _name};
				
				UMName = _name;
				deletemarkerlocal "currentUnitSelected";
				createMarkerLocal ["currentUnitSelected", getpos UMName];
				"currentUnitSelected" setMarkerTypelocal "Select";
				"currentUnitSelected" setMarkerColorlocal "ColorRed";
				_control = _mccdialog displayCtrl MCC_MINIMAP;
				_control ctrlMapAnimAdd [0.5, (ctrlMapScale ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl MCC_MINIMAP)), getpos UMName];
				ctrlMapAnimCommit _control;
				
				if (! isnil "MCC_PIPcam") then 
				{
					if (MCC_PIPcam != ObjNull) then 
					{
						MCC_PIPcam cameraEffect ["TERMINATE", "BACK"];
						camDestroy MCC_PIPcam;
					};
				};
				
				_control = _mccdialog displayCtrl MCC_UM_PIC;
				[_control] call MCC_fnc_pipOpen;	
				
				MCC_PIPcam = "camera" camCreate getPos player;
				waitUntil {alive MCC_PIPcam};
				
				MCC_PIPcam attachTo [vehicle (UMName),[10,15,10]]; // ->todo: grab this from a custom config
				if(vehicle (UMName) isKindOf "Man") then {MCC_PIPcam  camSetFov 0.15} else {MCC_PIPcam  camSetFov 0.8}; 
				MCC_PIPcam  camSetTarget vehicle (UMName);
				MCC_PIPcam cameraEffect ["INTERNAL", "BACK", "rendertarget10"];
				MCC_PIPcam camCommit 0; // commit Changes
				
				private ["_effectParams"];
				_effectParams = switch (MCC_UMPIPView) do 
								{
									// Normal
									case 0: 
									{
										[3, 1, 1, 1, 0.1, [0, 0.4, 1, 0.1], [0, 0.2, 1, 1], [0, 0, 0, 0]]
									};
									
									// Night vision
									case 1: 
									{
										[1]
									};
									
									// Thermal imaging
									case 2: 
									{
										[2]
									};
								};
				
				sleep 0.1;
				// Set effect
				"rendertarget10" setPiPEffect _effectParams;
				_control ctrlsettext"#(argb,512,512,1)r2t(rendertarget10,1.0);";
				sleep 0.1;
				_control ctrlsettext"#(argb,512,512,1)r2t(rendertarget10,1.0);";
			};
		};
		
		case 5:	//High command: Assighn Commander
		{
		if ((lbCurSel MCC_UM_LIST)>=0) then 
			{
			if (MCC_UMUnit==1) then 
				{
				hint "Only units can be assighned as high commanders";
				} 
				else 
				{
				UMName =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST);
				[[[netID UMName,UMName],0],"MCC_fnc_highCommand",true,false] call BIS_fnc_MP;
				};
			};
		};

		case 6:	//High command: Clear ALL groups
		{
		if ((lbCurSel MCC_UM_LIST)>=0) then 
			{
			if (MCC_UMUnit==0) then 
				{UMName =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)} 
				else {UMName = leader (UMgroupNames select (lbCurSel MCC_UM_LIST))};
			hint "cleared all High Command units"; 
			[[[netID UMName,UMName],1],"MCC_fnc_highCommand",true,false] call BIS_fnc_MP;
			};
		};
		
		case 7:	//High command: Add group
		{
		if ((lbCurSel MCC_UM_LIST)>=0) then 
			{
			if (MCC_UMUnit==0) then 
				{UMName =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)} 
				else {UMName = leader (UMgroupNames select (lbCurSel MCC_UM_LIST))};
			hint "Group Added"; 
			[[[netID UMName,UMName],2],"MCC_fnc_highCommand",true,false] call BIS_fnc_MP;
			};
		};

		case 8:	//Multi-Selection
		{
			_params = _this select 1;

			_ctrl = _params select 0;
			_pressed = _params select 1;
			_shift = _params select 4;
			_ctrlKey = _params select 5;
			
			if (MCC_UMUnit==0) then // Units selection
			{
				if ((lbCurSel MCC_UM_LIST) == -1) exitWith {}; 
				if (_ctrlKey) then 
				{
					if !((MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)) in MCC_selectedUnits) then
					{
						MCC_selectedUnits = MCC_selectedUnits + [MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)];
					} 
					else 
					{
						MCC_selectedUnits = MCC_selectedUnits - [MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)];
					};
				} 
				else 
				{
					MCC_selectedUnits = [MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)];
				};
			};
						
			if (MCC_UMUnit==1) then // Groups selection
			{
				if (_ctrlKey && ((lbCurSel MCC_UM_LIST) != -1)) then 
				{
					if !((UMgroupNames select (lbCurSel MCC_UM_LIST)) in MCC_selectedUnits) then
					{
						MCC_selectedUnits = MCC_selectedUnits + [UMgroupNames select (lbCurSel MCC_UM_LIST)];
						lbSetColor [MCC_UM_LIST, (lbCurSel MCC_UM_LIST), [0, 1, 1, 1]];
					} 
					else 
					{
						MCC_selectedUnits = MCC_selectedUnits - [UMgroupNames select (lbCurSel MCC_UM_LIST)];
						lbSetColor [MCC_UM_LIST, (lbCurSel MCC_UM_LIST), [1, 1, 1, 1]];
					};
				}
				else 
				{
					MCC_selectedUnits = [UMgroupNames select (lbCurSel MCC_UM_LIST)];
					for [{_x=0},{_x<(lbSize MCC_UM_LIST)},{_x=_x+1}] do 
					{
						lbSetColor [MCC_UM_LIST, _x, [1, 1, 1, 1]];
					};  //MCC BUG -> missing ;
					lbSetColor [MCC_UM_LIST, (lbCurSel MCC_UM_LIST), [0, 1, 1, 1]];
					//hint format ["%1", MCC_selectedUnits];
				};
			};
		};
		
		case 9:	//HALO
		{
			hint "click on the map to start the Parachute";
			MCC_click = false; 
			onMapSingleClick " 	hint format ['%1 Paradroped', MCC_UMunitsNames];
								MCC_pos = _pos;
								MCC_click = true; 
								onMapSingleClick """";";
			waituntil {MCC_click}; 					
			if (MCC_UMUnit==0) then {
				{
					[[MCC_pos,[netId _x,_x],true,5000,_forEachIndex],"MCC_fnc_paradrop",_x,false] call BIS_fnc_MP;
					sleep 0.5; 
				} foreach MCC_selectedUnits;
					} else {
							{
								{
									[[MCC_pos,[netId _x,_x],true,5000,_forEachIndex],"MCC_fnc_paradrop",_x,false] call BIS_fnc_MP;
									sleep 0.5; 
								} foreach units _x;
							sleep 5;
							} foreach MCC_selectedUnits;
						};
		};
				
		case 10:	//Parachute
		{
			hint "click on the map to start the Parachute";
			MCC_click = false; 
			onMapSingleClick " 	hint format ['%1 Paradroped', MCC_UMunitsNames];
								MCC_pos = _pos;
								MCC_click = true; 
								onMapSingleClick """";";
			waituntil {MCC_click}; 					
			if (MCC_UMUnit==0) then 
			{
				{
					[[MCC_pos,[netId _x,_x],false,800,_forEachIndex],"MCC_fnc_paradrop",_x,false] call BIS_fnc_MP;
					sleep 0.5; 
				} foreach MCC_selectedUnits;
			} 
			else 
			{
				{
					{
						[[MCC_pos,[netId _x,_x],false,800,_forEachIndex],"MCC_fnc_paradrop",_x,false] call BIS_fnc_MP;
						sleep 0.5; 
					} foreach units _x;
				} foreach MCC_selectedUnits;
			};
		};
		
		case 11:	//Broadcast
		{
			hint "Live feed is broadcasting";
			if (MCC_UMUnit==0) then 
				{UMName =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)} 
				else {UMName = leader (UMgroupNames select (lbCurSel MCC_UM_LIST))};
			[[[netid UMName,UMName], MCC_UMPIPView],"MCC_fnc_broadcast",true,false] spawn BIS_fnc_MP;
		};
		
		case 12:	//Delete
		{
			if (MCC_UMUnit==0) then 
				{
					{while {!(isnull _x) && !(isplayer _x)} do {deletevehicle vehicle _x}} foreach MCC_selectedUnits;
					} else {
						{{while {!(isnull _x) && !(isplayer _x)} do {deletevehicle vehicle _x};}foreach units _x} foreach MCC_selectedUnits;
						};
		};
		
		case 13:	//Join
		{
			hint "Click on the unit or group to select it then click on the unit or group you want it to join to"; 
			if (MCC_UMUnit==0) then 
				{
					UMJoin=  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST);
					} else {
						UMJoin = UMgroupNames select (lbCurSel MCC_UM_LIST);
						};
			MCC_UMisJoining = true;
		};
		
		case 14:	//Parachute
		{
			hint "Units paracuted"; 
			if (MCC_UMUnit==0) then 
				{
					{while {!(isnull _x) && !(isplayer _x)} do {deletevehicle vehicle _x}} foreach MCC_selectedUnits;
					} else {
						{while {!(isnull _x) && !(isplayer _x)} do {deletevehicle vehicle _x};}foreach units MCC_selectedUnits;
						};
		};
		
		default //default - no match
		{
			player globalchat format ["Access Denied: type %1", _type];
		};
	};	