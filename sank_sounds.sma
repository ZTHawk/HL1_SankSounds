/***************************************************************************
* This plugin reads keyword/wav/mp3 combinations from a configfile and when
* a player says one of the keywords, it will trigger HL to play that Wav/MP3
* file to all or dead/alive players. It allows reloading of the file without
* restarting the current level, as well as adding keyword/wav/mp3
* combinations from the console during gameplay. Also includes banning
* players from playing sounds.
*
* Credits:
*	- Luke Sankey				->	original author
*	- HunteR				->	modifications
*
* Functions included in this plugin:
*	mp_sank_sounds_download	1/0		-	turn internal download system on/off
*	mp_sank_sounds_freezetime <x>		-	x = time in seconds to wait till first sounds are played (connect sound)
*	mp_sank_sounds_obey_duration <x>	-	determine whos sounds may overlap (bit mask) (see readme.txt)
*	amx_sound				-	turn Sank Sounds on/off
*	amx_sound_help				-	prints all available sounds to console
*	amx_sound_play <dir/sound>		-	plays a specific wav/mp3/speech
*	amx_sound_add <keyword> <dir/sound>	-	adds a word/wav/mp3/speech
*	amx_sound_reload <filename>		-	reload your snd-list.cfg or custom .cfg
*	amx_sound_remove <keyword> <dir/sound>	-	remove a word/wav/mp3
*	amx_sound_write <filename>		-	write all settings to custom .cfg
*	amx_sound_reset <player>		-	resets quota for specified player
*	amx_sound_debug				-	prints debugs (debug mode must be on, see define below)
*	amx_sound_ban <player>			-	bans player from using sounds for current map
*	amx_sound_unban <player>		-	unbans player from using sounds for current map
*
* Config file settings:
*	SND_WARN 				- 	The number at which a player will get warned for playing too many sounds each map
*	SND_MAX					-	The number at which a player will get muted for playing too many sounds each map
*	SND_MAX_DUR				-	The maximum amount of seconds a player can play sounds each map (float )
*	SND_JOIN				-	The Sounds to play when a person joins the game
*	SND_EXIT				-	The Sounds to play when a person exits the game
*	SND_DELAY				-	Minimum delay between sounds (float)
*	SND_MODE XX				-	Determinates who can play and who can hear sounds (see readme.txt for details)
*	EXACT_MATCH 1/0				-	Determinates if plugin triggers on exact match, or partial speech match
*	ADMINS_ONLY 1/0				-	Determinates if only admins are allowed to play sounds
*	DISPLAY_KEYWORDS 1/0			-	Determinates if keywords are shown in chat or not
*
* Commands available for each player:
*	amx_sound_help				-	prints all available sounds to console
*	say "/soundson"				-	now the player can hear sounds again
*	say "/soundsoff"			-	player disables ability to hear sounds
*	say "/sounds"				-	shows a list of all sounds
*
* ported to Amx Mod X by White Panther
*
* v1.0.2 (original 4.1 but this is AmxModX):
*	- initial release for AmxModX
*	- renamed commands to fit with AmxModX
*	- Admin sounds cannot be seen by normal people when using amx_sound_help
*	- sounds are precached from file
*	- fix: check if soundfile exist before precache (that should solve some probs)
*	- fix: if chat message was longer than 29 chars the first wav in cfg was played
*
* v1.1.3 :
*	- fixed bug with spaces between keywords and wavs
*	- multiple Join and Exit sounds can now be used
*	- fixed bug where connect and disconnect sound have not been played
*	- fixed bug where dead players could not hear sounds
*	- added bot check
*	- added option to only allow admins to play sounds
*
* v 1.2.4 :
*	- added mp3 support (they have to be in <Mod-Dir>/sound too) (engine module needed therefore) (+ hotfix: wavs not being played)
*	- changed the way of initializing each sound file (if bad file it wont be loaded and error msg will be printed)
*	- changed SND_KICK to SND_MAX
*	- increased default defines ( words: 40 - > 80 / each wavs: 10 -> 14  / file chars: 30 -> 60 )
*	- fixed bug for 32 players
*	- increased memory usage for variables to 64K (should fix probs)
*	- while parsing there is now a check if file exists (if not it wont be put in list)
*
* v1.2.5:
*	- added a cvar to enable or disable auto download (change will take place after restart/mapchange)
*
* v1.3:
*	- fixed:
*		- fixed prob where strings were copied into other strings with no size match
*		- removed bot detection (maybe this was causing some problems, playing sounds to bots does not do any harm)
*		- admin sounds could not be played (eg: hallo; misc/hi.wav;@misc/hi2.wav -> hi2.wav was not played, even by admins)
*	- added:
*		- type "/sounds" in chat to get a MOTD window with all sounds available (not all mods support MOTD window)
*		- ability for speech sounds (like the AmxModX's speechmenu)
*		- admin check to "amx_sound_debug" so in debugmode only admins can use it
*		- list is now sorted by name for more readable output (sort by Bailopan) (sort can be turned off by define)
*
* v1.3.2:
*	- fixed:
*		- mp3 support not working
*	- changed:
*		- mp3 now dont need to be in sound folder but anywhere you want (anywhere in your mod folder though)
*			just specify the correct path (eg: music/mymusic/my.mp3 or sound/testmp3/test.mp3 or mainfolder.mp3)
*		- amx_sound_debug can now also be used if debug mode is off (this function prints the sound matrix)
*
* v1.3.3:
*	- added:
*		- cvar "mp_sank_sounds_freezetime" to define when first connect/disconnect sounds are played after mapchange (in seconds)
*
* v1.3.4:
*	- fixed:
*		- error where some players could not hear any sound
*	- changed:
*		- some log messages got better checks
*		- reimplemented check for bots
*
* v1.3.5:
*	- added:
*		- with "/soundson" and "/soundsoff" each player can activate/deactivate the ability to hear sounds
*
* v1.3.7:
*	- added:
*		- "DISPLAY_KEYWORDS" to config, it determinates if keywords are shown in chat or not
*		- option to load specific sounds only on specific maps
*	- changed:
*		- "SND_DELAY" is now a float
*
* v1.4.0:
*	- added:
*		- option to load packages of sounds, packages cycle with each map-change (packages must be numbered)
*		- ability to ban people from using sounds (only for current map) ( amx_sound_ban <player> <1/0 OR on/off> )
*	- changed:
*		- precache method changed
*		- all keywords are now stored into buffer, even those sounds that are not precached
*		- code improvements
*
* v1.4.1:
*	- fixed:
*		- when setting DISPLAY_KEYWORDS to 0 chat was disabled
*
* v1.4.2:
*	- fixed:
*		- players could be banned from sounds after reconnect
*	- added:
*		- option to include sounds from "half-life.gcf" and <current mod>.gcf
*
* v1.4.2b:
*	- fixed:
*		- compile error when disabling mp3 support
*
* v1.4.3:
*	- fixed:
*		- keywords without or with wrong files will not be added anymore
*		- possible errors fixed
*		- error with MOTD display fixed
*
* v1.4.5:
*	- fixed:
*		- ADMINS_ONLY was not working always
*		- players could only play less sound than specified in SND_MAX
*		- runtime error with amx_sound_reload
*	- added:
*		- sounds can now also be used in team chat
*		- amx_sound_unban to unban players
*	- changed:
*		- keyword check tweaked
*		- amx_sound_ban now do not expect additional parameter "on / off" or "1 / 0"
*
* v1.4.7:
*	- fixed:
*		- keywords with admin and public sounds, could block normal players from playing normal sounds
*		- runtime error which could stop plugin to work
*		- message telling players to wait till next sound can be played is not displayed on every word anymore
*
* v1.5.0: ( AmxModX 1.71 or better ONLY )
*	- fixed:
*		- sounds being not in a subfolder ( eg: sound/mysound.wav ) will now be played
*		- reconnecting to reset quota will not work anymore
*		- no more overlapping sounds ( Join and Exit sounds will still overlap other but others cannot overlap them )
*		- amx_sound_reset now accepts IDs too
*		- sound quota could be increased even if no sound was played
*	- added:
*		- sound duration is now calculated
*	- changed:
*		- SND_DELAY does not affect admins anymore
*		- SND_SPLIT has been replaced with more customizable SND_MODE
*		- removed support to disable MP3
*
* v1.5.0b:
*	- fixed:
*		- rare runtime error
*
* v1.5.1:
*	- fixed:
*		- calculation for MP3's encoded with MPEG 2
*	- added:
*		- saying "/soundlist" will now show sound list like "/sounds" does
*		- CVAR: "mp_sank_sounds_obey_duration" to determine if sounds may overlap or not ( default: 1 = do not overlap )
*
* v1.5.1b:
*	- fixed:
*		- runtime error in mp3 calculation
*
* v1.5.2:
*	- fixed:
*		- support for SND_DELAY was accidently removed
*		- some possible minor bugs
*	- added:
*		- SND_MAX_DUR: maximum of seconds a player can play sounds each map
*		- two new options for SND_MODE ( read help for more information )
*
* v1.5.3:
*	- fixed:
*		- admin being able to play sounds when "mp_sank_sounds_obey_duration" was on
*	- added:
*		- CVAR: "mp_sank_sounds_motd_address" to use a website to show all sounds ( empty cvar = no website will be used )
*
* v1.5.4:
*	- fixed:
*		- error in mp3 calculation
*		- when using "mapnameonly" option, following options have been ignored
*	- added:
*		- minor detection for damaged/invalid files
*	- changed:
*		- both "SND-LIST.CFG" and "snd-list.cfg" will work now ( linux )
*		- code improvements
*		- faster config parsing/writing
*
* v1.5.5:
*	- fixed:
*		- error in mp3 calculation ( once again :( )
*	- added:
*		- additional debug info for mp3's when compiled in DEGUB_MODE 1
*
* v1.5.6:
*	- fixed:
*		- sounds located in <MODDIR>/sounds/ (no subfolder) not being played if dead and alive not being splitted
*		- long lines not being parsed correctly
*		- players could play one more sound than allowed
*
* v1.6.0: (16.4.2007)
*	- fixed:
*		- speech sounds not being played
*		- join / exit sound duration was incorrect
*		- SND_WARN / SND_MAX error checking could display wrong error
*	- added:
*		- access can be defined for every sound and keyword seperately
*	- changed:
*		- partly rewritten
*		- way of saving data
*		- sounds when enabling and disabling Sank Sounds are not precached anymore ( hard coded )
*		- many code improvements
*
* v1.6.2: (16.01.2008)
*	- fixed:
*		- removed debug message
*		- admins are not included in overlapping check anymore
*		- non admins could see sounds that are for admins only
*		- bug when adding and removing sounds ingame to list (wierd keywords and sounds)
*	- added:
*		- "PLAY_COUNT_KEY" and "PLAY_COUNT" to data structure to count how often a key and sound has been used
*		- messages for players when enabling/disabling sounds and if players have to wait cause of delay
*	- changed:
*		- sank sounds is now precaching sounds after plugin init (fakemeta modul needed)
*		- no more engine, but therefore fakemeta is needed
*		- minor code tweaks
*
* v1.6.3: (29.02.2008)
*	- fixed:
*		- runtime error if more sounds added than defined in MAX_KEYWORDS
*		- commenting SND_JOIN and SND_EXIT (adding # or // infront of them) made the following sounds to be added to these options
*	- changed:
*		- CVAR "mp_sank_sounds_obey_duration" is now a bitmask (see readme.txt)
*
* v1.6.4: (21.12.2008)
*	- added:
*		- warning for unsupported mp3 files
*	- changed:
*		- mp3 detection code rewritten
*
* v1.6.5: (14.01.2009)
*	- fixed:
*		- wav detection for bad files
*
* v1.6.5b: (22.01.2009)
*	- changed:
*		- removed warning for unsupported mp3s (they are supported)
*
* v1.6.6: (03.03.2009)
*	- fixed:
*		- last entry in configfile was not sorted
*		- runtime error with keywords without any sound
*		- exploit where SND_JOIN and SND_EXIT could be used as keywords
*	- changed:
*		- SND_JOIN and SND_JOIN do not have to be before any other keyword
*
* v1.6.6b: (29.03.2009)
*	- fixed:
*		- runtime error
*		- if SND_JOIN or SND_JOIN was not at the beginning and more sounds were added afterwards, those new sounds overwrote previous sounds
*
* IMPORTANT:
*	a) if u want to use the internal download system do not use more than 200 sounds (HL cannot handle it)
*		(also depending on map, you may need to use even less)
*		but if u disable the internal download system u can use as many sounds as the plugin can handle
*		(max should be over 100000 sounds (depending on the Array Defines ), BUT the plugin speed
*		is another question with thousands of sounds ;) )
*	
*	b) File has to look like this:
*		SND_MAX;		20
*		SND_MAX_DUR;		180.0
*		SND_WARN;		17
*		SND_JOIN;		misc/hi.wav
*		SND_EXIT;		misc/comeagain.wav
*		SND_DELAY;		0.0
*		SND_MODE;		15
*		EXACT_MATCH;		1
*		ADMINS_ONLY;		0
*		DISPLAY_KEYWORDS;	1
*	
*		# Word/Sound combinations:
*		crap;			misc/awwcrap.Wav;misc/awwcrap2.wav
*		woohoo;			misc/woohoo.wav
*		@ha ha;			misc/haha.wav
*		@abm@godlike;		misc/godlike.wav
*		doh;			misc/doh.wav;misc/doh2.wav;@misc/doh3.wav
*		mp3;			sound/mymp3.mp3;music/mymp3s/number2.mp3;mainfolder.mp3
*		target;			"target destroyed"
*		
*		mapname TESTMAP
*		testmap;		misc/doh.wav
*		mapname TESTMAP2
*		testmap2;		misc/haha.wav;sound/mymp3.mp3
*		testmap3;		misc/hi.wav
*		
*		package 1
*		haha2;			misc/haha.wav
*		doh3;			misc/doh3.wav
*		package 2
*		hi;			misc/hi.wav
*		
*		modspecific
*		<keyword>;		<location>/<name>.wav
*		
*		Follow these instructions
*		wavs:
*			- base directory is "mod-dir/sound/"
*			- put EXACT PATH to the wav beginning from base directory (eg misc/test.wav or test2.wav)
*		mp3:
*			- base directory is "mod-dir/"
*			- put the EXACT PATH to the mp3 (eg sound/test.mp3 or music/mymp3s/test2.mp3 or mainfolder.mp3)
*		speech:
*			- base directory is "mod-dir/sound/vox/"
*			- these files are inside the steam package
*			- for a list look at c)
*		mapname:
*			- type mapname <space> the real mapname (without .bsp)
*			- everthing below will be loaded only on this map
*		package:
*			- type package <space> number
*			- everthing below will be loaded only once and switched to next package on map-change
*			- if only 1 package this package will be used every map-change
*		modspecific:
*			- every sound below that line must be inside half-life.gcf or <yourmod>.gcf
*			- if you add other files then said above they may/will crash your server as these sounds are assumed to be existent
*	
*	c) speech sounds must be put in quotes (eg: target; "target destroyed")
*		you may not put different speech types into 1 speech or the speech wont be played
*		speech without directory is used from "vox/.."
*		first specify the speech type (ONLY ONCE eg hgrunt/) and then put the words with spaces between each speech
*		eg "hgrunt/yessir barney/stop1" will not work as 2 different speeches
*		BUT "hgrunt/yessir no" will work
*		get all available speech sounds here:
*			"http://www.adminmod.org/help/online/Admin_Mod_Reference/Half_Life_Sounds.htm"
*	
*	d) "@" infront of a
*		- word means only admin can use this word
*		- wav/mp3/speech/word means players can use the word but this sound is only played by admins
*
*	e) custom admin access:
*		- infront of a word/sound add @<ACCESS_LEVELS>@
*		- replace <ACCESS_LEVELS> with the access levels you desire
*		- @abc@ means: everyone with access a, b or c can use it
***************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

// set this to 1 to get some debug messages
#define	DEBUG_MODE	0

// turn this off to stop list from being sorted by keywords in alphabetic order
#define	ALLOW_SORT	1

// Array Defines, ATTENTION: ( MAX_RANDOM + 1 ) * TOK_LENGTH must be smaller 2048 !!!
#define MAX_KEYWORDS	80				// Maximum number of keywords ( ATTENTION: 2 are reserved )
#define MAX_RANDOM	15				// Maximum number of sounds per keyword
#define TOK_LENGTH	60				// Maximum length of keyword and sound file strings
#define MAX_BANS	32				// Maximum number of bans stored
#define NUM_PER_LINE	6				// Number of words per line from amx_sound_help
#define BUFFER_LEN	TOK_LENGTH * MAX_RANDOM

//#pragma dynamic 16384
#pragma dynamic 65536

#define ACCESS_ADMIN	ADMIN_LEVEL_A

#define PLUGIN_AUTHOR		"White Panther, Luke Sankey, HunteR"
#define PLUGIN_VERSION		"1.6.6b"

new Enable_Sound[] =	"misc/woohoo.wav"	// Sound played when Sank Soounds being enabled
new Disable_Sound[] =	"misc/awwcrap.wav"	// Sound played when Sank Soounds being disabled

new config_filename[128]

new SndCount[33] = {0, ...}			// Holds the number telling how many sounds a player has played
new Float:SndLenghtCount[33] = {0.0, ...}
new SndOn[33] = {1, ...}

new SND_WARN = 0				// The number at which a player will get warned for playing too many sounds
new SND_MAX = 0					// The number at which a player will get kicked for playing too many sounds
new Float:SND_MAX_DUR = 0.0
new Float:SND_DELAY = 0.0			// Minimum delay between sounds
new SND_MODE = 15				// Determinates who can play and who can hear sounds (dead and alive)
new EXACT_MATCH = 1				// Determinates if plugin triggers on exact match, or partial speech match
new ADMINS_ONLY = 0				// Determinates if only admins are allowed to play sounds
new DISPLAY_KEYWORDS = 1			// Determinates if keywords are shown in chat or not

new Float:NextSoundTime		// spam protection
new Float:Join_exit_SoundTime	// spam protection 2
new Float:LastSoundTime = 0.0
new bSoundsEnabled = 1		// amx_sound <on/off> or <1/0>

new CVAR_freezetime, CVAR_obey_duration

new g_max_players
new banned_player_steamids[MAX_BANS][60]
new restrict_playing_sounds[33]
new sound_quota_steamids[33][60]

new motd_sound_list_address[128]

enum
{
	PARSE_SND_MAX,
	PARSE_SND_MAX_DUR,
	PARSE_SND_WARN,
	PARSE_SND_DELAY,
	PARSE_SND_MODE,
	PARSE_EXACT_MATCH,
	PARSE_ADMINS_ONLY,
	PARSE_DISPLAY_KEYWORDS,
	PARSE_KEYWORD
}

enum
{
	ERROR_NONE,
	ERROR_MAX_KEYWORDS,
	ERROR_STRING_LENGTH
}

enum
{
	FLAG_IGNORE_AMOUNT = 1
}

enum
{
	SOUND_TYPE_SPEECH,
	SOUND_TYPE_MP3,
	SOUND_TYPE_WAV,
	SOUND_TYPE_WAV_NOSUB
}

enum SOUND_DATA_BASE
{
	KEYWORD[TOK_LENGTH],
	ADMIN_LEVEL_BASE,
	SOUND_AMOUNT,
	FLAGS,
	PLAY_COUNT_KEY,
	
	KEY_SOUNDS[BUFFER_LEN],
	Float:DURATION[MAX_RANDOM],
	ADMIN_LEVEL[MAX_RANDOM],
	SOUND_TYPE[MAX_RANDOM],
	PLAY_COUNT[MAX_RANDOM],
	
	SOUND_DATA_BASE_END
}

new sound_data[MAX_KEYWORDS][SOUND_DATA_BASE]

public plugin_init( )
{
	register_plugin("Sank Sounds Plugin", PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_cvar("sanksounds_version", PLUGIN_VERSION, FCVAR_SERVER)
	
	register_concmd("amx_sound_reset", "amx_sound_reset", ACCESS_ADMIN, " <user | all> : Resets sound quota for ^"user^", or everyone if ^"all^"")
	register_concmd("amx_sound_add", "amx_sound_add", ACCESS_ADMIN, " <keyword> <dir/sound> : Adds a Word/Sound combo to the sound list")
	register_clcmd("amx_sound_help", "amx_sound_help")
	register_concmd("amx_sound", "amx_sound", ACCESS_ADMIN, " :  Turns sounds on/off")
	register_concmd("amx_sound_play", "amx_sound_play", ACCESS_ADMIN, " <dir/sound> : Plays sound to all users")
	register_concmd("amx_sound_reload", "amx_sound_reload", ACCESS_ADMIN, " : Reloads config file. Filename is optional. If no filename, default is loaded")
	register_concmd("amx_sound_remove", "amx_sound_remove", ACCESS_ADMIN, " <keyword> <dir/sound> : Removes a Word/Sound combo from the sound list. Must use quotes")
	register_concmd("amx_sound_write", "amx_sound_write", ACCESS_ADMIN, " :  Writes current sound configuration to file")
	register_concmd("amx_sound_debug", "amx_sound_debug", ACCESS_ADMIN, "prints the whole Word/Sound combo list")
	register_concmd("amx_sound_ban", "amx_sound_ban", ACCESS_ADMIN, " <name or #userid>: Bans player from using sounds for current map")
	register_concmd("amx_sound_unban", "amx_sound_unban", ACCESS_ADMIN, " <name or #userid>: Unbans player from using sounds for current map")
	
	register_clcmd("say", "HandleSay")
	register_clcmd("say_team", "HandleSay")
	
	register_cvar("mp_sank_sounds_download", "1")
	CVAR_freezetime = register_cvar("mp_sank_sounds_freezetime", "0")
	CVAR_obey_duration = register_cvar("mp_sank_sounds_obey_duration", "1")
	register_cvar("mp_sank_sounds_motd_address", "")
	
	g_max_players = get_maxplayers()
}

public plugin_cfg( )
{
	get_cvar_string("mp_sank_sounds_motd_address", motd_sound_list_address, 127)
	
	new configpath[61]
	get_configsdir(configpath, 60)
	format(config_filename, 127, "%s/SND-LIST.CFG", configpath)	// Name of file to parse
	
	// check if file in capital letter exists
	// otherwise make it all lowercase and try to load it
	if ( file_exists(config_filename) )
	{
		parse_sound_file(config_filename)
	}else
	{
		strtolower(config_filename)
		parse_sound_file(config_filename)
	}
}

public client_putinserver( id )
{
	restrict_playing_sounds[id] = -1
	
	new steamid[60], i
	get_user_authid(id, steamid, 59)
	for ( i = 0; i < MAX_BANS; ++i )
	{
		if ( equal(steamid, banned_player_steamids[i]) )
			restrict_playing_sounds[id] = i
	}
	
	if ( !equal(steamid, sound_quota_steamids[id]) )
	{
		copy(sound_quota_steamids[id], 59, steamid)
		SndCount[id] = 0
		SndLenghtCount[id] = 0.0
	}
	
	SndOn[id] = 1
	
	new Float:gametime = get_gametime()
	if ( gametime <= get_pcvar_num(CVAR_freezetime) )
		return
	
	if ( sound_data[0][SOUND_AMOUNT] == 0 )
		return
	
	if ( Join_exit_SoundTime >= gametime )
		return
	
	new rand = random(sound_data[0][SOUND_AMOUNT])
	new playFile[TOK_LENGTH]
	copy(playFile, TOK_LENGTH, sound_data[0][KEY_SOUNDS][TOK_LENGTH * rand])
	
	if ( sound_data[0][ADMIN_LEVEL][rand] != 0
		&& !(get_user_flags(id) & sound_data[0][ADMIN_LEVEL][rand]) )
		return
	
	playsoundall(playFile, sound_data[0][SOUND_TYPE][rand])
	
	Join_exit_SoundTime = gametime + sound_data[0][DURATION][rand]
	if ( NextSoundTime < Join_exit_SoundTime )
		NextSoundTime = Join_exit_SoundTime
}

public client_disconnect( id )
{
	SndOn[id] = 1
	restrict_playing_sounds[id] = -1
	
	new Float:gametime = get_gametime()
	if ( gametime <= get_pcvar_num(CVAR_freezetime) )
		return
	
	if ( sound_data[1][SOUND_AMOUNT] == 0 )
		return
	
	if ( Join_exit_SoundTime >= gametime )
		return
	
	new rand = random(sound_data[1][SOUND_AMOUNT])
	new playFile[TOK_LENGTH]
	copy(playFile, TOK_LENGTH, sound_data[1][KEY_SOUNDS][TOK_LENGTH * rand])
	
	if ( sound_data[1][ADMIN_LEVEL][rand] != 0
		&& !(get_user_flags(id) & sound_data[1][ADMIN_LEVEL][rand]) )
		return
		
	playsoundall(playFile, sound_data[1][SOUND_TYPE][rand])
	
	Join_exit_SoundTime = gametime + sound_data[1][DURATION][rand]
	if ( NextSoundTime < Join_exit_SoundTime )
		NextSoundTime = Join_exit_SoundTime
}

public amx_sound_reset( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new arg[33], target
	read_argv(1, arg, 32)
	if ( equal(arg, "all") == 1 )
	{
		client_print(id, print_console, "Sank Sounds >> Quota has been reseted for all players")
		for ( target = 1; target <= g_max_players; ++target )
		{
			SndCount[target] = 0
			SndLenghtCount[target] = 0.0
		}
	}else
	{
		target = cmd_target(id, arg, 1)
		if ( !target )
			return PLUGIN_HANDLED
		
		SndCount[target] = 0
		SndLenghtCount[target] = 0.0
		new name[33]
		get_user_name(target, name, 32)
		client_print(id, print_console, "Sank Sounds >> Quota has been reseted for ^"%s^"", name)
	}
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Adds a Word/Sound combo to the list. If it is a valid line in the config
// file, then it is a valid parameter here. The only difference is you can
// only specify one Sound file at a time with this command.
//
// Usage: amx_sound_add <keyword> <dir/sound>
// Usage: amx_sound_add <setting> <value>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_add( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new Word[TOK_LENGTH + 1], Sound[TOK_LENGTH + 1]
	new configOption = 0
	
	read_argv(1, Word, TOK_LENGTH)
	read_argv(2, Sound, TOK_LENGTH)
	if ( strlen(Word) <= 0
		|| strlen(Sound) == 0 )
	{
		client_print(id, print_console, "Sank Sounds >>Invalid format")
		client_print(id, print_console, "Sank Sounds >>USAGE: amx_sound_add keyword <dir/sound>")
		
		return PLUGIN_HANDLED
	}

	// First look for special parameters
	if ( equali(Word, "SND_MAX") )
	{
		SND_MAX = str_to_num(Sound)
		configOption = 1
	}else if ( equali(Word, "SND_MAX_DUR") )
	{
		SND_MAX_DUR = floatstr(Sound)
		configOption = 1
	}else if ( equali(Word, "SND_WARN") )
	{
		SND_WARN = str_to_num(Sound)
		configOption = 1
	}else if ( equali(Word, "SND_DELAY") )
	{
		SND_DELAY = floatstr(Sound)
		configOption = 1
	}else if ( equali(Word, "SND_MODE") )
	{
		SND_MODE = str_to_num(Sound)
		configOption = 1
	}else if ( equali(Word, "EXACT_MATCH") )
	{
		EXACT_MATCH = str_to_num(Sound)
		configOption = 1
	}else if ( equali(Word, "ADMINS_ONLY") )
	{
		ADMINS_ONLY = str_to_num(Sound)
		configOption = 1
	}else if ( equali(Word, "DISPLAY_KEYWORDS") )
	{
		DISPLAY_KEYWORDS = str_to_num(Sound)
		configOption = 1
	}
	
	if ( configOption )
	{
		// Do some error checking on the user-input numbers
		ErrorCheck()
		
		return PLUGIN_HANDLED
	}
	
	// Loop once for each keyword
	new i, j
	for( i = 0; i < MAX_KEYWORDS; ++i )
	{
		// If an empty string, then break this loop
		if ( strlen(sound_data[i][KEYWORD]) == 0 )
			break
		
		// If no match found, keep looping
		if ( !equal(Word, sound_data[i][KEYWORD], TOK_LENGTH) )
			continue
		
		// See if the Sound already exists
		for( j = 0; j < MAX_RANDOM; ++j )
		{
			// If an empty string, then break this loop
			if ( strlen(sound_data[i][KEY_SOUNDS][TOK_LENGTH * j]) == 0 )
				break

			// See if this is the same as the new Sound
			if ( equali(Sound, sound_data[i][KEY_SOUNDS][TOK_LENGTH * j], TOK_LENGTH) )
			{
				client_print(id, print_console, "Sank Sounds >> ^"%s; %s^" already exists", Word, Sound)
				
				return PLUGIN_HANDLED
			}
		}
		
		// If we reached the end, then there is no room
		if ( j >= MAX_RANDOM - 1 )
			client_print(id, print_console, "Sank Sounds >> No room for new Sound. Increase MAX_RANDOM and recompile")
		else
		{
			// Word exists, but Sound is new to the list, so add entry
			array_add_inner_element(i, j, Sound)
			
			client_print(id, print_console, "Sank Sounds >> ^"%s^" successfully added to ^"%s^"", Sound, Word)
		}
		
		return PLUGIN_HANDLED
	}
	
	// If we reached the end, then there is no room
	if ( i >= MAX_KEYWORDS )
		client_print(id, print_console, "Sank Sounds >> No room for new Word/Sound combo. Increase MAX_KEYWORDS and recompile")
	else
	{
		// Word/Sound combo is new to the list, so make a new entry
		array_add_element(i, Word)
		array_add_inner_element(i, j, Sound)
		
		client_print(id, print_console, "Sank Sounds >> ^"%s; %s^" successfully added", Word, Sound)
	}
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// amx_sound_help lists all amx_sound commands and keywords to the user.
//
// Usage: amx_sound_help
//////////////////////////////////////////////////////////////////////////////
public amx_sound_help( id )
{
	print_sound_list(id)
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Turns on/off the playing of the Sound files for this plugin only
//////////////////////////////////////////////////////////////////////////////
public amx_sound( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new onoff[5]
	read_argv(1, onoff, 4)
	if ( equal(onoff, "on")
		|| equal(onoff, "1") )
	{
		if ( bSoundsEnabled == 1 )
			console_print(id, "Sank Sounds >> Plugin already enabled")
		else
		{
			bSoundsEnabled = 1
			console_print(id, "Sank Sounds >> Plugin enabled")
			client_print(0, print_chat, "Sank Sounds >> Plugin has been enabled")
			if ( Enable_Sound[0] )
			{
				new type = Enable_Sound[0] == '^"' ? SOUND_TYPE_SPEECH : ( Enable_Sound[strlen(Enable_Sound) - 1] == '3' ? SOUND_TYPE_MP3 : ( contain(Enable_Sound, "/") != -1 ? SOUND_TYPE_WAV : SOUND_TYPE_WAV_NOSUB) )
				playsoundall(Enable_Sound, type)
			}
		}
		
		return PLUGIN_HANDLED
	}else if ( equal(onoff, "off")
		|| equal(onoff, "0") )
	{
		if ( bSoundsEnabled == 0 )
			console_print(id, "Sank Sounds >> Plugin already disabled")
		else
		{
			bSoundsEnabled = 0
			console_print(id, "Sank Sounds >> Plugin disabled")
			client_print(0, print_chat, "Sank Sounds >> Plugin has been disabled")
			if ( Disable_Sound[0] )
			{
				new type = Disable_Sound[0] == '^"' ? SOUND_TYPE_SPEECH : ( Disable_Sound[strlen(Disable_Sound) - 1] == '3' ? SOUND_TYPE_MP3 : ( contain(Disable_Sound, "/") != -1 ? SOUND_TYPE_WAV : SOUND_TYPE_WAV_NOSUB) )
				playsoundall(Disable_Sound, type)
			}
		}
	}
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Plays a sound to all players
//
// Usage: amx_sound_play <dir/sound>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_play( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new arg[128]
	read_argv(1, arg, 127)
	
	if ( strlen(arg) < 1 )
	{
		client_print(id, print_console, "Sank Sounds >> Sound is invalid.")
		
		return PLUGIN_HANDLED
	}
	
	new type = arg[0] == '^"' ? SOUND_TYPE_SPEECH : ( arg[strlen(arg) - 1] == '3' ? SOUND_TYPE_MP3 : ( contain(arg, "/") != -1 ? SOUND_TYPE_WAV : SOUND_TYPE_WAV_NOSUB) )
	playsoundall(arg, type)
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Reloads the Word/Sound combos from filename
//
// Usage: amx_sound_reload <filename>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_reload( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 0) )
		return PLUGIN_HANDLED
	
	new parsefile[128]
	read_argv(1, parsefile, 127)
	// Initialize sound_data array
	for( new i = 0; i < MAX_KEYWORDS; ++i )
		array_clear_element(i)
	
	parse_sound_file(parsefile, 0)
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Removes a Word/Sound combo from the list. You must specify a keyword, but it
// is not necessary to specify a Sound if you want to remove all Sounds associated
// with that keyword
//
// Usage: amx_sound_remove <keyWord> <dir/sound>"
//////////////////////////////////////////////////////////////////////////////
public amx_sound_remove( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new Word[TOK_LENGTH + 1], Sound[TOK_LENGTH + 1]
	
	read_argv(1, Word, TOK_LENGTH)
	read_argv(2, Sound, TOK_LENGTH)
	if ( strlen(Word) == 0 )
	{
		client_print(id, print_console, "Sank Sounds >> Invalid format")
		client_print(id, print_console, "Sank Sounds >> USAGE: amx_sound_remove keyword <dir/sound>")
		
		return PLUGIN_HANDLED
	}
	
	// speech must have extra ""
	if ( strlen(Sound) != 0
		&& containi(Sound, ".wav") == -1
		&& containi(Sound, ".mp") == -1 )
		format(Sound, TOK_LENGTH, "^"%s^"", Sound)
	
	// Loop once for each keyWord
	new iCurWord, jCurSound
	for( iCurWord = 0; iCurWord < MAX_KEYWORDS; ++iCurWord )
	{
		// If an empty string, then break this loop, we're at the end
		if ( strlen(sound_data[iCurWord][KEYWORD]) == 0 )
			break
		
		// Look for a Word match
		if ( !equali(Word, sound_data[iCurWord][KEYWORD], TOK_LENGTH) )
			continue
		
		// If no Sound was specified, then remove the whole Word's entry
		if ( strlen(Sound) == 0 )
		{
			// special check for join / exit keywords
			if ( iCurWord < 2 )
			{
				// safe join / exit data
				new temp_char = sound_data[iCurWord][KEYWORD][0]
				new temp_flag = sound_data[iCurWord][FLAGS]
				
				// Delete the last data
				array_clear_element(iCurWord)
				
				// restore data
				sound_data[iCurWord][KEYWORD][0] = temp_char
				sound_data[iCurWord][FLAGS] = temp_flag
				
				// We reached the end
				client_print(id, print_console, "Sank Sounds >> %s successfully cleared", Word)
				
				return PLUGIN_HANDLED
			}
			
			array_remove(iCurWord)
			
			client_print(id, print_console, "Sank Sounds >> %s successfully removed", Word)
			
			return PLUGIN_HANDLED
		}
			
		// Just remove the one Sound, if it exists
		for( jCurSound = 0; jCurSound < MAX_RANDOM; ++jCurSound )
		{
			// If an empty string, then break this loop, we're at the end
			if ( !strlen(sound_data[iCurWord][KEY_SOUNDS][TOK_LENGTH * jCurSound]) )
				break
			
			// Look for a Sound match
			if ( !equali(Sound, sound_data[iCurWord][KEY_SOUNDS][TOK_LENGTH * jCurSound], TOK_LENGTH) )
				continue
			
			if ( sound_data[iCurWord][SOUND_AMOUNT] == 1 )		// If this is the only Sound entry, then remove the entry altogether
			{
				array_remove(iCurWord)
				
				client_print(id, print_console, "Sank Sounds >> %s successfully removed", Word)
			}else
			{
				array_remove_inner(iCurWord, jCurSound)
				
				client_print(id, print_console, "Sank Sounds >> %s successfully removed from %s", Sound, Word)
			}
			
			return PLUGIN_HANDLED
		}
		// We reached the end for this Word, and the Sound didn't exist
		client_print(id, print_console, "Sank Sounds >> %s not found", Sound)
		
		return PLUGIN_HANDLED
	}
	// We reached the end, and the Word didn't exist
	client_print(id, print_console, "Sank Sounds >> %s not found", Word)
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Saves the current configuration of Word/Sound combos to filename for possible
// reloading at a later time. You cannot overwrite the default file.
//
// Usage: amx_sound_write <filename>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_write( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new savefile[128]
	
	read_argv(1, savefile, 127)
	if ( strlen(savefile) == 0 )
	{
		client_print(id, print_console, "Sank Sounds >> You must specify a filename")
		
		return PLUGIN_HANDLED
	}
	
	// disallow to use same filename as the default config_filename
	if ( equali(savefile, config_filename) )
	{
		client_print(id, print_console, "Sank Sounds >> Illegal write to default sound config file")
		client_print(id, print_console, "Sank Sounds >> Specify a different filename")
		
		return PLUGIN_HANDLED
	}
	
	/************ File should have the following format: **************
	# TimeStamp:		07:15:00 Monday January 15, 2001
	# File created by:	[SPU]Crazy_Chevy

	# Important parameters:
	SND_MAX;		20
	SND_MAX_DUR;		180.0
	SND_WARN;		17
	SND_JOIN;		misc/hi.wav
	SND_EXIT;		misc/comeagain.wav
	SND_DELAY;		0.0
	SND_MODE;		15
	EXACT_MATCH;		1
	ADMINS_ONLY;		0
	DISPLAY_KEYWORDS;	1

	# Word/Sound combinations:
	crap;			misc/awwcrap.Wav;misc/awwcrap2.wav
	woohoo;			misc/woohoo.wav
	@ha ha;			misc/haha.wav
	doh;			misc/doh.wav;misc/doh2.wav;@misc/doh3.wav

	******************************************************************/
	
	new TimeStamp[128], name[33], Text[BUFFER_LEN + TOK_LENGTH]
	new Textlen = BUFFER_LEN + TOK_LENGTH - 1
	get_user_name(id, name, 32)
	get_time("%H:%M:%S %A %B %d, %Y", TimeStamp, 127)
	
	new file = fopen(savefile, "w+")
	if ( !file )
	{
		log_amx("Sank Sounds >> Unable to read from ^"%s^" file", savefile)
		
		return PLUGIN_HANDLED
	}
	
	formatex(Text, Textlen, "# TimeStamp:^t^t%s^n", TimeStamp)
	fputs(file, Text)
	formatex(Text, Textlen, "# File created by:^t%s^n", name)
	fputs(file, Text)
	fputs(file, "^n")		// blank line
	fputs(file, "# Important parameters:^n")
	formatex(Text, Textlen, "SND_MAX;^t^t%d^n", SND_MAX)
	fputs(file, Text)
	formatex(Text, Textlen, "SND_MAX_DUR;^t^t%.1f^n", SND_MAX_DUR)
	fputs(file, Text)
	formatex(Text, Textlen, "SND_WARN;^t^t%d^n", SND_WARN)
	fputs(file, Text)
	
	new joinex_snd_buff[BUFFER_LEN]
	cfg_write_keysound(0, joinex_snd_buff, BUFFER_LEN - 1)
	formatex(Text, Textlen, "SND_JOIN;^t^t%s^n", joinex_snd_buff)
	fputs(file, Text)
	joinex_snd_buff[0] = 0
	cfg_write_keysound(1, joinex_snd_buff, BUFFER_LEN - 1)
	formatex(Text, Textlen, "SND_EXIT;^t^t%s^n", joinex_snd_buff)
	fputs(file, Text)
	formatex(Text, Textlen, "SND_DELAY;^t^t%f^n", SND_DELAY)
	fputs(file, Text)
	formatex(Text, Textlen, "SND_MODE;^t^t%d^n", SND_MODE)
	fputs(file, Text)
	formatex(Text, Textlen, "EXACT_MATCH;^t^t%d^n", EXACT_MATCH)
	fputs(file, Text)
	formatex(Text, Textlen, "ADMINS_ONLY;^t^t%d^n", ADMINS_ONLY)
	fputs(file, Text)
	formatex(Text, Textlen, "DISPLAY_KEYWORDS;^t%d^n", DISPLAY_KEYWORDS)
	fputs(file, Text)
	fputs(file, "^n")		// blank line
	fputs(file, "# Word/Sound combinations:^n")
	
	for ( new i = 2; i < MAX_KEYWORDS; ++i )	// first 2 elements are reserved for Join / Exit sounds
	{
		// See if we reached the end
		if ( strlen(sound_data[i][KEYWORD]) == 0 )
			break
		
		cfg_write_keyword(i, Text, Textlen)
		cfg_write_keysound(i, Text, Textlen)
		
		new text_len = strlen(Text)
		if ( text_len + 2 <= BUFFER_LEN )
		{
			Text[text_len] = '^n'	// add new line
			Text[text_len + 1] = 0
		}
		
		// Now write the formatted string to the file
		fputs(file, Text)
		
		// And loop for the next Sound
	}
	
	fclose(file)
	
	client_print(id, print_console, "Sank Sounds >> Configuration successfully written to %s", savefile)
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Prints out Word/Sound combo matrix for debugging purposes. Kinda cool, even
// if you're not really debugging.
//
// Usage: amx_sound_debug
// Usage: amx_sound_reload <filename>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_debug( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 1)
		&& id > 0 )
		return PLUGIN_HANDLED
	
	new i, j, join_snd_buff[BUFFER_LEN], exit_snd_buff[BUFFER_LEN]
	
	if ( !is_dedicated_server()
		&& id == 1 )	// for listenserver and with id = 1 we can use server_print
		id = 0
	
	if ( id )
		client_print(id, print_console, "SND_WARN: %d^nSND_MAX: %d^nSND_MAX_DUR: %5.1f^n", SND_WARN, SND_MAX, SND_MAX_DUR)
	else
		server_print("SND_WARN: %d^nSND_MAX: %d^nSND_MAX_DUR: %5.1f^n", SND_WARN, SND_MAX, SND_MAX_DUR)
	
	for( i = 0; i < MAX_RANDOM; ++i )
	{
		new tempstr[TOK_LENGTH]
		if ( strlen(sound_data[0][KEY_SOUNDS][TOK_LENGTH * i]) )
		{
			formatex(tempstr, TOK_LENGTH, "%s;", sound_data[0][KEY_SOUNDS][TOK_LENGTH * i])
			add(join_snd_buff, BUFFER_LEN, tempstr)
		}
		if ( strlen(sound_data[1][KEY_SOUNDS][TOK_LENGTH * i]) )
		{
			formatex(tempstr, TOK_LENGTH, "%s;", sound_data[1][KEY_SOUNDS][TOK_LENGTH * i])
			add(exit_snd_buff, BUFFER_LEN, tempstr)
		}
	}
	if ( id )
	{
		client_print(id, print_console, "SND_JOIN: %s", join_snd_buff)
		client_print(id, print_console, "SND_EXIT: %s", exit_snd_buff)
		client_print(id, print_console, "SND_DELAY: %f^nSND_MODE: %d^nEXACT_MATCH: %d", SND_DELAY, SND_MODE, EXACT_MATCH)
		client_print(id, print_console, "ADMINS_ONLY: %d^nDISPLAY_KEYWORDS: %d", ADMINS_ONLY, DISPLAY_KEYWORDS)
	}else
	{
		server_print("SND_JOIN: %s^n", join_snd_buff)
		server_print("SND_EXIT: %s^n", exit_snd_buff)
		server_print("SND_DELAY: %f^nSND_MODE: %d^nEXACT_MATCH: %d^n", SND_DELAY, SND_MODE, EXACT_MATCH)
		server_print("ADMINS_ONLY: %d^nDISPLAY_KEYWORDS: %d^n", ADMINS_ONLY, DISPLAY_KEYWORDS)
	}

	// Print out the matrix of sound data, so we got what we think we did
	for( i = 2; i < MAX_KEYWORDS; ++i )	// first 2 elements are reserved for Join / Exit sounds
	{
		if ( strlen(sound_data[i][KEYWORD]) == 0 )
			break
		
		new access_level[32]
		get_flags(sound_data[i][ADMIN_LEVEL_BASE], access_level, 31)
		if ( id )
			client_print(id, print_console, "^n[%d] ^"%s^" with %d sound%s and level ^"%s^" (played: %d)", i - 2, sound_data[i][KEYWORD], sound_data[i][SOUND_AMOUNT], sound_data[i][SOUND_AMOUNT] > 1 ? "s" : "", access_level, sound_data[i][PLAY_COUNT_KEY])
		else
			server_print("^n[%d] ^"%s^" with %d sound%s and level ^"%s^" (played: %d)", i - 2, sound_data[i][KEYWORD], sound_data[i][SOUND_AMOUNT], sound_data[i][SOUND_AMOUNT] > 1 ? "s" : "", access_level, sound_data[i][PLAY_COUNT_KEY])
		for( j = 0; j < MAX_RANDOM; ++j )
		{
			if ( strlen(sound_data[i][KEY_SOUNDS][j * TOK_LENGTH]) == 0 )
				continue
			
			get_flags(sound_data[i][ADMIN_LEVEL][j], access_level, 31)
			if ( id )
				client_print(id, print_console, " ^"%s^" - time: %5.2f - admin level ^"%s^" (played: %d)", sound_data[i][KEY_SOUNDS][j * TOK_LENGTH], sound_data[i][DURATION][j], access_level, sound_data[i][PLAY_COUNT][j])
			else
				server_print(" ^"%s^" - time: %5.2f - admin level ^"%s^" (played: %d)", sound_data[i][KEY_SOUNDS][j * TOK_LENGTH], sound_data[i][DURATION][j], access_level, sound_data[i][PLAY_COUNT][j])
		}
	}
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Bans players from using sounds for current map
//
// Usage: amx_sound_ban <player>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_ban( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new arg[33]
	read_argv(1, arg, 32)
	new player = cmd_target(id, arg, 1)
	if ( !player )
		return PLUGIN_HANDLED
	
	if ( get_user_flags(player) & ACCESS_ADMIN )
		return PLUGIN_HANDLED
	
	if ( restrict_playing_sounds[player] == -1 )
	{
		new found, empty = -1
		new steamid[60]
		get_user_authid(id, steamid, 59)
		for ( new i = 0; i < MAX_BANS; ++i )
		{
			if ( empty == -1
				&& !banned_player_steamids[i][0] )
				empty = i
			
			if ( !equal(steamid, banned_player_steamids[i]) )
				continue
			
			found = 1
			
			break
		}
		if ( !found )
		{
			if ( empty == -1 )
				empty = 0
			
			copy(banned_player_steamids[empty], 59, steamid)
			
			restrict_playing_sounds[player] = empty
		}
	}
	
	new name[33]
	get_user_name(player, name, 32)
	client_print(id, print_console, "Sank Sounds >> Player ^"%s^" has been banned from using sounds", name)
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Unbans players from using sounds for current map
//
// Usage: amx_sound_unban <player>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_unban( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new arg[33]
	read_argv(1, arg, 32)
	new player = cmd_target(id, arg)
	if ( !player )
		return PLUGIN_HANDLED
	
	if ( restrict_playing_sounds[player] != -1 )
	{
		new found = -1
		new steamid[60]
		get_user_authid(id, steamid, 59)
		for ( new i = 0; i < MAX_BANS; ++i )
		{
			if ( !equal(steamid, banned_player_steamids[i]) )
				continue
			
			found = i
			
			break
		}
		if ( found != -1 )
			banned_player_steamids[found][0] = 0
		
		restrict_playing_sounds[player] = -1
	}
	
	new name[33]
	get_user_name(player, name, 32)
	client_print(id, print_console, "Sank Sounds >> Player ^"%s^" has been unbanned from using sounds", name)
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Everything a person says goes through here, and we determine if we want to
// play a sound or not.
//
// Usage: say <anything>
//////////////////////////////////////////////////////////////////////////////
public HandleSay( id )
{
	// If sounds are not enabled, then skip this whole thing
	if ( !bSoundsEnabled )
		return PLUGIN_CONTINUE
	
	// player is banned from playing sounds
	if ( restrict_playing_sounds[id] != -1 )
		return PLUGIN_CONTINUE
	
	new Speech[128]
	read_args(Speech, 127)
	remove_quotes(Speech)
	
	// credit to SR71Goku for fixing this oversight:
	if ( !strlen(Speech) )
		return PLUGIN_CONTINUE
	
	if ( equal(Speech, "/sound", 6) )
	{
		if ( Speech[6] == 's' )
		{
			if ( Speech[7] == 'o'
				&& Speech[8] == 'n' )
			{
				SndOn[id] = 1
				client_print(id, print_chat, "Sank Sounds >> You will hear all sounds again")
			}else if ( Speech[7] == 'o'
				&& Speech[8] == 'f'
				&& Speech[9] == 'f'
				&& Speech[10] == 0 )
			{
				SndOn[id] = 0
				client_print(id, print_chat, "Sank Sounds >> I will stop playing sounds for you")
			}else if ( Speech[7] == 0 )
				print_sound_list(id, 1)
			else
				return PLUGIN_CONTINUE
			
			return PLUGIN_HANDLED
		}else if ( Speech[6] == 'l'
			&& Speech[7] == 'i'
			&& Speech[8] == 's'
			&& Speech[9] == 't'
			&& Speech[10] == 0 )
		{
			print_sound_list(id, 1)
			
			return PLUGIN_HANDLED
		}
		
		return PLUGIN_CONTINUE
	}
	
	new ListIndex = -1
	// Check to see if what the player said is a trigger for a sound
	for ( new i = 2; i < MAX_KEYWORDS; ++i )	// first 2 elements are reserved for Join / Exit sounds
	{
		// end of list reached
		if ( sound_data[i][KEYWORD][0] == 0 )
			break;
		
		if ( equali(Speech, sound_data[i][KEYWORD])
			|| ( EXACT_MATCH == 0
				&& containi(Speech, sound_data[i][KEYWORD]) != -1 ) )
		{
			// check for access
			if ( sound_data[i][ADMIN_LEVEL_BASE] == 0
				|| get_user_flags(id) & sound_data[i][ADMIN_LEVEL_BASE] )
				ListIndex = i
			
			break
		}
	}
	
	// check If player used NO sound trigger
	if ( ListIndex == -1 )
		return PLUGIN_CONTINUE
	
	new obey_duration_mode = get_pcvar_num(CVAR_obey_duration)
	new admin_flags = get_user_flags(id)
	new Float:gametime = get_gametime()
	if ( gametime > NextSoundTime + SND_DELAY			// 1.  check for sound overlapping + delay time
		|| ( admin_flags & ADMIN_RCON				// 2.  check if super admin
			&& !(obey_duration_mode & 4) )			// 2b. check if super admin have to obey duration
		|| ( admin_flags & ACCESS_ADMIN				// 3.  check if admin
			&& !(obey_duration_mode & 2) )			// 3b. check if admin have to obey duration
		|| ( !(obey_duration_mode & 1)				// 4.  check if overlapping is allowed
			&& gametime > LastSoundTime + SND_DELAY ) )	// 4b. or for delay time
	{
		// check if player is allowed to play sounds depending on config
		new alive = is_user_alive(id)
		if ( SND_MODE & ( alive + 1 )
			&& !QuotaExceeded(id) )		// If the user has not exceeded their quota, then play a Sound
		{
			new rand = random(sound_data[ListIndex][SOUND_AMOUNT])
			new timeout
			new playFile[TOK_LENGTH]

			// This for loop runs around until it finds a real file to play
			// Defaults to the first Sound file, if no file is found at random.
			for( timeout = MAX_RANDOM;			// Initial condition
				timeout >= 0 && !strlen(playFile);	// While these are true
				--timeout )				// Update each iteration
			{
				rand = random(sound_data[ListIndex][SOUND_AMOUNT])
				// If for some reason we never find a file
				//  then default to the first Sound entry
				if ( !timeout )
					rand = 0
				
				// check if sound has access defined, if so only allow admins to use it
				if ( sound_data[ListIndex][ADMIN_LEVEL][rand] == 0
					|| ( get_user_flags(id) & sound_data[ListIndex][ADMIN_LEVEL][rand] ) )
					copy(playFile, TOK_LENGTH, sound_data[ListIndex][KEY_SOUNDS][rand * TOK_LENGTH])
			}
			
			if ( playFile[0] )
			{
				NextSoundTime = gametime + sound_data[ListIndex][DURATION][rand]
				
				// Increment their playsound count
				++SndCount[id]
				SndLenghtCount[id] += sound_data[ListIndex][DURATION][rand]
				
				// increment counter
				++sound_data[ListIndex][PLAY_COUNT_KEY]
				++sound_data[ListIndex][PLAY_COUNT][rand]
				
				playsoundall(playFile, sound_data[ListIndex][SOUND_TYPE][rand], SND_MODE & 16, alive)
				
				LastSoundTime = gametime
			}
		}else client_print(id, print_chat, "Sank Sounds >> XXX")
	}else if ( gametime <= NextSoundTime + SND_DELAY
		&& obey_duration_mode != 0 )
		client_print(id, print_chat, "Sank Sounds >> Sound is still playing ( wait %3.1f seconds )", NextSoundTime + SND_DELAY - gametime)
	else
		client_print(id, print_chat, "Sank Sounds >> Do not use sounds too often ( wait %3.1f seconds )", LastSoundTime + SND_DELAY - gametime)
	
	if ( DISPLAY_KEYWORDS == 0 )
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

//////////////////////////////////////////////////////////////////////////////
// Parses the sound file specified by loadfile. If loadfile is empty, then
// it parses the default config_filename.
//////////////////////////////////////////////////////////////////////////////
parse_sound_file( loadfile[] , precache_sounds = 1 )
{
	if ( !strlen(loadfile) )
		copy(loadfile, 127, config_filename)
	
	if ( !file_exists(loadfile) )
	{
		// file does not exist
		log_amx("Sank Sounds >> Cannot find ^"%s^" file", loadfile)
		
		return
	}
	
	new current_package_str[4]
	new current_package, package_num
	if ( vaultdata_exists("sank_sounds_current_package") )
	{
		get_vaultdata("sank_sounds_current_package", current_package_str, 3)
		current_package = str_to_num(current_package_str)
	}
	
	new allowed_to_precache = 1, allow_check_existence = 1, allow_to_use_sounds = 1
	new allow_global_precache = get_cvar_num("mp_sank_sounds_download")
	new mapname[32]
	get_mapname(mapname, 31)
	
	new i
	new ListIndex = -1
	new tmpIndex = -1
	new maxLineBuf_len = ( BUFFER_LEN + TOK_LENGTH ) - 1
	new strLineBuf[BUFFER_LEN + TOK_LENGTH]
		
	new error_code = ERROR_NONE
	new parse_option = PARSE_KEYWORD
	new temp_str[128]
	new check_for_semi
	new position
	
	new file = fopen(loadfile, "r")
	if ( !file )
	{
		log_amx("Sank Sounds >> Unable to read from ^"%s^" file", loadfile)
		
		return
	}
	
	while ( fgets(file, strLineBuf, maxLineBuf_len) )
	{
		if ( (strLineBuf[0] == '^n')						// empty line
			|| ( strLineBuf[0] == 10 && strLineBuf[1] == '^n' )		// empty line
			|| ( strLineBuf[0] == '/' && strLineBuf[1] == '/' )		// comment
			|| (strLineBuf[0] == '#') )					// another comment
			continue
		
		trim(strLineBuf)	// remove newline and spaces
		
		if ( equali(strLineBuf, "package ", 8) )
		{
			++package_num
			if ( current_package )
			{
				if ( current_package == str_to_num(strLineBuf[8]) )
					allowed_to_precache = 1
				else
					allowed_to_precache = 0
			}else
			{
				current_package = 1
				allowed_to_precache = 1
			}
			
			allow_to_use_sounds = 1
			allow_check_existence = 1
			
			continue
		}else if ( equali(strLineBuf, "mapname ", 8) )
		{
			if ( equali(strLineBuf[8], mapname) )
				allowed_to_precache = 1
			else
				allowed_to_precache = 0
			
			allow_to_use_sounds = 1
			allow_check_existence = 1
			
			continue
		}else if ( equali(strLineBuf, "mapnameonly ", 12) )
		{
			if ( equali(strLineBuf[12], mapname) )
			{
				allowed_to_precache = 1
				allow_to_use_sounds = 1
			}else
			{
				allowed_to_precache = 0
				allow_to_use_sounds = 0
			}
			
			allow_check_existence = 1
			
			continue
		}else if ( equali(strLineBuf, "modspecific", 11) )
		{
			allow_to_use_sounds = 1
			allow_check_existence = 0
			
			continue
		}
		
		if ( !allow_to_use_sounds )	// check for sounds that can be used only on specified map
			continue
		
		if ( ListIndex >= MAX_KEYWORDS )
		{
			log_amx("Sank Sounds >> Sound list truncated. Increase MAX_KEYWORDS. Stopped parsing file ^"%s^"^n", loadfile)
			
			break
		}
		
		error_code = ERROR_NONE
		position = 0
		for( i = 0; i < MAX_RANDOM; ++i )
		{
			// check if reached end of buffer ( input has been parsed )
			if ( position >= strlen(strLineBuf) )
			{
				strLineBuf[0] = 0
				break
			}
			
			temp_str[0] = 0		// reset
			check_for_semi = contain(strLineBuf[position], ";")
			if ( check_for_semi != -1 )
			{
				copyc(temp_str, 127, strLineBuf[position], ';')
				position += check_for_semi + 1
			}else
			{
				copy(temp_str, 127, strLineBuf[position])
				position += strlen(temp_str)
			}
			
			// Now remove any spaces or tabs from around the strings -- clean them up
			trim(temp_str)
			
			// check if file length is bigger than array
			if ( strlen(temp_str) > TOK_LENGTH )
			{
				error_code = ERROR_STRING_LENGTH
				
				break
			}
			
			if ( i == 0 )
			{	// first entry is not a sound file
				if ( equali(temp_str, "SND_MAX") )
					parse_option = PARSE_SND_MAX
				else if ( equali(temp_str, "SND_MAX_DUR") )
					parse_option = PARSE_SND_MAX_DUR
				else if ( equali(temp_str, "SND_WARN") )
					parse_option = PARSE_SND_WARN
				else if ( equali(temp_str, "SND_DELAY") )
					parse_option = PARSE_SND_DELAY
				else if ( equali(temp_str, "SND_MODE") )
					parse_option = PARSE_SND_MODE
				else if ( equali(temp_str, "EXACT_MATCH") )
					parse_option = PARSE_EXACT_MATCH
				else if ( equali(temp_str, "ADMINS_ONLY") )
					parse_option = PARSE_ADMINS_ONLY
				else if ( equali(temp_str, "DISPLAY_KEYWORDS") )
					parse_option = PARSE_DISPLAY_KEYWORDS
				else
				{
					parse_option = PARSE_KEYWORD
					if ( ListIndex != -1
						&& sound_data[ListIndex][SOUND_AMOUNT] == 0
						&& !(sound_data[ListIndex][FLAGS] & FLAG_IGNORE_AMOUNT) )	// check if allowed to ignore amount of sounds ( eg: SND_JOIN / SND_EXIT )
						log_amx("Sank Sounds >> Found keyword without any valid sound. Skipping this keyword: ^"%s^"", sound_data[ListIndex][KEYWORD])
					else
						++ListIndex
					
					if ( ListIndex >= MAX_KEYWORDS )
					{
						error_code = ERROR_MAX_KEYWORDS
						
						break
					}
					
					new result = array_add_element(ListIndex, temp_str)
					if ( result > -1 )
					{
						tmpIndex = result
						--ListIndex
					}else
					{
						tmpIndex = -1
						if ( result == -1 )
							ListIndex = 2
					}
				}
			}else
			{
				switch ( parse_option )
				{
					case PARSE_SND_MAX:
					{
						SND_MAX = str_to_num(temp_str)
					}
					case PARSE_SND_MAX_DUR:
					{
						SND_MAX_DUR = floatstr(temp_str)
					}
					case PARSE_SND_WARN:
					{
						SND_WARN = str_to_num(temp_str)
					}
					case PARSE_SND_DELAY:
					{
						SND_DELAY = floatstr(temp_str)
					}
					case PARSE_SND_MODE:
					{
						SND_MODE = str_to_num(temp_str)
					}
					case PARSE_EXACT_MATCH:
					{
						EXACT_MATCH = str_to_num(temp_str)
					}
					case PARSE_ADMINS_ONLY:
					{
						ADMINS_ONLY = str_to_num(temp_str)
					}
					case PARSE_DISPLAY_KEYWORDS:
					{
						DISPLAY_KEYWORDS = str_to_num(temp_str)
					}
					case PARSE_KEYWORD:
					{
						new error_value = -1
						if ( tmpIndex != -1 )
							error_value = array_add_inner_element(tmpIndex, i - 1, temp_str, allow_check_existence, allow_global_precache, precache_sounds, allowed_to_precache)
						else
							error_value = array_add_inner_element(ListIndex, i - 1, temp_str, allow_check_existence, allow_global_precache, precache_sounds, allowed_to_precache)
						if ( error_value == -1 )
						{
							// sound could not be added, so clear that array entry
							if ( tmpIndex != -1 )
								array_clear_inner_element(tmpIndex, i - 1)
							else
								array_clear_inner_element(ListIndex, i - 1)
							
							continue
						}
					}
				}
			}
		}
		
		// Error occured so skip Word/Sound Combo
		if ( error_code == ERROR_MAX_KEYWORDS )
		{
			log_amx("Sank Sounds >> Sound list truncated. Increase MAX_KEYWORDS. Stopped parsing file ^"%s^"^n", loadfile)
			
			break
		}
		
		if ( error_code == ERROR_STRING_LENGTH )
		{
			log_amx("Sank Sounds >> Skipping this word/sound combo. Word or Sound is too long: ^"%s^". Length is %i but max is %i (change name/remove spaces in config or increase TOK_LENGTH)", temp_str, strlen(temp_str), TOK_LENGTH)
			
			continue
		}
		if ( error_code != ERROR_NONE )
		{
			log_amx("Sank Sounds >> Fatal Error")
			
			continue
		}
		
		// If we finished MAX_RANDOM times, and strLineBuf[position] still has contents
		// then we should have a bigger MAX_RANDOM
		else if ( position < strlen(strLineBuf) )
		{
			log_amx("Sank Sounds >> Sound list partially truncated. Increase MAX_RANDOM. Continuing to parse file ^"%s^"^n", loadfile)
		}
	}
	
	fclose(file)
	
	if ( ListIndex != -1 )
	{
		if ( sound_data[ListIndex][SOUND_AMOUNT] == 0
			&& !(sound_data[ListIndex][FLAGS] & FLAG_IGNORE_AMOUNT) )	// check if allowed to ignore amount of sounds ( eg: SND_JOIN / SND_EXIT )
		{
			log_amx("Sank Sounds >> Found keyword without any valid sound. Skipping this keyword: ^"%s^"", sound_data[ListIndex][KEYWORD])
			sound_data[ListIndex][KEYWORD][0] = 0
			--ListIndex
		}
	}
	
	// Now we have all of the data from the text file in our data structures.
	// Next we do some error checking, some setup, and we're done parsing!
	ErrorCheck()
	
	++current_package
	if ( current_package > package_num )
		current_package = 1
	
	num_to_str(current_package, current_package_str, 3)
	set_vaultdata("sank_sounds_current_package", current_package_str)
	
	//++ListIndex
#if ALLOW_SORT == 1
	if ( ListIndex > 1 )
		sort_HeapSort(ListIndex - 1)	// -2 cause first two are reserved for join/exit sounds
#endif
}

//////////////////////////////////////////////////////////////////////////////
// Returns 0 if the user is allowed to say things
// Returns 1 and mutes the user if the quota has been exceeded.
//////////////////////////////////////////////////////////////////////////////
QuotaExceeded( id )
{
	// check if is admin
	new admin_check = ( get_user_flags(id) & ACCESS_ADMIN )
	
	if ( ADMINS_ONLY && !admin_check )
		return 1
	
	// If the sound limitation is disabled, then return happily.
	if ( admin_check )
		return 0
	
	if ( SND_MAX != 0 )
	{
		if ( SndCount[id] >= SND_MAX )
		{
			if ( SndCount[id] - 3 < SND_MAX )
			{
				client_print(id, print_chat, "Sank Sounds >> You were warned, you are muted")
				
				// player is already muted, we increament here to save a variable to protect player from "you are muted" spam ( only 3 warnings )
				++SndCount[id]
			}
			
			return 1
		}else if ( SndCount[id] >= SND_WARN )
			client_print(id, print_chat, "Sank Sounds >> You have %d left before you get muted", SND_MAX - SndCount[id])
	}
	
	if ( SND_MAX_DUR != 0.0
		&& SndLenghtCount[id] > SND_MAX_DUR )
		return 1
	
	return 0
}

//////////////////////////////////////////////////////////////////////////////
// Checks the input variables for invalid values
//////////////////////////////////////////////////////////////////////////////
ErrorCheck( )
{
	// Can't have negative delay between sounds
	if ( SND_DELAY < 0.0 )
	{
		log_amx("Sank Sounds >> SND_DELAY cannot be negative. Setting to value: 0")
		SND_DELAY = 0.0
	}
	
	// If SND_MAX is zero, then sounds quota is disabled. Can't have negative quota
	if ( SND_MAX < 0 )
	{
		SND_MAX = 0	// in case it was negative
		log_amx("Sank Sounds >> SND_MAX cannot be negative. Setting to value: 0")
	}
	
	// If SND_MAX_DUR is zero, then sounds quota is disabled. Can't have negative quota
	if ( SND_MAX_DUR < 0.0 )
	{
		SND_MAX_DUR = 0.0	// in case it was negative
		log_amx("Sank Sounds >> SND_MAX_DUR cannot be negative. Setting to value: 0.0")
	}
	
	// If SND_WARN is zero, then we can't have warning every time a keyword is said,
	// so we default to 3 less than max
	else if ( ( SND_WARN <= 0 && SND_MAX != 0 )
		|| SND_MAX < SND_WARN )
	{
		if ( SND_MAX < SND_WARN  )
			// And finally, if they want to warn after a person has been
			// muted, that's silly, so we'll fix it.
			log_amx("Sank Sounds >> SND_WARN cannot be higher than SND_MAX")
		else if ( SND_WARN <= 0 )
			log_amx("Sank Sounds >> SND_WARN cannot be set to zero")
		
		if ( SND_MAX > 3 )
			SND_WARN = SND_MAX - 3
		else
			SND_WARN = SND_MAX - 1
		
		log_amx("Sank Sounds >> SND_WARN set to default value: %i", SND_WARN)
	}
}

playsoundall( sound[] , type , split_dead_alive = 0 , sender_alive_status = 0 )
{
	new alive
	for( new i = 1; i <= g_max_players; ++i )
	{
		if ( !is_user_connected(i) )
			continue
		
		if ( is_user_bot(i) )
			continue
		
		if ( !SndOn[i] )
			continue
		
		alive = is_user_alive(i)
		if ( !(SND_MODE & ( alive * 4 + 4 )) )
			continue
		
		if ( split_dead_alive
			&& alive != sender_alive_status		// make sure if splited both are in same group
			&& !(SND_MODE & ( alive * 32 + 32 )) )	// OR check if different groups may hear each other
			continue
		
		if ( type == SOUND_TYPE_MP3 )
			client_cmd(i, "mp3 play ^"%s^"", sound)
		else if ( type == SOUND_TYPE_WAV_NOSUB )
			client_cmd(i, "play ^"%s^"", sound)
		else
			client_cmd(i, "spk ^"%s^"", sound)
	}
}

print_sound_list( id , motd_msg = 0 )
{
	new text[256], motd_buffer[2048], ilen, skip_for_loop
	new info_text[64] = "say < keyword >: plays A sound. keYwords are listed Below:"
	if ( strlen(motd_sound_list_address) > 3 )	// make sure at least you have something like: a.b ( http://a.b )
	{
		copy(motd_buffer, 127, motd_sound_list_address)
		skip_for_loop = 1
		motd_msg = 1
	}else if ( motd_msg )
		ilen = format(motd_buffer, 2047, "<body bgcolor=#000000><font color=#FFB000><pre>%s^n", info_text)
	else
		client_print(id, print_console, info_text)
	
	// Loop once for each keyword
	new i, j = -1
	for ( i = 2; i < MAX_KEYWORDS && skip_for_loop == 0; ++i )	// first 2 elements are reserved for Join / Exit sounds
	{
		// If an invalid string, then break this loop
		if ( strlen(sound_data[i][KEYWORD]) == 0
			|| strlen(sound_data[i][KEYWORD]) > TOK_LENGTH )
			break
		
		// check if player can see admin sounds
		++j
		new found_stricted = 0
		if ( sound_data[i][ADMIN_LEVEL_BASE] == 0
			|| get_user_flags(id) & sound_data[i][ADMIN_LEVEL_BASE] )
		{
			if ( motd_msg )
				ilen += format(motd_buffer[ilen], 2047 - ilen, "%s", sound_data[i][KEYWORD])
			else
				add(text, 255, sound_data[i][KEYWORD])
		}else
		{
			--j
			found_stricted = 1
		}
		
		if ( !found_stricted )
		{
			if ( j % NUM_PER_LINE == NUM_PER_LINE - 1 )
			{
				// We got NUM_PER_LINE on this line,
				// so print it and start on the next line
				if ( motd_msg )
					ilen += format(motd_buffer[ilen], 2047 - ilen, "^n")
				else
				{
					client_print(id, print_console, "%s", text)
					text[0] = 0
				}
			}else
			{
				if ( motd_msg )
					ilen += format(motd_buffer[ilen], 2047 - ilen, " | ")
				else
					add(text, 255, " | ")
			}
		}
	}
	if ( motd_msg
		&& strlen(motd_buffer) )
		show_motd(id, motd_buffer)
	else if ( strlen(text) )
		client_print(id, print_console, text)
}

#if ALLOW_SORT == 1
// 4 functions for array sort ( by Bailopan ) ( customized to fit plugin )
sort_HeapSort( ListIndex )
{
	new i
	new aSize = ( ListIndex / 2 ) - 1
	for ( i = aSize; i >= 0; --i )
		sort_SiftDown(i, ListIndex - 1)
	
	for ( i = ListIndex - 1; i >= 1; --i )
	{
		array_switch_elements(0, i)
		sort_SiftDown(0, i - 1)
	}
}

sort_compare( elem1 , elem2 )
{
	// skip first 2 elements ( join / exit )
	elem1 += 2
	elem2 += 2
	
	new i = 0
	for ( i = 0; i < TOK_LENGTH; ++i )
	{
		if ( sound_data[elem1][KEYWORD][i] != sound_data[elem2][KEYWORD][i] )
		{
			if ( sound_data[elem1][KEYWORD][i] > sound_data[elem2][KEYWORD][i] )
				return 1
			
			return -1
		}
	}
	
	return 0
}

sort_SiftDown( root , bottom )
{
	new done, child
	while ( ( root * 2 <= bottom ) && !done )
	{
		if ( root * 2 == bottom )
			child = root * 2
		else if ( sort_compare(root * 2, root * 2 + 1) > 0 )
			child = root * 2
		else
			child = root * 2 + 1
		
		if ( sort_compare(root, child) < 0 )
		{
			array_switch_elements(root, child)
			root = child
		}else
			done = 1
	}
}

array_switch_elements( element_one , element_two )
{
	// skip first 2 elements ( join / exit )
	element_one += 2
	element_two += 2
	
	new i
	new temp_sounds[BUFFER_LEN]
	new temp_keyword[TOK_LENGTH]
	new temp_int, Float:temp_float, temp_access, temp_access_base, temp_type, temp_flags, temp_play_count
	
	copy(temp_keyword, TOK_LENGTH, sound_data[element_one][KEYWORD])
	for ( i = 0; i < BUFFER_LEN; ++i )
		temp_sounds[i] = sound_data[element_one][KEY_SOUNDS][i]
	temp_int = sound_data[element_one][SOUND_AMOUNT]
	temp_access_base = sound_data[element_one][ADMIN_LEVEL_BASE]
	temp_flags = sound_data[element_one][FLAGS]
	temp_play_count = sound_data[element_one][PLAY_COUNT_KEY]
	
	copy(sound_data[element_one][KEYWORD], TOK_LENGTH, sound_data[element_two][KEYWORD])
	for ( i = 0; i < BUFFER_LEN; ++i )
		sound_data[element_one][KEY_SOUNDS][i] = sound_data[element_two][KEY_SOUNDS][i]
	sound_data[element_one][SOUND_AMOUNT] = sound_data[element_two][SOUND_AMOUNT]
	sound_data[element_one][ADMIN_LEVEL_BASE] = sound_data[element_two][ADMIN_LEVEL_BASE]
	sound_data[element_one][FLAGS] = sound_data[element_two][FLAGS]
	sound_data[element_one][PLAY_COUNT_KEY] = sound_data[element_two][PLAY_COUNT_KEY]
	
	copy(sound_data[element_two][KEYWORD], TOK_LENGTH, temp_keyword)
	for ( i = 0; i < BUFFER_LEN; ++i )
		sound_data[element_two][KEY_SOUNDS][i] = temp_sounds[i]
	sound_data[element_two][SOUND_AMOUNT] = temp_int
	sound_data[element_two][ADMIN_LEVEL_BASE] = temp_access_base
	sound_data[element_two][FLAGS] = temp_flags
	sound_data[element_two][PLAY_COUNT_KEY] = temp_play_count
	
	for ( i = 0; i < MAX_RANDOM; ++i )
	{
		temp_float = sound_data[element_one][DURATION][i]
		sound_data[element_one][DURATION][i] = _:sound_data[element_two][DURATION][i]
		sound_data[element_two][DURATION][i] = _:temp_float
		
		temp_access = sound_data[element_one][ADMIN_LEVEL][i]
		sound_data[element_one][ADMIN_LEVEL][i] = sound_data[element_two][ADMIN_LEVEL][i]
		sound_data[element_two][ADMIN_LEVEL][i] = temp_access
		
		temp_type = sound_data[element_one][SOUND_TYPE][i]
		sound_data[element_one][SOUND_TYPE][i] = sound_data[element_two][SOUND_TYPE][i]
		sound_data[element_two][SOUND_TYPE][i] = temp_type
		
		temp_play_count = sound_data[element_one][PLAY_COUNT][i]
		sound_data[element_one][PLAY_COUNT][i] = sound_data[element_two][PLAY_COUNT][i]
		sound_data[element_two][PLAY_COUNT][i] = temp_play_count
	}
}
#endif

array_add_element( num , keyword[] )
{
	new join_check = equali(keyword, "SND_JOIN")
	new exit_check = equali(keyword, "SND_EXIT")
	// if index is 0 or 1 but not the correct keyword then make sure to save in correct array position
	if ( join_check == 0
		&& exit_check == 0 )
	{
		if ( num == 0
			|| num == 1 )
		{
			join_check = -1
			exit_check = -1
			num = 2
		}
	}else
	{
		if ( num > 1 )
		{
			if ( join_check != 0 )
			{
				num = 0
				exit_check = -1
			}else if ( exit_check != 0 )
			{
				num = 1
				join_check = -1
			}
		}
	}
	
	if ( join_check > 0
		|| exit_check > 0 )
		sound_data[num][FLAGS] |= FLAG_IGNORE_AMOUNT
	sound_data[num][ADMIN_LEVEL_BASE] = cfg_parse_access(keyword)
	copy(sound_data[num][KEYWORD], TOK_LENGTH, keyword)
	sound_data[num][PLAY_COUNT_KEY] = 0
	
	return (join_check == -1 && exit_check == -1)
		? -1
		: (join_check == -1 || exit_check == -1)
			? num : -2
}

array_add_inner_element( num , elem , soundfile[] , allow_check_existence = 1 , allow_global_precache = 0 , precache_sounds = 0 , allowed_to_precache = 0 )
{
	sound_data[num][ADMIN_LEVEL][elem] = cfg_parse_access(soundfile)
	sound_data[num][SOUND_TYPE][elem] = soundfile[0] == '^"' ? SOUND_TYPE_SPEECH : ( soundfile[strlen(soundfile) - 1] == '3' ? SOUND_TYPE_MP3 : ( contain(soundfile, "/") != -1 ? SOUND_TYPE_WAV : SOUND_TYPE_WAV_NOSUB ) )
	sound_data[num][PLAY_COUNT][elem] = 0
	
	// check if not speech sounds
	if ( soundfile[0] != '^"' )
	{
		new sound_file_name[TOK_LENGTH + 1 + 10]
		new is_mp3 = ( containi(soundfile, ".mp") != -1 )
		if ( !is_mp3 )
		{	// ".mp3" in not in the string
			formatex(sound_file_name, TOK_LENGTH + 10, "sound/%s", soundfile)
		}else
			copy(sound_file_name, TOK_LENGTH + 10, soundfile)
		
		if ( allow_check_existence )
		{
			if ( !file_exists(sound_file_name) )
			{
				log_amx("Sank Sounds >> Trying to load a file that dont exist. Skipping this file: ^"%s^"", sound_file_name)
				
				return -1
			}
			
			sound_data[num][DURATION][elem] = _:cfg_get_duration(sound_file_name, is_mp3 ? SOUND_TYPE_MP3 : SOUND_TYPE_WAV )
			
			if ( sound_data[num][DURATION][elem] <= 0.0 )
			{
				log_amx("Sank Sounds >> Sound duration is not valid. File is damaged. Skipping this file: ^"%s^"", sound_file_name)
				
				return -1
			}
		}
		
		if ( allow_global_precache
			&& precache_sounds == 1
			&& allowed_to_precache )
		{
			if ( is_mp3 )
				//precache_generic(soundfile)
				engfunc(EngFunc_PrecacheGeneric, soundfile)
			else
				//precache_sound(soundfile)
				engfunc(EngFunc_PrecacheSound, soundfile)
		}
	}
	
	copy(sound_data[num][KEY_SOUNDS][TOK_LENGTH * elem], TOK_LENGTH, soundfile)
	++sound_data[num][SOUND_AMOUNT]
	
	return 1
}

array_clear_element( index )
{
	for ( new i = 0; i < TOK_LENGTH; ++i )
		sound_data[index][KEYWORD][i] = 0
	sound_data[index][SOUND_AMOUNT] = 0
	sound_data[index][ADMIN_LEVEL_BASE] = 0
	sound_data[index][FLAGS] = 0
	sound_data[index][PLAY_COUNT_KEY] = 0
	
	for ( new i = 0; i < MAX_RANDOM; ++i )
		array_clear_inner_element(index, i)
}

array_clear_inner_element( index , elem )
{
	for ( new i = 0; i < TOK_LENGTH; ++i )
		sound_data[index][KEY_SOUNDS][TOK_LENGTH * elem + i] = 0
	sound_data[index][DURATION][elem] = _:0.0
	sound_data[index][ADMIN_LEVEL][elem] = 0
	sound_data[index][SOUND_TYPE][elem] = 0
	sound_data[index][PLAY_COUNT][elem] = 0
}

array_copy_element( dest , source )
{
	copy(sound_data[dest][KEYWORD], TOK_LENGTH, sound_data[source][KEYWORD])
	sound_data[dest][SOUND_AMOUNT] = sound_data[source][SOUND_AMOUNT]
	sound_data[dest][ADMIN_LEVEL_BASE] = sound_data[source][ADMIN_LEVEL_BASE]
	sound_data[dest][FLAGS] = sound_data[source][FLAGS]
	sound_data[dest][PLAY_COUNT_KEY] = sound_data[source][PLAY_COUNT_KEY]
	
	for ( new i = 0; i < MAX_RANDOM; ++i )
		array_copy_inner_elements(dest, i, source, i)
}

array_copy_inner_elements( array1 , elem1 , array2 , elem2 )
{
	copy(sound_data[array1][KEY_SOUNDS][TOK_LENGTH * elem1], TOK_LENGTH, sound_data[array2][KEY_SOUNDS][TOK_LENGTH * elem2])
	sound_data[array1][DURATION][elem1] = _:sound_data[array2][DURATION][elem2]
	sound_data[array1][ADMIN_LEVEL][elem1] = sound_data[array2][ADMIN_LEVEL][elem2]
	sound_data[array1][SOUND_TYPE][elem1] = sound_data[array2][SOUND_TYPE][elem2]
	sound_data[array1][PLAY_COUNT][elem1] = sound_data[array2][PLAY_COUNT][elem2]
}

array_remove( index )
{
	// Keep looping array, copying the next into the current
	for ( ; index < MAX_KEYWORDS; ++index )
	{
		// We are at last List element or there is no succesor
		// so clear it cause we want to remove one element anyway
		if ( index == MAX_KEYWORDS - 1
			|| sound_data[index + 1][KEYWORD][0] == 0 )
		{
			// Delete data
			array_clear_element(index)
			
			// We reached the end
			return
		}
		
		// Copy the next data over the current
		array_copy_element(index, index + 1)
	}
}

array_remove_inner( index , elem )
{
	// we are removing an element, so decrease counter
	--sound_data[index][SOUND_AMOUNT]
	
	for( ; elem < MAX_RANDOM; ++elem )
	{
		// If we're about to copy data that doesn't exist,
		// then just erase the last entry instead of copying
		if ( elem == MAX_RANDOM - 1
			|| sound_data[index][KEY_SOUNDS][TOK_LENGTH * (elem + 1)] == 0 )
		{
			// Delete Sound
			array_clear_inner_element(index, elem)
			
			// We reached the end
			return
		}
		
		// else
		// Copy the next data over the current
		array_copy_inner_elements(index, elem, index, elem + 1)
	}
}

cfg_write_keyword( index , Text[] , Textlen )
{
	Text[0] = 0
	
	if ( sound_data[index][ADMIN_LEVEL_BASE] )
	{
		new access_str[32]
		get_flags(sound_data[index][ADMIN_LEVEL_BASE], access_str, 31)
		formatex(Text, Textlen, "@%s@%s;^t^t", access_str, sound_data[index][KEYWORD])
	}else
		formatex(Text, Textlen, "%s;^t^t", sound_data[index][KEYWORD])
	
}

cfg_write_keysound( index , Text[] , Textlen )
{
	new access_str[32]
	for ( new j = 0; j < MAX_RANDOM && strlen(sound_data[index][KEY_SOUNDS][TOK_LENGTH * j]); ++j )
	{
		if ( sound_data[index][ADMIN_LEVEL][j] )
		{
			get_flags(sound_data[index][ADMIN_LEVEL][j], access_str, 31)
			format(Text, Textlen, "%s@%s@%s;", Text, access_str, sound_data[index][KEY_SOUNDS][TOK_LENGTH * j])
		}else
			format(Text, Textlen, "%s%s;", Text, sound_data[index][KEY_SOUNDS][TOK_LENGTH * j])
	}
}

cfg_parse_access( str[] )
{
	new access_level
	if ( str[0] == '@' )
	{
		new second_at = contain(str[1], "@")
		if ( second_at != -1 )
		{
			new temp_access[32]
			copy(temp_access, second_at, str[1])
			strtolower(temp_access)
			access_level = read_flags(temp_access)
			copy(str, 127, str[second_at + 1 + 1])
		}else
		{
			access_level = ACCESS_ADMIN
			copy(str, 127, str[1])
		}
	}
	
	return access_level
}

Float:cfg_get_duration( sound_file[] , type )
{
	switch ( type )
	{
		case SOUND_TYPE_WAV, SOUND_TYPE_WAV_NOSUB:
		{
			return cfg_get_wav_duration(sound_file)
		}
		case SOUND_TYPE_MP3:
		{
			return cfg_get_mp3_duration(sound_file)
		}
	}
	
	return 0.0
}

Float:cfg_get_wav_duration( wav_file[] )
{
	new file = fopen(wav_file, "rb")
	new dummy_input
	new i
	for ( i = 0; i < 24; ++i )
		dummy_input = fgetc(file)
	
	// 24th byte
	new hertz = fgetc(file)
	// 25th byte
	hertz += fgetc(file) * 256
	// 26th byte
	hertz += fgetc(file) * 256 * 256
	
	for ( i = 27; i < 34; ++i )
		dummy_input = fgetc(file)
	
	// 34th byte
	new bitrate = fgetc(file)
	
	// bytes for data length start right after ascii "data", so search for it
	// normally it is at 35 but also saw at 44, so just in case add bigger search area
	new data_found
	
	do
	{
		dummy_input = fgetc(file)
		if ( dummy_input == 'd' )
			data_found = 1
		else if ( dummy_input == 'a'
			&& data_found == 1 )
			data_found = 2
		else if ( dummy_input == 't'
			&& data_found == 2 )
			data_found = 3
		else if ( dummy_input == 'a'
			&& data_found == 3 )
			data_found = 4
		else
			data_found = 0
	}while ( dummy_input != -1 && data_found < 4 )
	
	if ( dummy_input == -1
		|| hertz <= 0
		|| bitrate <= 0
		|| data_found != 4 )
	{
		fclose(file)
		return 0.0
	}
	
	// 1st byte after data
	new data_length = fgetc(file)
	// 2nd byte after data
	data_length += fgetc(file) * 256
	// 3rd byte after data
	data_length += fgetc(file) * 256 * 256
	// 4th byte after data
	data_length += fgetc(file) * 256 * 256 * 256
	
	fclose(file)
	
	return float(data_length) / ( float(hertz * bitrate) / 8.0 )
}

enum
{
	MP3_MPEG_VERSION_BIT1 = 8,
	MP3_MPEG_VERSION_BIT2 = 16,
	MP3_LAYER_BIT1 = 2,
	MP3_LAYER_BIT2 = 4,
	MP3_PROTECT_BIT = 1,
	
	MP3_BITRATE_BIT1 = 16,
	MP3_BITRATE_BIT2 = 32,
	MP3_BITRATE_BIT3 = 64,
	MP3_BITRATE_BIT4 = 128,
	MP3_BITRATE_INVALID = 15,
	MP3_SAMPLERATE_BIT1 = 4,
	MP3_SAMPLERATE_BIT2 = 8,
	MP3_SAMPLERATE_INVALID = 3,
	MP3_PADDING_BIT = 2,
	MP3_PRIVATE_BIT = 1,
}

// bitrate info
new const bitrate_table[] = {
	//MPEG 2 & 2.5
	0, 32, 48, 56,  64,  80,  96, 112, 128, 144, 160, 176, 192, 224, 256, -1,	// Layer I
	0,  8, 16, 24,  32,  40,  48,  56,  64,  80,  96, 112, 128, 144, 160, -1,	// Layer II
	0,  8, 16, 24,  32,  40,  48,  56,  64,  80,  96, 112, 128, 144, 160, -1,	// Layer III
	//MPEG 1
	0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, -1,	// Layer I
	0, 32, 48, 56,  64,  80,  96, 112, 128, 160, 192, 224, 256, 320, 384, -1,	// Layer II
	0, 32, 40, 48,  56,  64,  80,  96, 112, 128, 160, 192, 224, 256, 320, -1,	// Layer III
}

#if DEBUG_MODE == 1
// frequency info
new const samplingrate_table[] = {
	11025, 12000,  8000, 0,	// MPEG 2.5	// have not seen MPEG 2.5, so UNTESTED
	   -1,    -1,    -1, 0,	// reserved
	22050, 24000, 16000, 0,	// MPEG 2
	44100, 48000, 32000, 0	// MPEG 1
}
#endif

Float:cfg_get_mp3_duration( mp3_file[] )
{
	new file = fopen(mp3_file, "rb")
	new byte, found_header, file_pos
	new byte2
	
	new mpeg_version
	new layer
	new mp3_bitrate
	new mp3_samplerate
	new result = -1
	do
	{
		byte = fgetc(file)
		if ( byte == -1 )
			break
		
		++file_pos
		if ( byte != 255 )
			continue
		
		byte = fgetc(file)
		byte2 = fgetc(file)
		result = verify_header(byte, byte2, mpeg_version, layer, mp3_bitrate, mp3_samplerate)
		if ( result == -1 )
		{
			fseek(file, file_pos, SEEK_SET)
			++file_pos
			continue
		}else
			break
		
		/*++file_pos
		if ( ( byte / 16 ) < 14
			|| byte == 255 )
			continue
		
		//if ( fgetc(file) > 80 )
		//if ( fgetc(file) > 0 )
		//if ( fgetc(file) > 40 )
		if ( fgetc(file) > 16 )
		{
			// header starts with hex: FF YY XX
			// YY must be YY modulo 16 = 15, but NOT equal 255 (mostly it is FB or F3)
			fseek(file, file_pos, SEEK_SET)
			found_header = 1
		}else
			++file_pos*/
	}while ( !found_header && byte != -1 )
	
	fclose(file)
	
	if ( byte == -1 )
		return 0.0
	
	//if ( mp3_bitrate == 2 )
	//	log_amx("Sank Sounds >> ^"%s^" has a samplerate of %iHz. This is not supported by Half Life 1 Engine", mp3_file, samplingrate_table[mpeg_version * 4 + mp3_samplerate])
	
	new mpeg_version_for_bitrate = 0
	if ( mpeg_version == 3 )
		mpeg_version_for_bitrate = 1
	new mp3_bitrate_kbps = bitrate_table[mpeg_version_for_bitrate * ( 3 * 16 ) + ( layer - 1 ) * 16 + mp3_bitrate]
	
#if DEBUG_MODE == 1
	log_amx("Sank Sounds >> DEBUG for file ^"%s^"", mp3_file)
	log_amx("Sank Sounds >> Data bytes = %i / %i", byte, byte2)
	log_amx("Sank Sounds >> Header position = %i", file_pos)
	new mpeg_version_str[10]
	if ( mpeg_version == 0 )
		copy(mpeg_version_str, 9, "MPEG 2.5")
	else if ( mpeg_version == 2 )
		copy(mpeg_version_str, 9, "MPEG 2")
	else if ( mpeg_version == 3 )
		copy(mpeg_version_str, 9, "MPEG 1")
	log_amx("Sank Sounds >> MPEG version = %i / Format: %s", mpeg_version, mpeg_version_str)
	log_amx("Sank Sounds >> Layer = %i", layer)
	log_amx("Sank Sounds >> Bitrate = %iKbps (%i)", mp3_bitrate_kbps, mp3_bitrate)
	
	//mp3_samplerate = samplingrate_table[mpeg_version * 3 + ( byte % 16 ) / 4]
	new mp3_samplerate_hz = samplingrate_table[mpeg_version * 4 + mp3_samplerate]
	
	log_amx("Sank Sounds >> Samplerate = %iHz (%i)", mp3_samplerate_hz, mp3_samplerate)
#endif
	new size_of_file = file_size(mp3_file, 0)
	
	if ( mp3_bitrate_kbps == 0 )
		return 0.0
	
	//song length...
	return float(size_of_file) / ( float(mp3_bitrate_kbps) * 1000.0 ) * 8.0
}

verify_header( header , header2 , &mpeg_version , &layer , &mp3_bitrate , &mp3_samplerate)
{
	// check if first 3 bits set
	if ( header & 0xe0 != 0xe0 )
		return -1
	
	layer = 4
		- ( header & MP3_LAYER_BIT1 ) / MP3_LAYER_BIT1
		+ ( header & MP3_LAYER_BIT2 ) / MP3_LAYER_BIT1
	
	if ( layer != 3 )
		return -1
	
	
	mp3_bitrate = ( header2 & MP3_BITRATE_BIT1 ) / MP3_BITRATE_BIT1
		+ ( header2 & MP3_BITRATE_BIT2 ) / MP3_BITRATE_BIT1
		+ ( header2 & MP3_BITRATE_BIT3 ) / MP3_BITRATE_BIT1
		+ ( header2 & MP3_BITRATE_BIT4 ) / MP3_BITRATE_BIT1
	
	if ( mp3_bitrate & MP3_BITRATE_INVALID == MP3_BITRATE_INVALID )
		return -1
	
	mp3_samplerate = ( header2 & MP3_SAMPLERATE_BIT1 ) / MP3_SAMPLERATE_BIT1
		+ ( header2 & MP3_SAMPLERATE_BIT2 ) / MP3_SAMPLERATE_BIT1
	
	if ( mp3_samplerate & MP3_SAMPLERATE_INVALID == MP3_SAMPLERATE_INVALID )
		return -1
	
	mpeg_version = ( header & MP3_MPEG_VERSION_BIT1 ) / MP3_MPEG_VERSION_BIT1
		+ ( header & MP3_MPEG_VERSION_BIT2 ) / MP3_MPEG_VERSION_BIT1
	
	return 1
}

/*
* plugin_sank_sounds.sma
* Author: Luke Sankey
* Date: March 21, 2001 - Original hard-coded version
* Date: July 2, 2001   - Rewrote to be text file configurable
* Date: November 18, 2001 - Added admin_sound_play command, new variables
*       SND_DELAY, SND_SPLIT and EXACT_MATCH, as well as the ability to
*       have admin-only sounds, like the original version had.
* Date: March 30, 2002 - Now ignores speech of length zero.
* Date: May 30, 2002 - Updated for use with new playerinfo function
* Date: November 12, 2002 - Moved snd-list.cfg file to new location, and
*       made it all lower-case.  Sorry, linux guys, if it confuses you.
*       Added some new ideas from Bill Bateman:
*       1.) added SND_PUNISH and changed SND_KICK to SND_MAX
*       2.) ability to either speak or play sounds
*
* Last Updated: May 12, 2003
*
*
*
* HunteR's modifications:
*	- Players no longer kicked, they are "muted" (no longer able to play sounds)
*	- All sounds are now "spoken" (using the speak command)
*	- As a result, all "\" must become "/"
*	- Ability to reset a player's sound count mid-game
*
* My most deepest thanks goes to William Bateman (aka HunteR)
*  http://thepit.shacknet.nu
*  huntercc@hotmail.com
* For he was the one who got me motivated once again to write this plugin
* since I don't run a server anymore. And besides that, he helped write
* parts of it.
*
* I hope you enjoy this new functionality on the old plugin_sank_sounds
*/