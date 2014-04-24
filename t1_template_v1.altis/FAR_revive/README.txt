Installation
=====================================

Copy FAR_Revive folder into your mission folder. Add this to the top of your init.sqf:

call compileFinal preprocessFileLineNumbers "FAR_revive\FAR_revive_init.sqf";

Features
=====================================

* Revive Modes. 0 = Only medics can revive, 1 = All units can revive, 2 = Same as 1 but a medikit will be required. 0 is default. 2 = Medikit or FAK required, FAKS are consumed. 3 = Medikit required, but FAK can stabilise bleeding. 
* Death messages. Teamkills are shown as "x was injured by y".
* Ability to drag injured units.
* Suicide option which you can use to respawn (if it's enabled) or just to kill yourself.
* Bleedout. If a timeout is specified and you are not revived within the given time you will bleed out and die.

Changelog
=====================================

Cupcake's version
* Added revive modes 2 and 3. 
* Added the option for limited "lives". If you go down too much you'll just die, skipping the "downed" state. 
* Parameter to adjust the damage of someone who has just been revived. 
* Option to allow damage to downed players. 
* Squashed bugs. 

v1.4d
* [NEW] Revive Modes. 0 = Only medics can revive, 1 = All units can revive, 2 = Same as 1 but a Medikit will be required
* [Fixed] Random black screens
* [Fixed] People dying randomly
* Code improvements

v1.4a
* Compatible with latest version of Arma 3
* [NEW] Casual mode. If enabled, all units will be able to revive (not just medics)

v1.4
* [NEW] Identifies medics without class names. You don't have to manually add class names
* [NEW] Bleedout
* [NEW] Death Messages

v1.3a
* [Fixed] Continuous beeping

v1.3
* [Fixed] Revive not working for some medics
* [Fixed] Medic not detected when inside a vehicle

v1.2
* [NEW] Dragging
* [Fixed] Revive not working if you died in a vehicle

v1.1
* Zero division error fixed

v1.0
* Initial version
