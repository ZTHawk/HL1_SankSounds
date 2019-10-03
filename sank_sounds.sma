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
*	mp_sank_sounds_obey_duration 1/0	-	determine if sounds may overlap or not 1 = do not overlap / 0 = overlap
*	amx_sound				-	turn Sank Sounds on/off
*	amx_sound_help				-	prints all available sounds to console
*	amx_sound_play <dir/wav>		-	plays a specific wav/mp3/speech
*	amx_sound_add <keyword> <dir/wav>	-	adds a word/wav/mp3/speech
*	amx_sound_reload <filename>		-	reload your snd-list.cfg or custom .cfg
*	amx_sound_remove <keyword> <dir/wav>	-	remove a word/wav/mp3
*	amx_sound_write <filename>		-	write all settings to custom .cfg
*	amx_sound_reset <player>		-	resets quota for specified player
*	amx_sound_debug				-	prints debugs (debug mode must be on, see define below)
*	amx_sound_ban <player>			-	bans player from using sounds for current map
*	amx_sound_unban <player>		-	unbans player from using sounds for current map
*
* Config file settings:
*	SND_WARN 				- 	The number at which a player will get warned for playing too many sounds
*	SND_MAX					-	The number at which a player will get muted for playing too many sounds
*	SND_JOIN				-	The Wavs to play when a person joins the game
*	SND_EXIT				-	The Wavs to play when a person exits the game
*	SND_DELAY				-	Minimum delay between sounds (float)
*	SND_MODE XX				-	Determinates who can play and who can hear sounds (dead and alive)
*							choose option below add add them together ( eg: 2 + 8 = 10, means only alive can play and hear sounds )
*							1 = dead can play sounds
*							2 = alive can play sounds
*							4 = dead can hear sounds
*							8 = alive can hear sounds
*							16 = alive and dead are isolated
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
*		- all keywords are now stored into buffer, even of those sounds that are not precached
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
*		- sounds beiing not in a subfolder ( eg: sound/mysound.wav ) will now be played
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
*		- runtime error on mp3 calculation
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
*		SND_WARN;		17
*		SND_JOIN;		misc/hi.wav
*		SND_EXIT;		misc/comeagain.wav
*		SND_DELAY;		0.0
*		SND_MODE;		15
*		EXACT_MATCH;		1
*		ADMINS_ONLY;		0
*		DISPLAY_KEYWORDS;	1
*	
*		# Word/Wav combinations:
*		crap;			misc/awwcrap.Wav;misc/awwcrap2.wav
*		woohoo;			misc/woohoo.wav
*		@ha ha;			misc/haha.wav
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
*		- wav/mp3/speech-word means players can use the word but this wav is only played by admins
***************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <engine>	// backwards campatability, amxX 1.75 does not need it anymore

// set this to 1 to get some debug messages
#define	DEBUG	0

// turn this off to stop list from being sorted by keywords in alphabetic order
#define	ALLOW_SORT	1

// Array Defines, ATTENTION: ( MAX_RANDOM + 1 ) * TOK_LENGTH < 2048 !!!
#define MAX_KEYWORDS	80				// Maximum number of keywords
#define MAX_RANDOM	15				// Maximum number of wavs per keyword
#define TOK_LENGTH	60				// Maximum length of keyword and wav/mp3 file strings
#define MAX_BANS	32				// Maximum number of bans stored
#define NUM_PER_LINE	6				// Number of words per line from amx_sound_help

//#pragma dynamic 16384
#pragma dynamic 65536

#define ACCESS_ADMIN	ADMIN_LEVEL_A

new Enable_Sound[] =	"misc/woohoo.wav"		// Sound played when Sank Soounds enabled
new Disable_Sound[] =	"misc/awwcrap.wav"		// Sound played when Sank Soounds disabled

new plugin_author[] = "White Panther, Luke Sankey, HunteR"
new plugin_version[] = "1.5.1b"

new FILENAME[128]

new SndCount[33] = {0, ...}			// Holds the number telling how many sounds a player has played
new SndOn[33] = {1, ...}

new SND_WARN = 0				// The number at which a player will get warned for playing too many sounds
new SND_MAX = 0					// The number at which a player will get kicked for playing too many sounds
new Join_wavs[TOK_LENGTH * MAX_RANDOM]		// The Wavs to play when a person joins the game
new Float:Join_sound_duration[MAX_RANDOM]
new Exit_wavs[TOK_LENGTH * MAX_RANDOM]		// The Wavs to play when a person exits the game
new Float:Exit_sound_duration[MAX_RANDOM]
new Join_snd_num, Exit_snd_num			// Number of join and exit Wavs
new Float:SND_DELAY = 0.0			// Minimum delay between sounds
new SND_MODE = 15				// Determinates who can play and who can hear sounds (dead and alive)
new EXACT_MATCH = 1				// Determinates if plugin triggers on exact match, or partial speech match
new ADMINS_ONLY = 0				// Determinates if only admins are allowed to play sounds
new DISPLAY_KEYWORDS = 1			// Determinates if keywords are shown in chat or not

new WordWavCombo[MAX_KEYWORDS][TOK_LENGTH * ( MAX_RANDOM + 1 )]
new Float:Sound_duration[MAX_KEYWORDS][MAX_RANDOM + 1]
new soundnum_for_keyword[MAX_KEYWORDS]

new Float:NextSoundTime		// spam protection
new Float:Join_exit_SoundTime	// spam protection 2
new bSoundsEnabled = 1		// amx_sound <on/off> or <1/0>

new CVAR_freezetime, CVAR_obey_duration

new g_max_players
new banned_player_steamids[MAX_BANS][60]
new restrict_playing_sounds[33]
new sound_quota_steamids[33][60]

public plugin_init( )
{
	register_plugin("Sank Sounds Plugin", plugin_version, plugin_author)
	register_cvar("sanksounds_version", plugin_version, FCVAR_SERVER)
	register_concmd("amx_sound_reset", "amx_sound_reset", ACCESS_ADMIN, " <user | all> : Resets sound quota for ^"user^", or everyone if ^"all^"")
	register_concmd("amx_sound_add", "amx_sound_add", ACCESS_ADMIN, " <keyword> <dir/wav> : Adds a Word/Wav combo to the sound list")
	register_clcmd("amx_sound_help", "amx_sound_help")
	register_concmd("amx_sound", "amx_sound", ACCESS_ADMIN, " :  Turns sounds on/off")
	register_concmd("amx_sound_play", "amx_sound_play", ACCESS_ADMIN, " <dir/wav> : Plays sound to all users")
	register_concmd("amx_sound_reload", "amx_sound_reload", ACCESS_ADMIN, " : Reloads config file. Filename is optional. If no filename, default is loaded")
	register_concmd("amx_sound_remove", "amx_sound_remove", ACCESS_ADMIN, " <keyword> <dir/wav> : Removes a Word/Wav combo from the sound list. Must use quotes")
	register_concmd("amx_sound_write", "amx_sound_write", ACCESS_ADMIN, " :  Writes current sound configuration to file")
	register_concmd("amx_sound_debug", "amx_sound_print_matrix", ACCESS_ADMIN, "prints the whole Word/Wav combo list")
	register_concmd("amx_sound_ban", "amx_sound_ban", ACCESS_ADMIN, " <name or #userid>: Bans player from using sounds for current map")
	register_concmd("amx_sound_unban", "amx_sound_unban", ACCESS_ADMIN, " <name or #userid>: Unbans player from using sounds for current map")
	register_clcmd("say", "HandleSay")
	register_clcmd("say_team", "HandleSay")
	
	register_cvar("mp_sank_sounds_download", "1")
	CVAR_freezetime = register_cvar("mp_sank_sounds_freezetime", "0")
	CVAR_obey_duration = register_cvar("mp_sank_sounds_obey_duration", "1")
	
	g_max_players = get_maxplayers()
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
	}
}

public client_connect( id )
{
	new Float:gametime = get_gametime()
	if ( gametime > get_pcvar_num(CVAR_freezetime) )
	{
		if ( Join_snd_num )
		{
			if ( Join_exit_SoundTime < gametime )
			{
				new a = random(Join_snd_num)
				new playFile[TOK_LENGTH]
				copy(playFile, TOK_LENGTH, Join_wavs[TOK_LENGTH * a])
				playsoundall(playFile)
				
				Join_exit_SoundTime = gametime + Join_sound_duration[a]
				if ( NextSoundTime < Join_exit_SoundTime )
					NextSoundTime = Join_exit_SoundTime
			}
		}
	}
	SndOn[id] = 1
}

public client_disconnect( id )
{
	new Float:gametime = get_gametime()
	if ( gametime > get_pcvar_num(CVAR_freezetime) )
	{
		if ( Exit_snd_num )
		{
			if ( Join_exit_SoundTime < gametime )
			{
				new a = random(Exit_snd_num)
				new playFile[TOK_LENGTH]
				copy(playFile, TOK_LENGTH, Exit_wavs[TOK_LENGTH * a])
				playsoundall(playFile)
				
				Join_exit_SoundTime = gametime + Exit_sound_duration[a]
				if ( NextSoundTime < Join_exit_SoundTime )
					NextSoundTime = Join_exit_SoundTime
			}
		}
	}
	SndOn[id] = 1
	restrict_playing_sounds[id] = -1
}

public plugin_precache( )
{
	new configpath[61]
	get_configsdir(configpath, 60)
	format(FILENAME, 127, "%s/SND-LIST.CFG", configpath)	// Name of file to parse
	parse_sound_file(FILENAME)
	
	new file_name[128]
	format(file_name, 127, "sound/%s", Enable_Sound)
	if ( file_exists(file_name) )
		precache_sound(Enable_Sound)
	else
		Enable_Sound[0] = 0
	
	format(file_name, 127, "sound/%s", Disable_Sound)
	if ( file_exists(file_name) )
		precache_sound(Disable_Sound)
	else
		Disable_Sound[0] = 0
}

public amx_sound_reset( id , level , cid )
{
	if ( cmd_access(id, level, cid, 2) )
	{
		new arg[33], i
		read_argv(1, arg, 32)
		if ( equal(arg, "all") == 1 )
		{
			client_print(id, print_console, "Sank Sounds >> Quota has been reseted for all players")
			for ( i = 1; i <= g_max_players; ++i )
				SndCount[i] = 0
		}else
		{
			i = cmd_target(id, arg, 1)
			if ( !i )
				return PLUGIN_HANDLED
			
			SndCount[i] = 0
			new name[33]
			get_user_name(i, name, 32)
			client_print(id, print_console, "Sank Sounds >> Quota has been reseted for ^"%s^"", name)
		}
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Adds a Word/Wav combo to the list. If it is a valid line in the config
// file, then it is a valid parameter here. The only difference is you can
// only specify one .Wav file at a time with this command.
//
// Usage: admin_sound_add <keyword> <dir/wav>
// Usage: admin_sound_add <setting> <value>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_add( id , level , cid )
{
	if ( cmd_access(id, level, cid, 2) )
	{
		new Word[TOK_LENGTH + 1], Wav[TOK_LENGTH + 1]
		new bGotOne = 0
		new joinex
		
		read_argv(1, Word, TOK_LENGTH)
		read_argv(2, Wav, TOK_LENGTH)
		if( strlen(Word) == 0 || strlen(Wav) == 0 )
		{
			client_print(id, print_console, "Sank Sounds >>Invalid format")
			client_print(id, print_console, "Sank Sounds >>USAGE: amx_sound_add keyword <dir/wav>")
			return PLUGIN_HANDLED
		}
	
		// First look for special parameters
		if ( equali(Word, "SND_MAX") )
		{
			SND_MAX = str_to_num(Wav)
			bGotOne = 1
		}else if ( equali(Word, "SND_WARN") )
		{
			SND_WARN = str_to_num(Wav)
			bGotOne = 1
		}else if ( equali(Word, "SND_JOIN") )
		{
			joinex = 1
		}else if ( equali(Word, "SND_EXIT") )
		{
			joinex = 2
		}else if ( equali(Word, "SND_DELAY") )
		{
			//SND_DELAY = str_to_num(Wav)
			SND_DELAY = floatstr(Wav)
			bGotOne = 1
		}else if ( equali(Word, "SND_MODE") )
			SND_MODE = str_to_num(Wav)
		else if ( equali(Word, "EXACT_MATCH") )
			EXACT_MATCH = str_to_num(Wav)
		else if ( equali(Word, "ADMINS_ONLY") )
			ADMINS_ONLY = str_to_num(Wav)
		else if ( equali(Word, "DISPLAY_KEYWORDS") )
			DISPLAY_KEYWORDS = str_to_num(Wav)
		
		if ( bGotOne )
		{
			// Do some error checking on the user-input numbers
			ErrorCheck()
			return PLUGIN_HANDLED
		}
		
		// check if is a speech
		new found_speech
		if ( containi(Wav, ".wav") == -1 && containi(Wav, ".mp") == -1 )
		{
			found_speech = 1
			format(Wav, TOK_LENGTH, "^"%s^"", Wav)
		}
		
		// check if the file to be added exists (speech always exists, or at least dont need to be precached)
		if ( !found_speech )
		{
			new file_name[TOK_LENGTH + 1]
			copy(file_name, TOK_LENGTH, Wav)
			replace(file_name, TOK_LENGTH, "@", "")
			format(file_name, TOK_LENGTH, "sound/%s", file_name)
			if ( !file_exists(file_name) )
			{
				log_amx("Sank Sounds >> Trying to add a file that dont exist. Not adding this file: ^"%s^"", file_name)
				return PLUGIN_HANDLED
			}
		}
		
		// Loop once for each keyword
		new i
		for( i = 0; i < MAX_KEYWORDS; ++i )
		{
			// If an empty string, then break this loop
			if( strlen(WordWavCombo[i]) == 0 )
				break
			// If we find a match, then add on the new Wav data
			if( equal(Word, WordWavCombo[i], TOK_LENGTH) || joinex )
			{
				// See if the Wav already exists
				new j
				for( j = 1; j < MAX_RANDOM; ++j )
				{
					if ( joinex == 1)
					{
						// If an empty string, then break this loop
						if ( strlen(Join_wavs[TOK_LENGTH * ( j - 1 )]) == 0 )
							break
						
						else if( equali(Wav, Join_wavs[TOK_LENGTH * ( j - 1 )], TOK_LENGTH) )
						{
							client_print(id, print_console, "Sank Sounds >> ^"%s^" already exists in SND_JOIN", Wav)
							return PLUGIN_HANDLED
						}
					}else if ( joinex == 2 )
					{
						// If an empty string, then break this loop
						if ( strlen(Exit_wavs[TOK_LENGTH * ( j - 1 )]) == 0 )
							break
						
						else if( equali(Wav, Exit_wavs[TOK_LENGTH * ( j - 1 )], TOK_LENGTH) )
						{
							client_print(id, print_console, "Sank Sounds >> ^"%s^" already exists in SND_EXIT", Wav)
							return PLUGIN_HANDLED
						}
					}else
					{
						// If an empty string, then break this loop
						if ( strlen(WordWavCombo[i][TOK_LENGTH * j]) == 0 )
							break
		
						// See if this is the same as the new Wav
						if( equali(Wav, WordWavCombo[i][TOK_LENGTH * j], TOK_LENGTH) )
						{
							client_print(id, print_console, "Sank Sounds >> ^"%s; %s^" already exists", Word, Wav)
							return PLUGIN_HANDLED
						}
					}
				}
	
				// If we reached the end, then there is no room
				if( j >= MAX_RANDOM )
					client_print(id, print_console, "Sank Sounds >> No room for new Wav. Increase MAX_RANDOM and recompile")
				else
				{
					// Word exists, but Wav is new to the list, so add entry
					if ( joinex == 1)
						copy(Join_wavs[TOK_LENGTH * j], TOK_LENGTH, Wav)
					else if ( joinex == 2)
						copy(WordWavCombo[i][TOK_LENGTH * j], TOK_LENGTH, Wav)
					else
						copy(WordWavCombo[i][TOK_LENGTH * j], TOK_LENGTH, Wav)
					
					client_print(id, print_console, "Sank Sounds >> ^"%s^" successfully added to ^"%s^"", Wav, Word)
				}
				return PLUGIN_HANDLED
			}
		}
		// If we reached the end, then there is no room
		if( i >= MAX_KEYWORDS )
			client_print(id, print_console, "Sank Sounds >> No room for new Word/Wav combo. Increase MAX_KEYWORDS and recompile")
		else
		{
			// Word/Wav combo is new to the list, so make a new entry
			copy(WordWavCombo[i][TOK_LENGTH * 0], TOK_LENGTH, Word)
			copy(WordWavCombo[i][TOK_LENGTH * 1], TOK_LENGTH, Wav)
			client_print(id, print_console, "Sank Sounds >> ^"%s; %s^" successfully added", Word, Wav)
		}
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
// Turns on/off the playing of the Wav files for this plugin only
//////////////////////////////////////////////////////////////////////////////
public amx_sound( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new onoff[5]
	read_argv(1, onoff, 4)
	if ( equal(onoff, "on") || equal(onoff, "1") )
	{
		if ( bSoundsEnabled == 1 )
			console_print(id, "Sank Sounds >> Plugin already enabled")
		else
		{
			bSoundsEnabled = 1
			console_print(id, "Sank Sounds >> Plugin enabled")
			client_print(0, print_chat, "Sank Sounds >> Plugin has been enabled")
			if ( Enable_Sound[0] )
				playsoundall(Enable_Sound)
		}
		return PLUGIN_HANDLED
	}else if ( equal(onoff, "off") || equal(onoff, "0") )
	{
		if ( bSoundsEnabled == 0 )
			console_print(id, "Sank Sounds >> Plugin already disabled")
		else
		{
			bSoundsEnabled = 0
			console_print(id, "Sank Sounds >> Plugin disabled")
			client_print(0, print_chat, "Sank Sounds >> Plugin has been disabled")
			if ( Disable_Sound[0] )
				playsoundall(Disable_Sound)
		}
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Plays a sound to all players
//
// Usage: admin_sound_play <dir/wav>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_play( id , level , cid )
{
	if ( cmd_access(id, level, cid, 2) )
	{
		new arg[128]
		read_argv(1, arg, 127)
		playsoundall(arg)
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Reloads the Word/Wav combos from filename
//
// Usage: admin_sound_reload <filename>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_reload( id , level , cid )
{
	if ( cmd_access(id, level, cid, 0) )
	{
		new parsefile[128]
		read_argv(1, parsefile, 127)
		// Initialize WordWavCombo[][][] array
		new i
		for( i = 0; i < MAX_KEYWORDS; ++i )
			WordWavCombo[i][0] = 0
		Join_wavs[0] = 0
		Exit_wavs[0] = 0
		
		parse_sound_file(parsefile, 0)
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Removes a Word/Wav combo from the list. You must specify a keyword, but it
// is not necessary to specify a Wav if you want to remove all Wavs associated
// with that keyword
//
// Usage: admin_sound_remove <keyWord> <dir/wav>"
//////////////////////////////////////////////////////////////////////////////
public amx_sound_remove( id , level , cid )
{
	if ( cmd_access(id, level, cid, 2) )
	{
		new Word[TOK_LENGTH + 1], Wav[TOK_LENGTH + 1]
		
		read_argv(1, Word, TOK_LENGTH)
		read_argv(2, Wav, TOK_LENGTH)
		if( strlen(Word) == 0 )
		{
			client_print(id, print_console, "Sank Sounds >> Invalid format")
			client_print(id, print_console, "Sank Sounds >> USAGE: admin_sound_remove keyword <dir/wav>")
			return PLUGIN_HANDLED
		}
		
		// Loop once for each keyWord
		new iCurWord
		for( iCurWord = 0; iCurWord < MAX_KEYWORDS + 2; ++iCurWord )
		{
			// If an empty string, then break this loop, we're at the end
			if( strlen(WordWavCombo[iCurWord]) == 0 )
				break
			// Look for a Word match
			new jCurWav
			new joinex
			if ( equali(Word, "SND_JOIN", TOK_LENGTH) )
				joinex = 1
			else if ( equali(Word, "SND_EXIT", TOK_LENGTH) )
				joinex = 2
			if( equali(Word, WordWavCombo[iCurWord], TOK_LENGTH) || joinex )
			{
				// If no Wav was specified, then remove the whole Word's entry
				if( strlen(Wav) == 0 ){
					if ( joinex == 1 )
					{
						Join_wavs[0] = 0
						client_print(id, print_console, "Sank Sounds >> Successfully removed wavs from %s", Word)
						return PLUGIN_HANDLED
					}else if ( joinex == 2 )
					{
						Exit_wavs[0] = 0
						client_print(id, print_console, "Sank Sounds >> Successfully removed wavs from %s", Word)
						return PLUGIN_HANDLED
					}else
					{
						// Keep looping i, copying the next into the current
						for(; iCurWord < MAX_KEYWORDS; ++iCurWord )
						{
							// If we're about to copy a string that doesn't exist,
							//  then just erase the last string instead of copying.
							if ( iCurWord >= MAX_KEYWORDS - 1 )
							{
								// Delete the last Word string
								WordWavCombo[iCurWord][0] = 0
								// We reached the end
								client_print(id, print_console, "Sank Sounds >> %s successfully removed", Word)
								return PLUGIN_HANDLED
							}else
							{
								// Copy the next string over the current string
								for( jCurWav = 0; jCurWav < TOK_LENGTH * (MAX_RANDOM + 1); ++jCurWav )
									WordWavCombo[iCurWord][jCurWav] = WordWavCombo[iCurWord + 1][jCurWav]
							}
						}
					}
				}else
				{
					// Just remove the one Wav, if it exists
					for( jCurWav = 1; jCurWav <= MAX_RANDOM; ++jCurWav )
					{
						// If an empty string, then break this loop, we're at the end
						if ( joinex == 1 ){
							if ( !strlen(Join_wavs[TOK_LENGTH * ( jCurWav - 1 )]) )
								break
						}else if ( joinex == 2 )
						{
							if ( !strlen(Exit_wavs[TOK_LENGTH * ( jCurWav - 1 )]) )
								break
						}else if ( !strlen(WordWavCombo[iCurWord][TOK_LENGTH * jCurWav]) )
							break
						
						// speech must have extra ""
						if ( containi(Wav, ".wav") == -1 && containi(Wav, ".mp") == -1 )
							format(Wav, TOK_LENGTH, "^"%s^"", Wav)
						
						// Look for a Wav match
						if ( equali(Wav, WordWavCombo[iCurWord][TOK_LENGTH * jCurWav], TOK_LENGTH) || ( joinex && ( equali(Wav, Join_wavs[TOK_LENGTH * ( jCurWav - 1 )], TOK_LENGTH) || equali(Wav, Exit_wavs[TOK_LENGTH * ( jCurWav - 1 )], TOK_LENGTH) ) ) )
						{
							for(; jCurWav <= MAX_RANDOM; ++jCurWav )
							{
								if ( !joinex )
								{
									// If this is the only Wav entry, then remove the entry altogether
									if ( jCurWav == 1 && !strlen(WordWavCombo[iCurWord][TOK_LENGTH * ( jCurWav + 1 )]) )
									{
										// Keep looping i, copying the next into the current
										for(; iCurWord < MAX_KEYWORDS; ++iCurWord )
										{
											// If we're about to copy a string that doesn't exist,
											//  then just erase the last string instead of copying.
											if ( iCurWord >= MAX_KEYWORDS - 1 )
											{
												// Delete the last Word string
												WordWavCombo[iCurWord][0] = 0
												// We reached the end
												client_print(id, print_console, "Sank Sounds >> %s successfully removed", Word)
												return PLUGIN_HANDLED
											}else
											{
												// Copy the next string over the current string
												for( jCurWav = 0; jCurWav < TOK_LENGTH * (MAX_RANDOM + 1); ++jCurWav )
													WordWavCombo[iCurWord][jCurWav] = WordWavCombo[iCurWord + 1][jCurWav]
											}
										}
									}
								}
								// If we're about to copy a string that doesn't exist,
								// then just erase the last string instead of copying.
								if( jCurWav >= MAX_RANDOM )
								{
									// Delete the last Wav string
									if ( joinex == 1 )
										Join_wavs[TOK_LENGTH * ( jCurWav - 1 )] = 0
									else if ( joinex == 2 )
										Exit_wavs[TOK_LENGTH * ( jCurWav - 1 )] = 0
									else
										WordWavCombo[iCurWord][TOK_LENGTH * jCurWav] = 0
									// We reached the end
									client_print(id, print_console, "Sank Sounds >> %s successfully removed from %s", Wav, Word)
									return PLUGIN_HANDLED
								}else
								{
									// Copy the next string over the current string
									if ( joinex == 1 )
										copy(Join_wavs[TOK_LENGTH * ( jCurWav - 1 )], TOK_LENGTH, Join_wavs[TOK_LENGTH * jCurWav])
									else if ( joinex == 2 )
										copy(Exit_wavs[TOK_LENGTH * ( jCurWav - 1 )], TOK_LENGTH, Exit_wavs[TOK_LENGTH * jCurWav])
									else
										copy(WordWavCombo[iCurWord][TOK_LENGTH * jCurWav], TOK_LENGTH, WordWavCombo[iCurWord][TOK_LENGTH * ( jCurWav + 1 )])
								}
							}
						}
					}
					// We reached the end for this Word, and the Wav didn't exist
					client_print(id, print_console, "Sank Sounds >> %s not found", Wav)
					return PLUGIN_HANDLED
				}
			}
		}
		// We reached the end, and the Word didn't exist
		client_print(id, print_console, "Sank Sounds >> %s not found", Word)
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Saves the current configuration of Word/Wav combos to filename for possible
// reloading at a later time. You cannot overwrite the default file.
//
// Usage: admin_sound_write <filename>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_write( id , level , cid )
{
	if ( cmd_access(id,level,cid,2) )
	{
		new savefile[128]
		
		read_argv(1, savefile, 127)
		// If the filename is NULL, then that's bad
		if ( strlen(savefile) == 0 )
		{
			client_print(id, print_console, "Sank Sounds >> You must specify a filename")
			return PLUGIN_HANDLED
		}
		// If the filename is the same as the default FILENAME, then that's bad
		if ( equali(savefile, FILENAME) )
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
		SND_WARN;		17
		SND_JOIN;		misc/hi.wav
		SND_EXIT;		misc/comeagain.wav
		SND_DELAY;		0.0
		SND_MODE;		15
		EXACT_MATCH;		1
		ADMINS_ONLY;		0
		DISPLAY_KEYWORDS;	1
	
		# Word/Wav combinations:
		crap;			misc/awwcrap.Wav;misc/awwcrap2.wav
		woohoo;			misc/woohoo.wav
		@ha ha;			misc/haha.wav
		doh;			misc/doh.wav;misc/doh2.wav;@misc/doh3.wav
	
		******************************************************************/
		
		new TimeStamp[128], name[33], Text[TOK_LENGTH * ( MAX_RANDOM + 1 )]
		new bSuccess = 1
		get_user_name(id, name, 32)
		get_time("%H:%M:%S %A %B %d, %Y", TimeStamp, 127)
		
		format(Text, 127, "# TimeStamp:^t^t%s", TimeStamp)
		write_file(savefile, Text)
		format(Text, 127, "# File created by:^t%s", name)
		write_file(savefile, Text)
		write_file(savefile, "")		// blank line
		write_file(savefile, "# Important parameters:")
		format(Text, 127, "SND_MAX;^t^t%d", SND_MAX)
		write_file(savefile, Text)
		format(Text, 127, "SND_WARN;^t^t%d", SND_WARN)
		write_file(savefile, Text)
		
		new join_snd_buff[TOK_LENGTH * MAX_RANDOM], exit_snd_buff[TOK_LENGTH * MAX_RANDOM]
		new i
		for( i = 0; i < MAX_RANDOM; ++i )
		{
			new tempstr[TOK_LENGTH]
			if ( strlen(Join_wavs[TOK_LENGTH * i]) )
			{
				format(tempstr, TOK_LENGTH, "%s;", Join_wavs[TOK_LENGTH * i])
				add(join_snd_buff[MAX_RANDOM * i], TOK_LENGTH, tempstr)
			}
			if ( strlen(Exit_wavs[TOK_LENGTH * i]) )
			{
				format(tempstr, TOK_LENGTH, "%s;", Exit_wavs[TOK_LENGTH * i])
				add(exit_snd_buff[MAX_RANDOM * i], TOK_LENGTH, tempstr)
			}
		}
		format(Text, 127, "SND_JOIN;^t^t%s", join_snd_buff)
		write_file(savefile, Text)
		format(Text, 127, "SND_EXIT;^t^t%s", exit_snd_buff)
		write_file(savefile, Text)
		format(Text, 127, "SND_DELAY;^t^t%f", SND_DELAY)
		write_file(savefile, Text)
		format(Text, 127, "SND_MODE;^t^t%d", SND_MODE)
		write_file(savefile, Text)
		format(Text, 127, "EXACT_MATCH;^t^t%d", EXACT_MATCH)
		write_file(savefile, Text)
		format(Text, 127, "ADMINS_ONLY;^t^t%d", ADMINS_ONLY)
		write_file(savefile, Text)
		format(Text, 127, "DISPLAY_KEYWORDS;^t^t%d", DISPLAY_KEYWORDS)
		write_file(savefile, Text)
		write_file(savefile, "")		// blank line
		write_file(savefile, "# Word/Wav combinations:")
		
		for ( i = 0; i < MAX_KEYWORDS && bSuccess; ++i )
		{
			// See if we reached the end
			if ( strlen(WordWavCombo[i]) == 0 )
				break
			
			// First, add the keyWord
			format(Text, TOK_LENGTH * MAX_RANDOM, "%s;^t^t^t", WordWavCombo[i])
			// Then add all the Wavs
			new j
			for ( j = 1; j < MAX_RANDOM && strlen(WordWavCombo[i][TOK_LENGTH * j]); ++j )
				format(Text, TOK_LENGTH * MAX_RANDOM, "%s%s;", Text, WordWavCombo[i][TOK_LENGTH * j])
			
			// Now write the formatted string to the file
			bSuccess = write_file(savefile, Text)
			// And loop for the next Wav
		}
	
		client_print(id, print_console, "Sank Sounds >> Configuration successfully written to %s", savefile)
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Prints out Word Wav combo matrix for debugging purposes. Kinda cool, even
// if you're not really debugging.
//
// Usage: admin_sound_debug
// Usage: admin_sound_reload <filename>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_print_matrix( id , level , cid )
{
	if ( cmd_access(id, level, cid, 1) || !id )
	{
		new i, j, join_snd_buff[TOK_LENGTH * MAX_RANDOM], exit_snd_buff[TOK_LENGTH * MAX_RANDOM]
		
		if ( !is_dedicated_server() && id == 1 )	// for listenserver and id = 1 we can use server_print
			id = 0
		
		if ( id )
			client_print(id, print_console, "SND_WARN: %d^nSND_MAX: %d", SND_WARN, SND_MAX)
		else
			server_print("SND_WARN: %d^nSND_MAX: %d^n", SND_WARN, SND_MAX)
		
		for( i = 0; i < MAX_RANDOM; ++i )
		{
			new tempstr[TOK_LENGTH]
			if ( strlen(Join_wavs[TOK_LENGTH * i]) )
			{
				format(tempstr, TOK_LENGTH, "%s;", Join_wavs[TOK_LENGTH * i])
				add(join_snd_buff, TOK_LENGTH * MAX_RANDOM, tempstr)
			}
			if ( strlen(Exit_wavs[TOK_LENGTH * i]) )
			{
				format(tempstr, TOK_LENGTH, "%s;", Exit_wavs[TOK_LENGTH * i])
				add(exit_snd_buff, TOK_LENGTH * MAX_RANDOM, tempstr)
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
		for( i = 0; i < MAX_KEYWORDS; ++i )
		{
			if ( strlen(WordWavCombo[i]) != 0 )
			{
				if ( id )
					client_print(id, print_console, "^n[%d] ^"%s^" with %d sound%s", i, WordWavCombo[i][0], soundnum_for_keyword[i], soundnum_for_keyword[i] > 1 ? "s" : "")
				else
					server_print("^n[%d] ^"%s^" with %d sound%s", i, WordWavCombo[i][0], soundnum_for_keyword[i], soundnum_for_keyword[i] > 1 ? "s" : "")
				for( j = 1; j < MAX_RANDOM + 1; ++j )
				{
					if ( strlen(WordWavCombo[i][j * TOK_LENGTH]) != 0 )
					{
						if ( id )
							client_print(id, print_console, " ^"%s^" - time: %5.2f", WordWavCombo[i][j * TOK_LENGTH], Sound_duration[i][j])
						else
							server_print(" ^"%s^" - time: %5.2f", WordWavCombo[i][j * TOK_LENGTH], Sound_duration[i][j])
					}
				}
			}
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
	if ( cmd_access(id, level, cid, 2) )
	{
		new arg[33]
		read_argv(1, arg, 32)
		new player = cmd_target(id, arg, 1)
		if ( !player )
			return PLUGIN_HANDLED
		
		if ( get_user_flags(player)& ACCESS_ADMIN )
			return PLUGIN_HANDLED
		
		if ( restrict_playing_sounds[player] == -1 )
		{
			new found, empty = -1
			new steamid[60]
			get_user_authid(id, steamid, 59)
			for ( new i = 0; i < MAX_BANS; ++i )
			{
				if ( empty == -1 && !banned_player_steamids[i][0] )
					empty = i
				if ( equal(steamid, banned_player_steamids[i]) )
				{
					found = 1
					break
				}
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
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Unbans players from using sounds for current map
//
// Usage: amx_sound_unban <player>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_unban( id , level , cid )
{
	if ( cmd_access(id, level, cid, 2) )
	{
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
				if ( equal(steamid, banned_player_steamids[i]) )
				{
					found = i
					break
				}
			}
			if ( found != -1 )
				banned_player_steamids[found][0] = 0
			
			restrict_playing_sounds[player] = -1
		}
		
		new name[33]
		get_user_name(player, name, 32)
		client_print(id, print_console, "Sank Sounds >> Player ^"%s^" has been unbanned from using sounds", name)
	}
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
	if( !strlen(Speech) )
		return PLUGIN_CONTINUE
	
	if ( equal(Speech, "/sound", 6) )
	{
		if ( Speech[6] == 's' )
		{
			if ( Speech[7] == 'o' && Speech[8] == 'n' && Speech[9] == 0 )
				SndOn[id] = 1
			else if ( Speech[7] == 'o' && Speech[8] == 'f' && Speech[9] == 'f' && Speech[10] == 0 )
				SndOn[id] = 0
			else if ( Speech[7] == 0 )
				print_sound_list(id, 1)
		}else if ( equal(Speech[6], "list", 4) )
			print_sound_list(id, 1)
		
		return PLUGIN_HANDLED
	}
	
	new is_admin = ( get_user_flags(id) & ACCESS_ADMIN )
	new ListIndex = -1
	// Check to see if what the player said is a trigger for a sound
	new i, Text[TOK_LENGTH + 1], block_admin_sound
	for ( i = 0; i < MAX_KEYWORDS; ++i )
	{
		copy(Text, TOK_LENGTH, WordWavCombo[i])
		
		// Remove the possible @ sign from beginning (for admins only)
		if ( Text[0] == '@' )
		{
			if ( !is_admin )
				block_admin_sound = 1
			replace(Text, TOK_LENGTH, "@", "")
		}
		if ( equali(Speech, Text) || ( EXACT_MATCH == 0 && containi(Speech, Text) != -1 ) )
		{
			if ( !block_admin_sound )
				ListIndex = i
			break
		}
		block_admin_sound = 0
	}
	
	// If what the player said is a sound trigger, then handle it
	if ( ListIndex != -1 )
	{
		new Float:gametime = get_gametime()
		if ( gametime > NextSoundTime
			|| get_pcvar_num(CVAR_obey_duration) == 0 )
		{
#if DEBUG
			new name[33]
			get_user_name(id, name, 32)
			client_print(id, print_console, "Checking Quota for %i:  %s in %s", name, Text, Speech)
#endif
			// check if player is allowed to play sounds depending on config
			new alive = is_user_alive(id)
			if ( SND_MODE & ( alive + 1 ) )
			{
				// If the user has not exceeded their quota, then play a Wav
				if ( !QuotaExceeded(id) )
				{
					new rand = random(soundnum_for_keyword[ListIndex])
					new timeout
					new playFile[TOK_LENGTH]
		
					// This for loop runs around until it finds a real file to play
					// Defaults to the first Wav file, if no file is found at random.
					for( timeout = MAX_RANDOM;			// Initial condition
						timeout >= 0 && !strlen(playFile);	// While these are true
						--timeout )				// Update each iteration
					{
						rand = random(soundnum_for_keyword[ListIndex])
						// If for some reason we never find a file
						//  then default to the first Wav entry
						if ( !timeout )
							rand = 0
		
						copy(playFile, TOK_LENGTH, WordWavCombo[ListIndex][( rand + 1 ) * TOK_LENGTH])
		
						// If this Wav was an admin-only Wav, but User is not an admin, then skip this one
						if ( equal(playFile, "@", 1) )
						{
							if ( !access(id, ACCESS_ADMIN) )
								playFile[0] = 0
							else
								replace(playFile, TOK_LENGTH, "@", "")
						}
					}
					if ( playFile[0] )
					{
						NextSoundTime = gametime + Sound_duration[ListIndex][rand + 1]
						
						// Increment their playsound count
						++SndCount[id]
						
						//playsoundall(playFile, is_user_alive(id))
						playsoundall(playFile, SND_MODE & 16, alive)
					}
				}
			}
		}
		if ( DISPLAY_KEYWORDS == 0 )
			return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

//////////////////////////////////////////////////////////////////////////////
// Parses the sound file specified by loadfile. If loadfile is empty, then
// it parses the default FILENAME.
//
// Returns 0 if parsing was successful
// Returns 1 if parsing failed
// Returns -1 otherwise
//
// Usage: admin_sound_reload <filename>
//////////////////////////////////////////////////////////////////////////////
parse_sound_file( loadfile[] , precache_sounds = 1 )
{
	new GotLine
	new iLineNum = 0, ListIndex = 0
	new strLineBuf[( MAX_RANDOM + 1 ) * TOK_LENGTH], Text[128]
	new WadOstrings[( MAX_RANDOM + 1 ) * TOK_LENGTH]	// same as [MAX_RANDOM][TOK_LENGTH]
	new Float:sound_length[MAX_RANDOM]

	/************ File should have the following format: **************

	# Set the necessary variables
	SND_MAX;		20
	SND_WARN;		17
	SND_JOIN;		misc/hi.wav
	SND_EXIT;		misc/comeagain.wav
	SND_DELAY;		0.0
	SND_MODE;		15
	EXACT_MATCH;		1
	ADMINS_ONLY;		0
	DISPLAY_KEYWORDS;	1

	# Now give the sound list
	crap;	misc/awwcrap.Wav;misc/awwcrap2.wav
	woohoo;	misc/woohoo.wav
	@ha ha;	misc/haha.wav
	doh;	misc/doh.wav;misc/doh2.wav;@misc/doh3.wav

	******************************************************************/
	
	if ( !strlen(loadfile) )
		copy(loadfile, 127, FILENAME)
	
	if ( file_exists(loadfile) )
	{
		new i, temp = 0
		GotLine = read_file(loadfile, iLineNum, strLineBuf, MAX_RANDOM * TOK_LENGTH, temp)
		if ( GotLine <= 0 )
		{
			log_amx("Sank Sounds >> Unable to read from %s file", loadfile)
			return -1
		}
		// Initialize WordWavCombo[][][] array before using it
		for( i = 0; i < MAX_KEYWORDS; ++i )
			WordWavCombo[i][0] = 0
		
		
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
		
		while ( ( GotLine = read_file(loadfile, iLineNum++, strLineBuf, MAX_RANDOM * TOK_LENGTH, temp) ) > 0 )
		{
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
				allow_check_existence = 1
				
				continue
			}else if ( equali(strLineBuf, "mapname ", 8) )
			{
				if ( equali(strLineBuf[8], mapname) )
					allowed_to_precache = 1
				else
					allowed_to_precache = 0
				
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
			}else if ( equali(strLineBuf, "modspecific") )
			{
				allow_check_existence = 0
				
				continue
			}
			
			if ( !allow_to_use_sounds )	// check for sounds that can be used only on specified map
				continue
			
			if ( ListIndex >= MAX_KEYWORDS )
			{
				log_amx("Sank Sounds >> Sound list truncated. Increase MAX_KEYWORDS")
				log_amx("Sank Sounds >> Stopped parsing file ^"%s^"^n", loadfile)
				break
			}
			// As long as the line isn't commented out, and isn't blank, then process it.
			if ( !equal(strLineBuf, "#", 1) && !equal(strLineBuf, "//", 2) && strlen(strLineBuf) != 0 )
			{
				new fatal_error
				// Take up to MAX_RANDOM Wav files for each keyWord, each separated by a ';'
				// Right now we fill the big WadOstrings[] with the information from the file.
				new is_wordwav_combo = 1, is_keyword_sound = 1
				soundnum_for_keyword[ListIndex] = 0
				for( i = 0; i < MAX_RANDOM; ++i )
				{
					new temp_str[128]
					new check_for_semi = ( contain(strLineBuf, ";") != -1 )
					if ( check_for_semi )
						copyc(temp_str, 127, strLineBuf, ';')
					else
						copy(temp_str, 127, strLineBuf)
					
					new to_replace[127]
					format(to_replace, 127, "%s%s", temp_str, check_for_semi ? ";" : "")
					
					replace(strLineBuf, MAX_RANDOM * TOK_LENGTH, to_replace, "")
					
					// Now remove any spaces or tabs from around the strings -- clean them up
					trim(temp_str)
					
					// check if file length is bigger than array
					if ( strlen(temp_str) > TOK_LENGTH )
					{
						log_amx("Sank Sounds >> Word or Wav is too long: ^"%s^". Length is %i but max is %i (change name/remove spaces in config or increase TOK_LENGTH)", temp_str, strlen(temp_str), TOK_LENGTH)
						log_amx("Sank Sounds >> Skipping this word/wav combo")
						fatal_error = 1
						break
					}
					
					// check if file exists, if not skip it
					if ( !i )
					{	// first is not a sound file
						if ( equali(temp_str, "SND_MAX") || equali(temp_str, "SND_WARN") || equali(temp_str, "SND_DELAY") || equali(temp_str, "SND_MODE") || equali(temp_str, "EXACT_MATCH") || equali(temp_str, "ADMINS_ONLY") || equali(temp_str, "DISPLAY_KEYWORDS") )
							is_wordwav_combo = 0
						else if ( equali(temp_str, "SND_JOIN") || equali(temp_str, "SND_EXIT") )
							is_keyword_sound = 0
					}else if ( is_wordwav_combo && strlen(temp_str) )
					{
						// check if not speech sounds
						if ( ( temp_str[0] != '@' && temp_str[0] != '^"' ) || ( temp_str[0] == '@' && temp_str[1] != '^"' ) )
						{
							new file_name[128], file_name_temp[128]
							copy(file_name, 127, temp_str)
							replace(file_name, TOK_LENGTH, "@", "")
							
							new mp3 = ( containi(file_name, ".mp") != -1 )
							if ( !mp3 )
							{	// ".mp3" in not in the string
								copy(file_name_temp, 127, file_name)
								format(file_name, 127, "sound/%s", file_name)
							}
							
							if ( allow_check_existence )
							{
								if ( !file_exists(file_name) )
								{
									log_amx("Sank Sounds >> Trying to load a file that dont exist. Skipping this file: ^"%s^"", file_name)
									--i
									
									if ( !strlen(strLineBuf) )
									{
										strLineBuf[0] = 0
										break
									}
									
									continue
								}else if ( mp3 )
									sound_length[i] = get_mp3_duration(file_name)
								else
									sound_length[i] = get_wav_duration(file_name)
							}
							
							if ( allow_global_precache && precache_sounds == 1 )
							{
								if ( allowed_to_precache )
								{
									if ( mp3 )
									{
										precache_generic(file_name)
										server_print("precaching MP3 file: %s", file_name)
									}else
									{
										server_print("precaching file: %s", file_name_temp)
										precache_sound(file_name_temp)
									}
								}
							}
						}
						if ( is_keyword_sound )
							++soundnum_for_keyword[ListIndex]
					}
					
					// sound exists and has correct length, so copy it into our big array
					copy(WadOstrings[TOK_LENGTH * i], TOK_LENGTH, temp_str)
					
					if ( !strlen(strLineBuf) )
					{
						strLineBuf[0] = 0
						break
					}
				}
				// If we finished MAX_RANDOM times, and strRest still has contents
				//  then we should have a bigger MAX_RANDOM
				if( strlen(strLineBuf) != 0 && !fatal_error )
				{
					log_amx("Sank Sounds >> Sound list partially truncated. Increase MAX_RANDOM")
					log_amx("Sank Sounds >> Continuing to parse file ^"%s^"^n", loadfile)
				}
				
				// No error occured so continue
				if ( !fatal_error )
				{
					// First look for special parameters
					if ( equali(WadOstrings, "SND_MAX") )
						SND_MAX = str_to_num(WadOstrings[TOK_LENGTH * 1])
					else if ( equali(WadOstrings, "SND_WARN") )
						SND_WARN = str_to_num(WadOstrings[TOK_LENGTH * 1])
					else if ( equali(WadOstrings, "SND_JOIN") )
					{
						Join_snd_num = 0
						for( new j = 0; j < MAX_RANDOM; ++j )
						{
							copy(Join_wavs[TOK_LENGTH * j], TOK_LENGTH, WadOstrings[TOK_LENGTH * ( j + 1 )])
							if ( strlen(Join_wavs[TOK_LENGTH * j]) )
							{
								Join_sound_duration[Join_snd_num] = sound_length[Join_snd_num]
								++Join_snd_num
							}
						}
					}else if ( equali(WadOstrings, "SND_EXIT") )
					{
						Exit_snd_num = 0
						for( new j = 0; j < MAX_RANDOM; ++j )
						{
							copy(Exit_wavs[TOK_LENGTH * j], TOK_LENGTH, WadOstrings[TOK_LENGTH * ( j + 1 )])
							if ( strlen(Exit_wavs[TOK_LENGTH * j]) )
							{
								Join_sound_duration[Exit_snd_num] = sound_length[Exit_snd_num]
								++Exit_snd_num
							}
						}
					}else if ( equali(WadOstrings, "SND_DELAY") )
						SND_DELAY = floatstr(WadOstrings[TOK_LENGTH * 1])
					else if ( equali(WadOstrings, "SND_MODE") )
						SND_MODE = str_to_num(WadOstrings[TOK_LENGTH * 1])
					else if ( equali(WadOstrings, "EXACT_MATCH") )
						EXACT_MATCH = str_to_num(WadOstrings[TOK_LENGTH * 1])
					else if ( equali(WadOstrings, "ADMINS_ONLY") )
						ADMINS_ONLY = str_to_num(WadOstrings[TOK_LENGTH * 1])
					else if ( equali(WadOstrings, "DISPLAY_KEYWORDS") )
						DISPLAY_KEYWORDS = str_to_num(WadOstrings[TOK_LENGTH * 1])
					
					// If it wasn't one of those essential parameters, then it should be
					//  a Keyword/Wav combo, so we'll treat it as such by copying it from our
					//  temporary structure into our global structure, WordWavCombo[][][]
					else if ( soundnum_for_keyword[ListIndex] > 0 )
					{	// we have to make sure that the keyword has at least one sound, otherwise it will not be added
						// Now we must transfer the contents of WadOstrings[] to
						//  our global data structure, WordWavCombo[Index][]
						//  with a really tricky "string copy"
						for ( i = 0; i < MAX_RANDOM * TOK_LENGTH; ++i )
							WordWavCombo[ListIndex][i] = WadOstrings[i]
						
						for ( i = 0; i < MAX_RANDOM; ++i )
							Sound_duration[ListIndex][i] = sound_length[i]
						
						++ListIndex
					}else
						log_amx("Sank Sounds >> Found keyword without any valid sound. Skipping this keyword: ^"%s^"", WadOstrings)
				}
			}
			// Initialize variables for next time by clearing all the
			//  strings in the WadOstrings[]
			for ( i = 0; i < MAX_RANDOM; ++i )
			{
				WadOstrings[i * TOK_LENGTH] = 0
				sound_length[i] = 0.0
			}
		}
		
		// Now we have all of the data from the text file in our data structures.
		// Next we do some error checking, some setup, and we're done parsing!
		ErrorCheck()
		
#if DEBUG
		// Log some info for the nosey admin
		log_amx("Sank Sounds >> Sound quota set to %i", SND_MAX)
		
		amx_sound_print_matrix(0, 0, 0)
		server_print("Sank Sounds >> Done parsing ^"%s^" file^n", loadfile)
#endif
		
		++current_package
		if ( current_package > package_num )
			current_package = 1
		
		num_to_str(current_package, current_package_str, 3)
		set_vaultdata("sank_sounds_current_package", current_package_str)
		
#if ALLOW_SORT == 1
		if ( ListIndex > 1 )
			HeapSort(ListIndex)
#endif
	}else
	{	// file exists returned false, meaning the file didn't exist
		format(Text, 127, "Sank Sounds >> Cannot find ^"%s^" file", loadfile)
		log_amx(Text)
		return 1
	}
	
	return 0
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
	if ( !admin_check && SND_MAX != 0 )
	{
		if ( SndCount[id] > SND_MAX && SndCount[id] + 3 > SND_MAX )
		{
			client_print(id, print_chat, "Sank Sounds >> You were warned, you are muted")
			
			// player is already muted, we increament here to save a variable to protect player from "you are muted" spam
			++SndCount[id]
			
			return 1
		}else if ( SndCount[id] >= SND_WARN )
			client_print(id, print_chat, "Sank Sounds >> You have %d left before you get muted", SND_MAX - SndCount[id])
	}
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
		log_amx("Sank Sounds >> SND_DELAY cannot be negative")
		log_amx("Sank Sounds >> SND_DELAY set to default value 0")
		SND_DELAY = 0.0
	}
	// If SND_MAX is zero, then sounds quota is disabled. Can't have negative quota
	if ( SND_MAX < 0 )
	{
		SND_MAX = 0	// in case it was negative
		log_amx("Sank Sounds >> SND_MAX cannot be negative. Setting to value 0")
	}
	// If SND_WARN is zero, then we can't have warning every
	// time a keyWord is said, so we default to 3 less than max
	else if ( ( SND_WARN <= 0 && SND_MAX != 0 ) || SND_MAX < SND_WARN )
	{
		if ( SND_MAX > 3 )
			SND_WARN = SND_MAX - 3
		else
			SND_WARN = SND_MAX - 1
		
		if ( SND_MAX < SND_WARN  )
		{
			// And finally, if they want to warn after a person has been
			// muted, that's silly, so we'll fix it.
			log_amx("Sank Sounds >> SND_WARN cannot be higher than SND_MAX")
			log_amx("Sank Sounds >> SND_WARN set to default value")
		}else
		{
			log_amx("Sank Sounds >> SND_WARN cannot be set to zero")
			log_amx("Sank Sounds >> SND_WARN set to default value")
		}
	}
}

playsoundall( sound[], split_dead_alive = 0 , sender_alive_status = 0 )
{
	remove_quotes(sound)
	replace(sound, 127, " ^t", "")
	
	new is_mp3 = ( containi(sound, ".mp") != -1 )
	new no_subfolder = ( containi(sound, "/") == -1 )
	new alive
	for( new i = 1; i <= g_max_players; ++i )
	{
		if ( is_user_connected(i) && !is_user_bot(i) )
		{
			if ( SndOn[i] )
			{
				if ( SND_MODE & ( ( alive = is_user_alive(i) ) * 4 + 4 ) )
				{
					if ( split_dead_alive )
					{
						if ( alive == sender_alive_status )
						{
							if ( is_mp3 )
								client_cmd(i, "mp3 play ^"%s^"", sound)
							else if ( no_subfolder )
								client_cmd(i, "play ^"%s^"", sound)
							else
								client_cmd(i, "spk ^"%s^"", sound)
						}
					}else
					{
						if ( is_mp3 )
							client_cmd(i, "mp3 play ^"%s^"", sound)
						else
							client_cmd(i, "spk ^"%s^"", sound)
					}
				}
			}
		}
	}
}

print_sound_list( id , motd_msg = 0 )
{
	new text[256], motd_buffer[2048], ilen
	new info_text[64] = "say < keyword >: plays A sound. keYwords are listed Below:"
	if ( motd_msg )
		ilen = format(motd_buffer, 2047, "<body bgcolor=#000000><font color=#FFB000><pre>%s^n", info_text)
	else
		client_print(id, print_console, info_text)
	
	// Loop once for each keyword
	new i, j = -1
	for( i = 0; i < MAX_KEYWORDS; ++i )
	{
		// If an invalid string, then break this loop
		if( strlen(WordWavCombo[i]) == 0 || strlen(WordWavCombo[i]) > TOK_LENGTH )
			break
		
		// check if player can see admin sounds
		j += 1
		new found_stricted = 0
		if ( equal(WordWavCombo[i], "@", 1) )
		{
			if ( get_user_flags(id) & ACCESS_ADMIN )
			{
				if ( motd_msg )
					ilen += format(motd_buffer[ilen], 2047 - ilen, "%s", WordWavCombo[i])
				else
					add(text, 255, WordWavCombo[i])
			}else
			{
				j -= 1
				found_stricted = 1
			}
		}else
		{
			if ( motd_msg )
				ilen += format(motd_buffer[ilen], 2047 - ilen, "%s", WordWavCombo[i])
			else
				add(text, 255, WordWavCombo[i])
		}
		if ( !found_stricted )
		{
			if( j % NUM_PER_LINE == NUM_PER_LINE - 1 )
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
	if ( motd_msg && strlen(motd_buffer) )
		show_motd(id, motd_buffer)
	else if( strlen(text) )
		client_print(id, print_console, text)
}

// 4 functions for array sort ( by Bailopan )
stock HeapSort( ListIndex )
{
	new i
	new aSize = ( ListIndex / 2 ) - 1
	for ( i = aSize; i >= 0; --i )
		SiftDown(i, ListIndex - 1)
	
	for ( i = ListIndex - 1; i >= 1; --i )
	{
		switch_array_elements(0, i)
		SiftDown(0, i - 1)
	}
}

stock fstrcmp( str1[] , str2[] )
{
	new i = 0
	for ( i = 0; i < TOK_LENGTH; ++i )
	{
		if ( str1[i] != str2[i] )
		{
			if ( str1[i] > str2[i] )
				return 1
			else
				return -1
		}
	}
	return 0
}

stock SiftDown( root , bottom )
{
	new done, child
	while ( ( root * 2 <= bottom ) && !done )
	{
		if ( root * 2 == bottom )
			child = root * 2
		else if ( fstrcmp(WordWavCombo[root * 2], WordWavCombo[root * 2 + 1]) > 0 )
			child = root * 2
		else
			child = root * 2 + 1
		
		if ( fstrcmp(WordWavCombo[root], WordWavCombo[child]) < 0 )
		{
			switch_array_elements(root, child)
			root = child
		}else
			done = 1
	}
}

stock switch_array_elements( element_one , element_two )
{
	new temp_str[TOK_LENGTH * ( MAX_RANDOM + 1 )], temp_int, Float:temp_float, i
	for ( i = 0; i < TOK_LENGTH * ( MAX_RANDOM + 1 ); ++i )
		temp_str[i] = WordWavCombo[element_one][i]
	temp_int = soundnum_for_keyword[element_one]
	
	for ( i = 0; i < TOK_LENGTH * ( MAX_RANDOM + 1 ); ++i )
		WordWavCombo[element_one][i] = WordWavCombo[element_two][i]
	soundnum_for_keyword[element_one] = soundnum_for_keyword[element_two]
	
	for ( i = 0; i < TOK_LENGTH * ( MAX_RANDOM + 1 ); ++i )
		WordWavCombo[element_two][i] = temp_str[i]
	soundnum_for_keyword[element_two] = temp_int
	
	for ( i = 0; i < MAX_RANDOM; ++i )
	{
		temp_float = Sound_duration[element_one][i]
		Sound_duration[element_one][i] = Sound_duration[element_two][i]
		Sound_duration[element_two][i] = temp_float
	}
}

Float:get_wav_duration( wav_file[] )
{
	new file = fopen(wav_file, "rb")
	new dummy_input
	new i
	for ( i = 0; i < 24; ++i )
		dummy_input = fgetc(file)
	
	// 24th bit
	new hertz = fgetc(file)
	// 25th bit
	hertz += fgetc(file) * 256
	// 26th bit
	hertz += fgetc(file) * 256 * 256
	
	for ( i = 27; i < 34; ++i )
		dummy_input = fgetc(file)
	
	// 34th bit
	new bitrate = fgetc(file)
	
	// bytes for data length start right after ascii "data", so search for it
	// normally it is at 35 but also saw at 44, so just in case add bigger search area
	new data_found
	for ( i = 35; i < 200 && data_found < 4; ++i )
	{
		dummy_input = fgetc(file)
		if ( dummy_input == 'd' )
			++data_found
		else if ( dummy_input == 'a' && data_found == 1 )
			++data_found
		else if ( dummy_input == 't' )
			++data_found
		else if ( dummy_input == 'a' )
			++data_found
		else
			data_found = 0
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

Float:get_mp3_duration( mp3_file[] )
{
	new file = fopen(mp3_file, "rb")
	new byte, found_header, file_pos
	do
	{
		byte = fgetc(file)
		++file_pos
		if ( byte == 255 )
		{
			byte = fgetc(file)
			++file_pos
			if ( ( byte / 16 ) == 15 )
			{
				//if ( fgetc(file) > 80 )
				if ( fgetc(file) > 0 )
				{
					// header starts with hex: FF YY XX
					// YY must be YY modulo 16 = 15, but mostly it is FB or F3
					fseek(file, file_pos, SEEK_SET);
					found_header = 1
				}else
					++file_pos
			}
				
		}
	}while ( !found_header )
	
	// position of first frame header......
	file_pos -= 2
	
	new header_start = file_pos
	
	// version check MPEG 1/2... ( 0 = mpeg 2 / 1 = mpeg 1 )
	new mpeg_version = ( ( byte % 16 ) / 4 ) / 2
	
	// layer check.... normally ( tested: 1 = layer 3 / 2 = layer 2; untested: 3 = layer 1 )
	// but we make layer 3 be realy 3:
	//    --->>> 4 - 1 = 3
	new layer = 4 - ( ( ( ( byte % 16 ) / 4 ) % 2 ) * 2 + ( ( ( byte % 16 ) % 4 ) / 2 ) )
	
	//get next byte to read 3rd byte of header. 
	byte = fgetc(file)
	
	// bitrate info
	new const bitrate_table[] = {
		//MPEG 2 & 2.5
		0, 32, 48, 56,  64,  80,  96, 112, 128, 144, 160, 176, 192, 224, 256, 0,	// Layer I
		0,  8, 16, 24,  32,  40,  48,  56,  64,  80,  96, 112, 128, 144, 160, 0,	// Layer II
		0,  8, 16, 24,  32,  40,  48,  56,  64,  80,  96, 112, 128, 144, 160, 0,	// Layer III
		//MPEG 1
		0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 0,	// Layer I
		0, 32, 48, 56,  64,  80,  96, 112, 128, 160, 192, 224, 256, 320, 384, 0,	// Layer II
		0, 32, 40, 48,  56,  64,  80,  96, 112, 128, 160, 192, 224, 256, 320, 0,	// Layer III
	}
	new mp3_bitrate = bitrate_table[mpeg_version * ( 3 * 16 ) + ( layer - 1 ) * 16 + ( byte / 16 )]
	
	// frequency info
	new const frequency_table[] = {
		22050, 24000, 16000,	// MPEG 2
		44100, 48000, 32000,	// MPEG 1
		32000, 16000,  8000,	// MPEG 2.5	// have noot seen MPEG 2.5, so UNTESTED
		    0,     0,     0	// reserved
	}
	new mp3_frequency = frequency_table[mpeg_version * 3 + ( byte % 16 ) / 4]
	
	// padding bit
	new padding_bit = ( ( byte % 16 ) % 4 ) / 2
	
	// get next char to read 4th byte of header.
	byte = fgetc(file)
	
	fclose(file)
	
	// all header info over..... calculating frame size.
	new frame_size = ( 144000 * mp3_bitrate / mp3_frequency ) + padding_bit
	
	new size_of_file = file_size(mp3_file, 0)
	
	//no. of frames...
	new frames = ( size_of_file - header_start ) / frame_size
	
	// MPEG 2 Layer 3 seems to have twice more frames
	if ( mpeg_version == 0 && layer == 3 )
		frames *= 2
	
	//song length...
	return float(size_of_file) / ( float(mp3_bitrate) * 1000.0 ) * 8.0
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