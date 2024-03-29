private ["_mccdialog","_comboBox","_displayname","_pic", "_index", "_array", "_class", "_type", "_magazines", "_muzzles", "_cfg", "_count","_string"];
#define ALLGEAR_IDD 8500
#define BOXGEAR_IDD 8501
#define GEARCLASS_IDD 8502
#define MCC_INITBOX 8004 

disableSerialization;

_type = _this select 0;

_mccdialog = uiNamespace getVariable "MCC3D_Dialog";
MCC_gearDialogClassIndex = lbCurSel GEARCLASS_IDD;

if (_type == 0) exitWith 	//Change class
{
	if (isnil "MCC_boxChange") then {MCC_boxChange = false};
	
	if (MCC_boxChange) exitWith {}; 
	MCC_boxChange = !MCC_boxChange;
	
	switch (MCC_gearDialogClassIndex) do 
		{
		case 0: //Binos
			{
			_array = W_BINOS;
			}; 
			
		case 1: //Items
			{
			_array = W_ITEMS;
			};
			
		case 2: //Uniforms
			{
			_array = U_UNIFORM;
			};
			
		case 3: //Launchers
			{
			_array = W_LAUNCHERS;
			};
		
		case 4: //MG
			{
			_array = W_MG;
			};
		
		case 5: //Pistols			
			{
			_array = W_PISTOLS;
			};
			
		case 6: //Rifles			
			{
			_array = W_RIFLES;
			};
		
		case 7: //Sniper Rifles			
			{
			_array = W_SNIPER;
			};
			
		case 8: //Rucks			
			{
			_array = W_RUCKS;
			};
		case 9: //Glasses			
			{
			_array = U_GLASSES;
			};
		case 10: //Magazines			
			{
			_array = U_MAGAZINES;
			};
		case 11: //Under Barrel			
			{
			_array = U_UNDERBARREL;
			};
		case 12: //Grenades		
			{
			_array = U_GRENADE;
			};
		case 13: //Explosive			
			{
			_array = U_EXPLOSIVE;
			};
		};

	_comboBox = _mccdialog displayCtrl ALLGEAR_IDD; 
		lbClear _comboBox;
		{
			_class = _x select 0;
			_displayname = _x select 1;
			_pic = _x select 2;
			_index = _comboBox lbAdd _displayname;
			_comboBox lbSetPicture [_index, _pic];
			_comboBox lbSetData [_index, _class];
		} foreach _array;
	_comboBox lbSetCurSel 0;
	sleep 0.5;
	MCC_boxChange = false; 
};

if (_type == 1) then //Add weapon + mags
{
	_class = lbData [ALLGEAR_IDD, (lbCurSel ALLGEAR_IDD)];
	if (MCC_gearDialogClassIndex > 9) then	{tempBox addMagazineCargo [_class,1]};
	if (MCC_gearDialogClassIndex == 1  || MCC_gearDialogClassIndex == 9 || MCC_gearDialogClassIndex == 2) then	{tempBox addItemCargo [_class,1]};
	if (MCC_gearDialogClassIndex == 8) then	{tempBox addBackpackCargo [_class,1]};
	if ((MCC_gearDialogClassIndex != 1)&& (MCC_gearDialogClassIndex != 2) && (MCC_gearDialogClassIndex < 8))  then
	{
		tempBox addWeaponCargo [_class,1];
		_cfg = configFile >> "CfgWeapons" >> _class;
		_muzzles = getArray (_cfg >> "muzzles");
		_magazines = [];
		if (count _muzzles == 1) then
			{
			_magazines = getArray(_cfg >> "magazines");
			} else
			{
				{
				if (_x == "this") then 
					{
					_magazines = _magazines + getArray(_cfg >> "magazines");
					} else 
					{
					_magazines = _magazines + getArray(_cfg >> _x >> "magazines");
					};
				} forEach _muzzles;
			};
		tempBox addmagazineCargo [_magazines select 0,6];
	};
};

if (_type == 2) then //Add weapon/mag without mags
{
	_class = lbData [ALLGEAR_IDD, (lbCurSel ALLGEAR_IDD)];
	if (MCC_gearDialogClassIndex > 9) then	{tempBox addMagazineCargo [_class,1]};
	if (MCC_gearDialogClassIndex == 1  || MCC_gearDialogClassIndex == 9 || MCC_gearDialogClassIndex == 2) then	{tempBox addItemCargo [_class,1]};
	if (MCC_gearDialogClassIndex == 8) then	{tempBox addBackpackCargo [_class,1]};
	if ((MCC_gearDialogClassIndex != 1)&& (MCC_gearDialogClassIndex != 2) && (MCC_gearDialogClassIndex < 8))  then	{tempBox addWeaponCargo [_class,1]};
};

if (_type == 3) then //Clear
{
	clearMagazineCargo tempBox;
	clearWeaponCargo tempBox;
	clearItemCargo tempBox;
	clearBackpackCargo tempBox;
};	
	
tempBoxWeapons 	= getWeaponCargo tempBox;	//Update box
tempBoxMagazine = getMagazineCargo tempBox;
tempBoxItems	= getItemCargo tempBox;
tempBoxRucks	= getBackpackCargo tempBox;

_count = 0;
_comboBox = _mccdialog displayCtrl BOXGEAR_IDD; 
lbClear _comboBox;
{
	_cfg = configFile >> "CfgWeapons" >> _x;
	_displayname = format ["%2 X %1 ", getText(_cfg >> "displayname"), (tempBoxWeapons select 1) select _count];
	_pic = getText(_cfg >> "picture");
	_index = _comboBox lbAdd _displayname;
	_comboBox lbSetPicture [_index, _pic];
	_count = _count+ 1;
} foreach (tempBoxWeapons select 0);

_count = 0;
{
	_cfg = configFile >> "CfgMagazines" >> _x;
	_displayname = format ["%2 X %1 ", getText(_cfg >> "displayname"), (tempBoxMagazine select 1) select _count];
	_pic = getText(_cfg >> "picture");
	_index = _comboBox lbAdd _displayname;
	_comboBox lbSetPicture [_index, _pic];
	_count = _count+ 1;
} foreach (tempBoxMagazine select 0);
_comboBox lbSetCurSel 0;

_count = 0;
{
	_cfg = configFile >> "CfgWeapons" >> _x;
	_displayname = format ["%2 X %1 ", getText(_cfg >> "displayname"), (tempBoxItems select 1) select _count];
	_pic = getText(_cfg >> "picture");
	_index = _comboBox lbAdd _displayname;
	_comboBox lbSetPicture [_index, _pic];
	_count = _count+ 1;
} foreach (tempBoxItems select 0);
_comboBox lbSetCurSel 0;

_count = 0;
{
	_cfg = configFile >> "CfgVehicles" >> _x;
	_displayname = format ["%2 X %1 ", getText(_cfg >> "displayname"), (tempBoxRucks select 1) select _count];
	_pic = getText(_cfg >> "picture");
	_index = _comboBox lbAdd _displayname;
	_comboBox lbSetPicture [_index, _pic];
	_count = _count+ 1;
} foreach (tempBoxRucks select 0);
_comboBox lbSetCurSel 0;
	

if (_type == 4) then //Generate
{
	_string = ctrlText MCC_INITBOX;
	_string = _string + format [';if (isServer) then {[[_this, %1, %2, %3, %4],"MCC_fnc_boxGenerator",_this,false] spawn BIS_fnc_MP};',tempBoxWeapons, tempBoxMagazine, tempBoxItems, tempBoxRucks];
	ctrlSetText [MCC_INITBOX,_string];
	_null = [1] execVM format["%1mcc\pop_menu\spawn_group3d.sqf",MCC_path];
};
	
