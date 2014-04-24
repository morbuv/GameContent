// Farooq's Revive 1.5c 
// (the 'c' is for cupcake)

//------------------------------------------//
// Parameters - Feel free to edit these
//------------------------------------------//

// Seconds until unconscious unit bleeds out and dies. Set to 0 to disable.
FAR_BleedOut = 200 + round (random 125);  

// Enable kill notifications
FAR_EnableDeathMessages = false;

/*
  0 = Only medics can revive
  1 = All units can revive
  2 = Same as 1 but a medikit is required to revive
  3 = Similar to 2. Requires either a FAK or a medikit to revive. If a FAK is used, it is removed from the inventory. (Added by Professor Cupcake)
  4 = Medikit required to revive, but a FAK can stabilise the bleeding. (Added by Professor Cupcake)
*/
FAR_ReviveMode = 4;

// Amount of lives. Set to any negative number to disable. (Added by oh fuck this, you know what? Just whenever you see the prefix 'CUP_', it's stuff I've added, mkay?)
CUP_Lives = 5;
// If you go down more than this many times, you will die instantly, instead of going unconscious. 
// The only way to regain your 'lives' is to die and respawn. 
// Setting this to 0 will effectively disable the revive script altogether. 

// When a unit is revived, they will be set to this amount of damage. 
CUP_ReviveDamage = 0.25;
// This probably goes without saying, but this value should always be less than 1. 

// Sets whether or not a unit may still be damaged while unconscious (thus allowing you to, say, execute a downed enemy)
CUP_AllowDamage = false; //TODO: Test this properly (in MP)
// NOTE: AI will still not attack downed units. 

CUP_ReviveTime = 25;

OLM_hit_handDamageImpact	= 0.1;
OLM_hit_legsDamageImpact	= 0.1;
OLM_hit_bodyDamageImpact	= 0.2;
OLM_hit_headDamageImpact	= 0.3;
OLM_hit_handDamageMaxImpact	= 0.3;
OLM_hit_legsDamageMaxImpact	= 0.5;
OLM_hit_bodyDamageMaxImpact	= 0.9;
OLM_hit_headDamageMaxImpact	= 0.9;


//------------------------------------------//

//call compile preprocessFile format ["%1FAR_revive\FAR_revive_funcs.sqf",MCC_path];
call compileFinal preprocessFileLineNumbers "FAR_revive\FAR_revive_funcs.sqf";

#define SCRIPT_VERSION "1.6"

FAR_isDragging_EH = [];
FAR_carry_EH = [];
FAR_carryDrop_EH = [];
FAR_load_EH = [];
FAR_deathMessage_EH = [];

FAR_isDragging = false;
FAR_Debugging = true;

if (isDedicated) exitWith {};

////////////////////////////////////////////////
// Player Initialization
////////////////////////////////////////////////
[] spawn
{
    waitUntil { !isNull player };

  // Public event handlers
  "FAR_isDragging_EH" addPublicVariableEventHandler FAR_public_EH;
  "FAR_deathMessage_EH" addPublicVariableEventHandler FAR_public_EH;
  "FAR_carry_EH" addPublicVariableEventHandler FAR_public_EH;
  "FAR_carryDrop_EH" addPublicVariableEventHandler FAR_public_EH;
  "FAR_load_EH" addPublicVariableEventHandler FAR_public_EH;
  
  [] spawn FAR_Player_Init;
  
  diag_log format["Farooq's Revive %1 is initialized in mode %2.", SCRIPT_VERSION, FAR_ReviveMode];

  // Event Handlers
  player addEventHandler 
  [
    "Respawn", 
    { 
      [] spawn FAR_Player_Init;
    }
  ];
};

// Drag & Carry animation fix
[] spawn
{
  while {true} do
  {
    if (
			animationState player == "acinpknlmstpsraswrfldnon_acinpercmrunsraswrfldnon" || 
			animationState player == "helper_switchtocarryrfl" ||
			animationState player == "AcinPknlMstpSrasWrflDnon"
		) then
    {
      if (FAR_isDragging) then
      {
        player switchMove "AcinPknlMstpSrasWrflDnon";
      }
      else
      {
        player switchMove "amovpknlmstpsraswrfldnon";
      };
    };
      
    sleep 3;
  }
};

FAR_Player_Init =
{
  // Cache player's side
  FAR_PlayerSide = side player;

  // Clear event handler before adding it
  player removeAllEventHandlers "HandleDamage";

  player addEventHandler ["HandleDamage", FAR_HandleDamage_EH];
  player addEventHandler ["Killed",
							{
							  // Remove dead body of player (for missions with respawn enabled)
							  _body = _this select 0;
							  
							  [_body] spawn 
							  {
								waitUntil { alive player };
								_body = _this select 0;
								deleteVehicle _body;
							  }
							}
						];
  player setVariable ["FAR_isUnconscious", 0, true];
  player setVariable ["FAR_isDragged", 0, true];
  player setVariable ["CUP_isBleeding", 0, true];
  player setVariable ["CUP_lifeCount", 0, true];
  FAR_isDragging = false;
  
  [] spawn FAR_Player_Actions;
};

/*
////////////////////////////////////////////////
// [Debugging] Add revive to playable AI units
////////////////////////////////////////////////
if (!FAR_Debugging || isMultiplayer) exitWith {};

{
  if (!isPlayer _x) then 
  {
    _x addEventHandler ["HandleDamage", FAR_HandleDamage_EH];
    _x setVariable ["FAR_isUnconscious", 0, true];
    _x setVariable ["FAR_isDragged", 0, true];
  };
} forEach switchableUnits;
*/