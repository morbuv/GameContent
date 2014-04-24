


waitUntil {(!isnil "MCC_AI_Skill") and (!isnil "MCC_AI_Aim") and (!isnil "MCC_AI_Spot") and (!isnil "MCC_AI_Command")};



while {true} do {
	
	sleep 23;
	
	playerIsZeus = false;
	
	if (!isNil "bis_curatorUnit") then {
		if (player == bis_curatorUnit) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor1") then {
		if (player == instructor1) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor2") then {
		if (player == instructor2) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor3") then {
		if (player == instructor3) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor4") then {
		if (player == instructor4) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor5") then {
		if (player == instructor5) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor6") then {
		if (player == instructor6) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor7") then {
		if (player == instructor7) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor8") then {
		if (player == instructor8) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor9") then {
		if (player == instructor9) then {
			playerIsZeus = true;
		};
	};
	if (!isNil "instructor10") then {
		if (player == instructor10) then {
			playerIsZeus = true;
		};
	};
	
	if (playerIsZeus) then {
		
		{
			if (!isPlayer _x) then {
				if (_x skill "general" != MCC_AI_Skill) then {
					_x setskill ["general", MCC_AI_Skill];
				};
				
				if (_x skill "aimingAccuracy" != MCC_AI_Aim) then {
					_x setskill ["aimingAccuracy", MCC_AI_Aim];
					_x setskill ["aimingShake", MCC_AI_Aim];
					_x setskill ["aimingSpeed", MCC_AI_Aim];
				};
				
				if (_x skill "spotDistance" != MCC_AI_Spot) then {
					_x setskill ["spotDistance", MCC_AI_Spot];
					_x setskill ["spotTime", MCC_AI_Spot];
				};
				
				if (_x skill "commanding" != MCC_AI_Command) then {
					_x setskill ["commanding", MCC_AI_Command];
				};
			};
			
			sleep 0.1;
			
		} forEach allUnits;
	};
};