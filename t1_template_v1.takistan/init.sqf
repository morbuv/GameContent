
//	Check mission parameter settings and execute parameter code.
for [ { _i = 0 }, { _i < count(paramsArray) }, { _i = _i + 1 } ] do
{
	_paramName =(configName ((missionConfigFile >> "Params") select _i));
	_paramValue = (paramsArray select _i);
	_paramCode = ( getText (missionConfigFile >> "Params" >> _paramName >> "code"));
		
	diag_log format ["INIT Params: [%1] - [%2] -[%3]", _paramName, _paramCode, _paramValue];
	
	if !( _paramCode == "" ) then 
	{
		_code = format[_paramCode, _paramValue];
		call compile _code;
	};
};

//	Initialize T1 Revive system.
//diag_log format ["T1_Revive: '%1'", T1_Revive];
if ( T1_Revive == 1 ) then
{
	call compile preprocessFile "=BTC=_revive\=BTC=_revive_init.sqf";
} else {
	call compile preprocessFile "FAR_Revive\FAR_revive_init.sqf";
};

startLoadingScreen ["Loading Tier1 Mission, please wait..."];

// Check if ASR_AI3 is available
if (isClass (configFile >> "cfgPatches">>"asr_ai3_danger")) then    
{   
	_asr_ai_va = getArray (configFile>>"cfgPatches">>"asr_ai3_main">>"versionAr");  
	if !(_asr_ai_va select 0 >= 0 && _asr_ai_va select 1 >= 0) then   
	{  
		// Run setskill script.
		execVM "Tier1\SetSkill\init_setSkill.sqf";
		diag_log format ["ASR_AI3 mod not found"];    
	};      
};	

endLoadingScreen;
//player sideChat "End Starting MCC sync...."; 

//	Finish world initialization before mission is launched. 
finishMissionInit;

//	The following code is executed after the briefing screen.
sleep 0.5;

//	Client-side scripts.
//if (!isdedicated) then {
if ( hasInterface ) then 
{	
	//	Add map markers to all player groups.
	[] execVM "Tier1\UnitMarkers\setgroupmarkers.sqf";
	
	//	Disable AI radio chatter.
	player setVariable ["BIS_noCoreConversations", true];
	enableSentences false;
};

// Start garbage collection
if ( (isServer) && (T1_garbageCollection == 1) ) then
{
	[] execVM "Tier1\Garbage\OLM_GCmp_init.sqf"; 
};

//	Scripts for all machines.

// Vehicle crew HUD
hud_teamlist = compile preprocessFileLineNumbers ("VehicleHud\hud_teamlist.sqf");
[] spawn hud_teamlist;

//	TPWCAS AI Suppression.
if !(isNil "tpwcas_enable") then 
{
	if ( tpwcas_enable == 1 ) then
	{
		diag_log format ["%1 - starting TPWCAS_A3 with tpwcas_mode [%2]", time, (tpwcas_mode)];
		[tpwcas_mode] execVM "tpwcas\tpwcas_script_init.sqf";
	};

	// enable AI Supression statistics logging (once every 60 seconds)
	if ( (tpwcas_enable == 1) && ( tpwcas_mode == 2 || !(hasInterface) ) ) then
	{
		waitUntil { !(isNil "bdetect_init_done") };
	
		[] spawn tpwcas_fnc_log_benchmark;
	};
};
