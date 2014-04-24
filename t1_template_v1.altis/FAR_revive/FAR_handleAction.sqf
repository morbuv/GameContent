private ["_params", "_action"];

// Parameters passed by the action
_params = _this select 3;
_action = _params select 0;

////////////////////////////////////////////////
// Handle actions
////////////////////////////////////////////////
if (_action == "action_revive") then
{
	[cursorTarget] spawn FAR_HandleRevive;
};

if (_action == "action_stabilise") then
{
	[cursorTarget] spawn CUP_HandleStabilise;
};

if (_action == "action_suicide") then
{
	player setCaptive false;
	player allowDamage true;
	player enableSimulation true;
	player setDamage 1;
};

if (_action == "action_drag") then
{
	[cursorTarget] spawn FAR_Drag;
};

if (_action == "action_carry") then
{
	[cursorTarget] spawn FAR_Carry;
};

if (_action == "action_release") then
{
	[] spawn FAR_Release;
};

if (_action == "action_load") then
{
	_values = [];
	_values = _params select 1;
	_values spawn FAR_load_in;
};
