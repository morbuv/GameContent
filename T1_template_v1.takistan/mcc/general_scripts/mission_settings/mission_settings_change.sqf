//Made by Shay_Gman (c) 09.11
#define missionSettings_IDD 2997

#define RESISTANCE_HOSTILE 8401 
#define T2T_AD 8402
#define AI_SKILL 8403 
#define AI_AIM 8404 
#define AI_SPOT 8405 
#define AI_COMMAND 8406
#define MCC_MSCONSOLEGPS 8407
#define MCC_MSCONSOLESHOWFRIENDS 8408
#define MCC_MSCONSOLECOMMANDAI 8409
#define MCC_IDCNAMETAGS 8410
#define mcc_artilleryTitleIDC 8411
#define mcc_saveGearComboIDC 8412
#define mcc_showGRPMarkerComboIDC 8413
#define mcc_showMessagesComboIDC 8414

private ["_string", "_resistanceHostile", "_AiSkill","_value","_ACEReviveTime","_ACESpectator","_t2t","_code"];
disableSerialization;

if !mcc_isloading then	
{
	_string = "";
	_resistanceHostile = lbCurSel RESISTANCE_HOSTILE;	//Reistance relations
	MCC_resistanceHostileIndex = lbCurSel RESISTANCE_HOSTILE;
	publicvariable "MCC_resistanceHostileIndex";
	
	_t2t = lbCurSel T2T_AD;	//Teleport2Team param
	MCC_t2tIndex = lbCurSel T2T_AD;
	if (_t2t == 0) then {_string = _string + "MCC_teleportToTeam = false;";MCC_teleportToTeam = false; publicvariable "MCC_teleportToTeam";};
	
	switch (_resistanceHostile) do	{
		case 0:	
		{
		_string = _string + "
					resistance setfriend [east, 0];
					resistance setfriend [west, 0];
					east setfriend [resistance, 0];
					west setFriend [resistance, 0];
					";
		};
		
		case 1:	
		{
		_string = _string + "
					resistance setfriend [east, 0];
					resistance setfriend [west, 0.7];
					east setfriend [resistance, 0];
					west setFriend [resistance, 0.7];
					";
		};
		
		case 2:	
		{
		_string = _string + "
				resistance setfriend [east, 0.7];
				resistance setfriend [west, 0];
				east setfriend [resistance, 0.7];
				west setFriend  [resistance, 0];
				";
		};
	};
	
	if (_string != "") then {[[2,compile _string], "MCC_fnc_globalExecute", true, true] spawn BIS_fnc_MP};
	
	_AiSkill = (((lbCurSel AI_SKILL)+1)/10);															//AI Skill
	MCC_aiSkillIndex = lbCurSel AI_SKILL;
	MCC_AI_Skill = _AiSkill; 
	publicvariable "MCC_AI_Skill"; 
	
	//_AiSkill = (((lbCurSel AI_AIM)+1)/10);																//AI_AIM
	_AiSkill = ((((lbCurSel AI_AIM)+1)/100)+0.04);	
	MCC_aiAimIndex = lbCurSel AI_AIM;
	MCC_AI_Aim = _AiSkill; 
	publicvariable "MCC_AI_Aim"; 
	
	_AiSkill = (((lbCurSel AI_SPOT)+1)/10);																//AI Spot
	MCC_aiSpotIndex = lbCurSel AI_SPOT;
	MCC_AI_Spot = _AiSkill; 
	publicvariable "MCC_AI_Spot";
	
	_AiSkill = (((lbCurSel AI_COMMAND)+1)/10);															//AI_COMMAND
	MCC_aiCommandIndex = lbCurSel AI_COMMAND;
	MCC_AI_Command = _AiSkill; 
	publicvariable "MCC_AI_Command"; 
	
	MCC_consoleGPSIndex = lbCurSel MCC_MSCONSOLEGPS;
	MCC_ConsoleOnlyShowUnitsWithGPS = if ((lbCurSel MCC_MSCONSOLEGPS) == 0) then {true} else {false};				//CONSOLE
	publicvariable "MCC_ConsoleOnlyShowUnitsWithGPS";
	
	MCC_consoleShowFriendsIndex = lbCurSel MCC_MSCONSOLESHOWFRIENDS;
	MCC_ConsoleDrawWP = if ((lbCurSel MCC_MSCONSOLESHOWFRIENDS) == 0) then {true} else {false};						//CONSOLE
	publicvariable "MCC_ConsoleDrawWP";
	
	MCC_ConsolePlayersCanSeeWPonMap = if ((lbCurSel MCC_MSCONSOLESHOWFRIENDS) == 0) then {true} else {false};		//CONSOLE
	publicvariable "MCC_ConsolePlayersCanSeeWPonMap";
	
	MCC_consoleCommandAIIndex = lbCurSel MCC_MSCONSOLECOMMANDAI;
	MCC_ConsoleCanCommandAI = if ((lbCurSel MCC_MSCONSOLECOMMANDAI) == 0) then {true} else {false};					//CONSOLE
	publicvariable "MCC_ConsoleCanCommandAI";
	
	MCC_nameTagsIndex = lbCurSel MCC_IDCNAMETAGS;
	MCC_nameTags = if ((lbCurSel MCC_IDCNAMETAGS) == 0) then {false} else {true};									//NameTags
	publicvariable "MCC_nameTags";
	
	MCC_saveGearIndex = lbCurSel mcc_saveGearComboIDC;
	MCC_saveGear = if ((lbCurSel mcc_saveGearComboIDC) == 0) then {false} else {true};								//Save gear EH
	publicvariable "MCC_saveGear";
	
	MCC_groupMarkersIndex = lbCurSel mcc_showGRPMarkerComboIDC;
	MCC_groupMarkers = if ((lbCurSel mcc_showGRPMarkerComboIDC) == 0) then {false} else {true};								//Group Markers
	publicvariable "MCC_groupMarkers";
	
	MCC_MessagesIndex = lbCurSel mcc_showMessagesComboIDC;
	MCC_Chat = if ((lbCurSel mcc_showMessagesComboIDC) == 0) then {false} else {true};								//Group Markers
	publicvariable "MCC_Chat";
	
	MCC_artilleryComputerIndex = lbCurSel mcc_artilleryTitleIDC;
	if ((lbCurSel mcc_artilleryTitleIDC) == 0) then 
	{
		[[2,compile format ["enableEngineArtillery false"]], "MCC_fnc_globalExecute", true, true] spawn BIS_fnc_MP;
	} 
	else		 
	{
		[[2,compile format ["enableEngineArtillery true"]], "MCC_fnc_globalExecute", true, true] spawn BIS_fnc_MP;
	};
	
	
	
	
	Hint "Mission Settings Saved";
    closedialog 0;
};