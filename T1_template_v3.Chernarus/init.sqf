
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

startLoadingScreen ["Loading Tier1 Mission, please wait..."];

// Check if ASR_AI3 is available
//if !(isClass (configFile >> "cfgPatches">>"asr_ai3_danger")) then
if !( isNil "asr_ai3_sysaiskill_fnc_setUnitSkill" ) then 
{   
	// Run setskill script.
	execVM "Tier1\SetSkill\init_setSkill.sqf";
	diag_log format ["ASR_AI3 mod not found"];    
}
else
{
	// disable potential conflict between ASR and GAIA
	ASR_AI3_sysdanger_reactions = [0,0,0];
};	

endLoadingScreen;

//	Finish world initialization before mission is launched. 
finishMissionInit;

//	The following code is executed after the briefing screen.
sleep 0.5;

//	Client-side scripts.
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
	
	T1_NVG_loop = true;
	[] execVM "Tier1\NVG\T1_NVG_loop.sqf";
};

//	Scripts for all machines.

// Vehicle crew HUD
hud_teamlist = compile preprocessFileLineNumbers ("VehicleHud\hud_teamlist.sqf");
[] spawn hud_teamlist;

//	TPWCAS AI Suppression.
if !(isNil "tpwcas_enable") then 
{
	// enable AI Supression statistics logging (once every 60 seconds)
	if ( (tpwcas_enable == 1) && ( tpwcas_mode == 2 || !(hasInterface) ) ) then
	{
		waitUntil { !(isNil "bdetect_init_done") };
	
		[] spawn tpwcas_fnc_log_benchmark;
	};
};
