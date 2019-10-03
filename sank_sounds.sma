/***************************************************************************
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
* This plugin will read from a text file keyword/wav file combinations
* and when a player says one of the keyWords, it will trigger HL to play
* that Wav file to all players. It allows reloading of the file without
* restarting the current level, as well as adding keyword/wav combinations
* from the console during gameplay.
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
*
* Functions included in this plugin:
*	mp_sank_sounds_download	1/0		-	turn internal download system on/off
*	mp_sank_sounds_freezetime <x>		-	x = time in seconds to wait till first sounds are played (connect sound)
*	amx_sound_add <keyword> <dir/wav>	-	adds a word/wav/mp3/speech
*	amx_sound_help				-	prints all available sounds to console
*	amx_sound				-	turn Sank Sounds on/off
*	amx_sound_play <dir/wav>		-	plays a specific wav/mp3/speech
*	amx_sound_reload <filename>		-	reload your snd-list.cfg or custom .cfg
*	amx_sound_remove <keyword> <dir/wav>	-	remove a word/wav/mp3
*	amx_sound_write <filename>		-	write all settings to custom .cfg
*	amx_sound_debug				-	prints debugs (debug mode must be on, see define below)
*	SND_WARN 				- 	The number at which a player will get warned for playing too many sounds
*	SND_MAX					-	The number at which a player will get muted for playing too many sounds
*	SND_JOIN				-	The Wavs to play when a person joins the game
*	SND_EXIT				-	The Wavs to play when a person exits the game
*	SND_DELAY				-	Minimum delay between sounds
*	SND_SPLIT 1/0				-	Determines if sounds play to all, or isolate dead and alive
*	EXACT_MATCH 1/0				-	Determines if plugin triggers on exact match, or partial speech match
*	ADMINS_ONLY 1/0				-	Determines if only admins are allowed to play sounds
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
* IMPORTANT:
*	a) if u want to use the internal download system do not use more than 500 sounds (HL cannot handle it)
*		but if u disable the internal download system u can use as many sounds as the plugin can handle
*		(max should be over 100k sounds (depending on the Array Defines ), BUT the plugin speed
*		is another question with thousands of sounds ;) )
*	
*	b) File has to look like this:
*		SND_MAX;		20
*		SND_WARN;		17
*		SND_JOIN;		misc/hi.wav
*		SND_EXIT;		misc/comeagain.wav
*		SND_DELAY;		0
*		SND_SPLIT;		0
*		EXACT_MATCH;		1
*		ADMINS_ONLY;		0
*	
*		# Word/Wav combinations:
*		crap;			misc/awwcrap.Wav;misc/awwcrap2.wav
*		woohoo;			misc/woohoo.wav
*		@ha ha;			misc/haha.wav
*		doh;			misc/doh.wav;misc/doh2.wav;@misc/doh3.wav
*		mp3;			sound/mymp3.mp3;music/mymp3s/number2.mp3;mainfolder.mp3
*		target;			"target destroyed"
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

// Comment the line below ( add // infront of it ) to remove mp3 support
#define	MP3_SUPPORT

// set this to 1 to get some debug messages
#define	DEBUG	0

// turn this off to stop list from being sorted by word names
#define	ALLOW_SORT	1

//#pragma dynamic 16384
#pragma dynamic 65536

#include <amxmodx>
#include <amxmisc>
#if defined MP3_SUPPORT
#include <engine>
#endif

#define ACCESS_ADMIN	ADMIN_LEVEL_A

new plugin_author[] = "Luke Sankey, White Panther, HunteR"
new plugin_version[] = "1.3.5"

new FILENAME[128]

// Array Defines, ( MAX_RANDOM + 1 ) * TOK_LENGTH <= 2048 !!!
#define MAX_KEYWORDS	80				// Maximum number of keywords
#define MAX_RANDOM	15				// Maximum number of wavs per keyword
#define TOK_LENGTH	60				// Maximum length of keyword and wav/mp3 file strings

#define NUM_PER_LINE	6				// Number of words per line from amx_sound_help
#define Enable_Sound	"misc/woohoo.wav"		// Sound played when Sank Soounds enabled
#define Disable_Sound	"misc/awwcrap.wav"		// Sound played when Sank Soounds disabled

new SndCount[33] = {0,...}			// Holds the number telling how many sounds a player has played
new SndOn[33] = {1,...}

new SND_WARN = 0				// The number at which a player will get warned for playing too many sounds
new SND_MAX = 0					// The number at which a player will get kicked for playing too many sounds
new Join_wavs[TOK_LENGTH*MAX_RANDOM]		// The Wavs to play when a person joins the game
new Exit_wavs[TOK_LENGTH*MAX_RANDOM]		// The Wavs to play when a person exits the game
new Join_snd_num, Exit_snd_num			// Number of join and exit Wavs
new SND_DELAY = 0				// Minimum delay between sounds
new SND_SPLIT = 0				// Determines if sounds play to all, or isolate dead and alive
new EXACT_MATCH = 1				// Determines if plugin triggers on exact match, or partial speech match
new ADMINS_ONLY = 0				// Determines if only admins are allowed to play sounds

new WordWavCombo[MAX_KEYWORDS][TOK_LENGTH*(MAX_RANDOM+1)]

new Float:LastSoundTime = 0.0	// Very limited spam protection
new bSoundsEnabled = 1		// amx_sound <on/off> or <1/0>

new g_max_players

public plugin_init(){
	register_plugin("Sank Sounds Plugin",plugin_version,plugin_author)
	register_cvar("sanksounds_version",plugin_version,FCVAR_SERVER)
	register_concmd("amx_sound_reset","amx_sound_reset",ACCESS_ADMIN," <user | all> : Resets sound quota for ^"user^", or everyone if ^"all^"")
	register_concmd("amx_sound_add","amx_sound_add",ACCESS_ADMIN," <keyword> <dir/wav> : Adds a Word/Wav combo to the sound list")
	register_clcmd("amx_sound_help","amx_sound_help")
	register_concmd("amx_sound","amx_sound",ACCESS_ADMIN," :  Turns sounds on/off")
	register_concmd("amx_sound_play","amx_sound_play",ACCESS_ADMIN," <dir/wav> : Plays sound to all users")
	register_concmd("amx_sound_reload","amx_sound_reload",ACCESS_ADMIN," : Reloads config file. Filename is optional. If no filename, default is loaded")
	register_concmd("amx_sound_remove","amx_sound_remove",ACCESS_ADMIN," <keyword> <dir/wav> : Removes a Word/Wav combo from the sound list. Must use quotes")
	register_concmd("amx_sound_write","amx_sound_write",ACCESS_ADMIN," :  Writes current sound configuration to file")
	register_concmd("amx_sound_debug", "amx_sound_print_matrix",ACCESS_ADMIN,"prints the whole Word/Wav combo list")
	register_clcmd("say", "HandleSay")
	
	register_cvar("mp_sank_sounds_download","1")
	register_cvar("mp_sank_sounds_freezetime","0")
	
	g_max_players = get_maxplayers()
}

#if defined MP3_SUPPORT
public plugin_modules(){
	require_module("engine")
}
#endif

public client_connect(id){
	if ( get_gametime() > get_cvar_num("mp_sank_sounds_freezetime") ){
		if ( Join_snd_num ){
			new a = random_num(1,Join_snd_num) - 1 // first wav has index 0
			new playFile[TOK_LENGTH]
			copy(playFile, TOK_LENGTH, Join_wavs[TOK_LENGTH*a])
			playsoundall(playFile)
		}
	}
	SndCount[id] = 0
	SndOn[id] = 1
}

public client_disconnect(id){
	if ( get_gametime() > get_cvar_num("mp_sank_sounds_freezetime") ){
		if ( Exit_snd_num ){
			new a = random_num(1,Exit_snd_num) - 1 // first wav has index 0
			new playFile[TOK_LENGTH]
			copy(playFile, TOK_LENGTH, Exit_wavs[TOK_LENGTH*a])
			playsoundall(playFile)
		}
	}
	SndCount[id] = 0
	SndOn[id] = 1
}

public plugin_precache(){
	new configpath[60]
	get_configsdir(configpath,60)
	format(FILENAME,127,"%s/SND-LIST.CFG",configpath) // Name of file to parse
	parse_sound_file(FILENAME)
	if ( get_cvar_num("mp_sank_sounds_download") ){
		for ( new i = 0; i < MAX_KEYWORDS + 2; i++ ){
			for ( new j = 0; j < MAX_RANDOM; j++ ){
				if ( i < MAX_KEYWORDS && strlen(WordWavCombo[i][TOK_LENGTH*(j+1)]) ){
					new temp_file[TOK_LENGTH+1]
					copy(temp_file,TOK_LENGTH,WordWavCombo[i][TOK_LENGTH*(j+1)])
					if ( equal(temp_file,"@",1) )
						replace(temp_file,TOK_LENGTH,"@","")
					// check if not speech sounds
					if ( temp_file[0] != '^"' )
						precache_file(temp_file)
				}else if ( i == MAX_KEYWORDS && strlen(Join_wavs[TOK_LENGTH*j]) )
					precache_file(Join_wavs[TOK_LENGTH*j])
				else if ( i == MAX_KEYWORDS + 1 && strlen(Exit_wavs[TOK_LENGTH*j]) )
					precache_file(Exit_wavs[TOK_LENGTH*j])
			}
		}
	}
}

precache_file(file[]){
#if defined MP3_SUPPORT
	new is_mp3 = ( containi(file,".mp3") != -1 )
	if ( is_mp3 )
		precache_generic(file)
	else
#endif
		precache_sound(file)
}

public amx_sound_reset(id,level,cid){
	if ( cmd_access(id,level,cid,2) ){
		new arg[33], i
		read_argv(1,arg,32)
		if ( equal(arg,"all") == 1 ){
			client_print(id,print_console, "[AMXX] Sound quota reset for all players")
			for ( i = 1; i <= g_max_players; i++ )
				SndCount[i] = 0
		}else{
			i = get_user_index(arg)
			if ( is_user_connected(i) ){
				SndCount[i] = 0
				client_print(id,print_console, "[AMXX] Sound quota reset for player %s", arg)
			}else
				client_print(id,print_console, "[AMXX] Unrecognized player: %s", arg)
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
public amx_sound_add(id,level,cid){
	if ( cmd_access(id,level,cid,2) ){
		new Word[TOK_LENGTH+1], Wav[TOK_LENGTH+1]
		new bGotOne = 0
		new joinex
		
		read_argv(1,Word,TOK_LENGTH)
		read_argv(2,Wav,TOK_LENGTH)
		if( strlen(Word) == 0 || strlen(Wav) == 0 ){
			client_print(id,print_console,"Invalid format")
			client_print(id,print_console,"USAGE: amx_sound_add keyword <dir/wav>")
			return PLUGIN_HANDLED
		}
	
		// First look for special parameters
		if ( equali(Word, "SND_MAX") ){
			SND_MAX = str_to_num(Wav)
			bGotOne = 1
		}else if ( equali(Word, "SND_WARN") ){
			SND_WARN = str_to_num(Wav)
			bGotOne = 1
		}else if ( equali(Word, "SND_JOIN") ){
			//copy(SND_JOIN,TOK_LENGTH,Wav)
			//bGotOne = 1
			joinex = 1
		}else if ( equali(Word, "SND_EXIT") ){
			//copy(SND_EXIT,TOK_LENGTH,Wav)
			//bGotOne = 1
			joinex = 2
		}else if ( equali(Word, "SND_DELAY") ){
			SND_DELAY = str_to_num(Wav)
			bGotOne = 1
		}else if ( equali(Word, "SND_SPLIT") ){
			SND_SPLIT = str_to_num(Wav)
			bGotOne = 1
		}else if ( equali(Word, "EXACT_MATCH") ){
			EXACT_MATCH = str_to_num(Wav)
			bGotOne = 1
		}else if ( equali(Word, "ADMINS_ONLY") ){
			ADMINS_ONLY = str_to_num(Wav)
			bGotOne = 1
		}
		if ( bGotOne ){
			// Do some error checking on the user-input numbers
			ErrorCheck()
			return PLUGIN_HANDLED
		}
		
		// check if is a speech
		new found_speech
		if ( containi(Wav,".wav") == -1 && containi(Wav,".mp3") == -1 ){
			found_speech = 1
			format(Wav,TOK_LENGTH,"^"%s^"",Wav)
		}
		
		// check if the file to be added exists (speech always exists, or at least dont need to be precached)
		if ( !found_speech ){
			new file_name[TOK_LENGTH+1]
			copy(file_name,TOK_LENGTH,Wav)
			replace(file_name, TOK_LENGTH, "@","")
			format(file_name,TOK_LENGTH,"sound/%s",file_name)
			if ( !file_exists(file_name) ){
				log_amx("Sank Sound Plugin >> Trying to add a file that dont exist. Not adding this file: ^"%s^"",file_name)
				return PLUGIN_HANDLED
			}
		}
		
		// Loop once for each keyword
		new i
		for( i = 0; i < MAX_KEYWORDS; i++ ){
			// If an empty string, then break this loop
			if( strlen(WordWavCombo[i]) == 0 )
				break
			// If we find a match, then add on the new Wav data
			if( equal(Word, WordWavCombo[i], TOK_LENGTH) || joinex ){
				// See if the Wav already exists
				new j
				for( j = 1; j < MAX_RANDOM; j++ ){
					if ( joinex == 1){
						// If an empty string, then break this loop
						if ( strlen(Join_wavs[TOK_LENGTH*(j-1)]) == 0 )
							break
						
						else if( equali(Wav, Join_wavs[TOK_LENGTH*(j-1)], TOK_LENGTH) ){
							client_print(id,print_console,"Sank Sound Plugin >> ^"%s^" already exists in SND_JOIN", Wav)
							return PLUGIN_HANDLED
						}
					}else if ( joinex == 2 ){
						// If an empty string, then break this loop
						if ( strlen(Exit_wavs[TOK_LENGTH*(j-1)]) == 0 )
							break
						
						else if( equali(Wav, Exit_wavs[TOK_LENGTH*(j-1)], TOK_LENGTH) ){
							client_print(id,print_console,"Sank Sound Plugin >> ^"%s^" already exists in SND_EXIT", Wav)
							return PLUGIN_HANDLED
						}
					}else{
						// If an empty string, then break this loop
						if ( strlen(WordWavCombo[i][TOK_LENGTH*j]) == 0 )
							break
		
						// See if this is the same as the new Wav
						if( equali(Wav, WordWavCombo[i][TOK_LENGTH*j], TOK_LENGTH) ){
							client_print(id,print_console,"Sank Sound Plugin >> ^"%s; %s^" already exists", Word, Wav)
							return PLUGIN_HANDLED
						}
					}
				}
	
				// If we reached the end, then there is no room
				if( j >= MAX_RANDOM )
					client_print(id,print_console,"Sank Sound Plugin >> No room for new Wav. Increase MAX RANDOM and recompile")
				else{
					// Word exists, but Wav is new to the list, so add entry
					if ( joinex == 1)
						copy(Join_wavs[TOK_LENGTH*j], TOK_LENGTH, Wav)
					else if ( joinex == 2)
						copy(WordWavCombo[i][TOK_LENGTH*j], TOK_LENGTH, Wav)
					else
						copy(WordWavCombo[i][TOK_LENGTH*j], TOK_LENGTH, Wav)
					
					client_print(id,print_console,"Sank Sound Plugin >> ^"%s^" successfully added to ^"%s^"", Wav, Word)
				}
				return PLUGIN_HANDLED
			}
		}
		// If we reached the end, then there is no room
		if( i >= MAX_KEYWORDS )
			client_print(id,print_console,"Sank Sound Plugin >> No room for new Word/Wav combo. Increase MAX KEYWORDS and recompile")
		else{
			// Word/Wav combo is new to the list, so make a new entry
			copy(WordWavCombo[i][TOK_LENGTH*0], TOK_LENGTH, Word)
			copy(WordWavCombo[i][TOK_LENGTH*1], TOK_LENGTH, Wav)
			client_print(id,print_console,"Sank Sound Plugin >> ^"%s; %s^" successfully added", Word, Wav)
		}
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// amx_sound_help lists all amx_sound commands and keywords to the user.
//
// Usage: amx_sound_help
//////////////////////////////////////////////////////////////////////////////
public amx_sound_help(id){
	print_sound_list(id)
	
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Turns on/off the playing of the Wav files for this plugin only
//////////////////////////////////////////////////////////////////////////////
public amx_sound(id,level,cid){
	if ( !cmd_access(id,level,cid,2) )
		return PLUGIN_HANDLED
	new onoff[5]
	read_argv(1,onoff,4)
	if ( equal(onoff,"on") || equal(onoff,"1") ){
		if ( bSoundsEnabled == 1 ){
			console_print(id,"Sank Sounds Plugin already enabled")
		}else{
			bSoundsEnabled = 1
			console_print(id,"Sank Sounds Plugin enabled")
			client_print(0,print_chat,"[AMXX] Sank Sounds Plugin has been enabled")
			playsoundall(Enable_Sound)
		}
		return PLUGIN_HANDLED
	}
	if ( equal(onoff,"off") || equal(onoff,"0") ){
		if ( bSoundsEnabled == 0 ){
			console_print(id,"Sank Sounds Plugin already disabled")
		}else{
			bSoundsEnabled = 0
			console_print(id,"Sank Sounds Plugin disabled")
			client_print(0,print_chat,"[AMXX] Sank Sounds Plugin has been disabled")
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
public amx_sound_play(id,level,cid){
	if ( cmd_access(id,level,cid,2) ){
		new arg[128]
		read_argv(1,arg,127)
		playsoundall(arg)
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Reloads the Word/Wav combos from filename
//
// Usage: admin_sound_reload <filename>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_reload(id,level,cid){
	if ( cmd_access(id,level,cid,0) ){
		new parsefile[128]
		read_argv(1,parsefile,127)
		// Initialize WordWavCombo[][][] array
		new i
		for( i = 0; i < MAX_KEYWORDS; i++ )
			WordWavCombo[i][0] = 0
		Join_wavs[0] = 0
		Exit_wavs[0] = 0
		
		parse_sound_file(parsefile)
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
public amx_sound_remove(id,level,cid){
	if ( cmd_access(id,level,cid,2) ){
		new Word[TOK_LENGTH+1], Wav[TOK_LENGTH+1]
		
		read_argv(1,Word,TOK_LENGTH)
		read_argv(2,Wav,TOK_LENGTH)
		if( strlen(Word) == 0 ){
			client_print(id,print_console,"Invalid format")
			client_print(id,print_console,"USAGE: admin_sound_remove keyword <dir/wav>")
			return PLUGIN_HANDLED
		}
		
		// Loop once for each keyWord
		new iCurWord
		for( iCurWord = 0; iCurWord < MAX_KEYWORDS + 2; iCurWord++ ){
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
			if( equali(Word, WordWavCombo[iCurWord], TOK_LENGTH) || joinex ){
				// If no Wav was specified, then remove the whole Word's entry
				if( strlen(Wav) == 0 ){
					if ( joinex == 1 ){
						Join_wavs[0] = 0
						client_print(id,print_console,"Sank Sound Plugin >> Successfully removed wavs from %s", Word)
						return PLUGIN_HANDLED
					}else if ( joinex == 2 ){
						Exit_wavs[0] = 0
						client_print(id,print_console,"Sank Sound Plugin >> Successfully removed wavs from %s", Word)
						return PLUGIN_HANDLED
					}else{
						// Keep looping i, copying the next into the current
						for(; iCurWord < MAX_KEYWORDS; iCurWord++ ){
							// If we're about to copy a string that doesn't exist,
							//  then just erase the last string instead of copying.
							if ( iCurWord >= MAX_KEYWORDS - 1 ){
								// Delete the last Word string
								WordWavCombo[iCurWord][0] = 0
								// We reached the end
								client_print(id,print_console,"Sank Sound Plugin >> %s successfully removed", Word)
								return PLUGIN_HANDLED
							}else{
								// Copy the next string over the current string
								for( jCurWav = 0; jCurWav < TOK_LENGTH * (MAX_RANDOM+1); jCurWav++ )
									WordWavCombo[iCurWord][jCurWav] = WordWavCombo[iCurWord+1][jCurWav]
							}
						}
					}
				}else{
					// Just remove the one Wav, if it exists
					for( jCurWav = 1; jCurWav <= MAX_RANDOM; jCurWav++ ){
						// If an empty string, then break this loop, we're at the end
						if ( joinex == 1 ){
							if ( !strlen(Join_wavs[TOK_LENGTH*(jCurWav-1)]) )
								break
						}else if ( joinex == 2 ){
							if ( !strlen(Exit_wavs[TOK_LENGTH*(jCurWav-1)]) )
								break
						}else if ( !strlen(WordWavCombo[iCurWord][TOK_LENGTH*jCurWav]) )
							break
						
						// speech must have extra ""
						if ( containi(Wav,".wav") == -1 && containi(Wav,".mp3") == -1 )
							format(Wav,TOK_LENGTH,"^"%s^"",Wav)
						
						// Look for a Wav match
						if ( equali(Wav, WordWavCombo[iCurWord][TOK_LENGTH*jCurWav], TOK_LENGTH) || ( joinex && ( equali(Wav, Join_wavs[TOK_LENGTH*(jCurWav-1)], TOK_LENGTH) || equali(Wav, Exit_wavs[TOK_LENGTH*(jCurWav-1)], TOK_LENGTH) ) ) ){
							for(; jCurWav <= MAX_RANDOM; jCurWav++ ){
								if ( !joinex ){
									// If this is the only Wav entry, then remove the entry altogether
									if ( jCurWav == 1 && !strlen(WordWavCombo[iCurWord][TOK_LENGTH*(jCurWav+1)]) ){
										// Keep looping i, copying the next into the current
										for(; iCurWord < MAX_KEYWORDS; iCurWord++ ){
											// If we're about to copy a string that doesn't exist,
											//  then just erase the last string instead of copying.
											if ( iCurWord >= MAX_KEYWORDS-1 ){
												// Delete the last Word string
												WordWavCombo[iCurWord][0] = 0
												// We reached the end
												client_print(id,print_console,"Sank Sound Plugin >> %s successfully removed", Word)
												return PLUGIN_HANDLED
											}else{
												// Copy the next string over the current string
												for( jCurWav = 0; jCurWav < TOK_LENGTH * (MAX_RANDOM+1); jCurWav++ )
													WordWavCombo[iCurWord][jCurWav] = WordWavCombo[iCurWord+1][jCurWav]
											}
										}
									}
								}
								// If we're about to copy a string that doesn't exist,
								// then just erase the last string instead of copying.
								if( jCurWav >= MAX_RANDOM ){
									// Delete the last Wav string
									if ( joinex == 1 )
										Join_wavs[TOK_LENGTH*(jCurWav-1)] = 0
									else if ( joinex == 2 )
										Exit_wavs[TOK_LENGTH*(jCurWav-1)] = 0
									else
										WordWavCombo[iCurWord][TOK_LENGTH*jCurWav] = 0
									// We reached the end
									client_print(id,print_console,"%s successfully removed from %s", Wav, Word)
									return PLUGIN_HANDLED
								}else{
									// Copy the next string over the current string
									if ( joinex == 1 )
										copy(Join_wavs[TOK_LENGTH*(jCurWav-1)], TOK_LENGTH, Join_wavs[TOK_LENGTH*jCurWav])
									else if ( joinex == 2 )
										copy(Exit_wavs[TOK_LENGTH*(jCurWav-1)], TOK_LENGTH, Exit_wavs[TOK_LENGTH*jCurWav])
									else
										copy(WordWavCombo[iCurWord][TOK_LENGTH*jCurWav], TOK_LENGTH, WordWavCombo[iCurWord][TOK_LENGTH*(jCurWav+1)])
								}
							}
						}
					}
					// We reached the end for this Word, and the Wav didn't exist
					client_print(id,print_console,"Sank Sound Plugin >> %s not found",  Wav)
					return PLUGIN_HANDLED
				}
			}
		}
		// We reached the end, and the Word didn't exist
		client_print(id,print_console,"Sank Sound Plugin >> %s not found", Word)
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Saves the current configuration of Word/Wav combos to filename for possible
// reloading at a later time. You cannot overwrite the default file.
//
// Usage: admin_sound_write <filename>
//////////////////////////////////////////////////////////////////////////////
public amx_sound_write(id,level,cid){
	if ( cmd_access(id,level,cid,2) ){
		new savefile[128], TimeStamp[128], name[33], Text[TOK_LENGTH*MAX_RANDOM+1]
		new bSuccess = 1
		
		get_user_name(id,name,32)
		read_argv(1,savefile,127)
		get_time("%H:%M:%S %A %B %d, %Y",TimeStamp,127)
		// If the filename is NULL, then that's bad
		if ( strlen(savefile) == 0 ){
			client_print(id,print_console,"Sank Sound Plugin >> You must specify a filename")
			return PLUGIN_HANDLED
		}
		// If the filename is the same as the default FILENAME, then that's bad
		if ( equali(savefile, FILENAME) ){
			client_print(id,print_console,"Sank Sound Plugin >> Illegal write to default sound config file")
			client_print(id,print_console,"Sank Sound Plugin >> Specify a different filename")
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
		SND_DELAY;		0
		SND_SPLIT;		0
		EXACT_MATCH;		1
		ADMINS_ONLY;		0
	
		# Word/Wav combinations:
		crap;			misc/awwcrap.Wav;misc/awwcrap2.wav
		woohoo;			misc/woohoo.wav
		@ha ha;			misc/haha.wav
		doh;			misc/doh.wav;misc/doh2.wav;@misc/doh3.wav
	
		******************************************************************/
		
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
		
		new join_snd_buff[TOK_LENGTH*MAX_RANDOM], exit_snd_buff[TOK_LENGTH*MAX_RANDOM]
		new i
		for( i = 0; i < MAX_RANDOM; i++ ){
			new tempstr[TOK_LENGTH]
			if ( strlen(Join_wavs[TOK_LENGTH*i]) ){
				format(tempstr,TOK_LENGTH,"%s;",Join_wavs[TOK_LENGTH*i])
				add(join_snd_buff[MAX_RANDOM*i],TOK_LENGTH,tempstr)
			}
			if ( strlen(Exit_wavs[TOK_LENGTH*i]) ){
				format(tempstr,TOK_LENGTH,"%s;",Exit_wavs[TOK_LENGTH*i])
				add(exit_snd_buff[MAX_RANDOM*i],TOK_LENGTH,tempstr)
			}
		}
		format(Text, 127, "SND_JOIN;^t^t%s", join_snd_buff)
		write_file(savefile, Text)
		format(Text, 127, "SND_EXIT;^t^t%s", exit_snd_buff)
		write_file(savefile, Text)
		format(Text, 127, "SND_DELAY;^t^t%d", SND_DELAY)
		write_file(savefile, Text)
		format(Text, 127, "SND_SPLIT;^t^t%d", SND_SPLIT)
		write_file(savefile, Text)
		format(Text, 127, "EXACT_MATCH;^t^t%d", EXACT_MATCH)
		write_file(savefile, Text)
		format(Text, 127, "ADMINS_ONLY;^t^t%d", ADMINS_ONLY)
		write_file(savefile, Text)
		write_file(savefile, "")		// blank line
		write_file(savefile, "# Word/Wav combinations:")
		
		for ( i = 0; i < MAX_KEYWORDS && bSuccess; i++ ){
			// See if we reached the end
			if ( strlen(WordWavCombo[i]) == 0 )
				break
			
			// First, add the keyWord
			format(Text, TOK_LENGTH*MAX_RANDOM, "%s;^t^t^t", WordWavCombo[i])
			// Then add all the Wavs
			new j
			for ( j = 1; j < MAX_RANDOM && strlen(WordWavCombo[i][TOK_LENGTH*j]); j++ )
				format(Text, TOK_LENGTH*MAX_RANDOM, "%s%s;", Text, WordWavCombo[i][TOK_LENGTH*j])
			
			// Now write the formatted string to the file
			bSuccess = write_file(savefile, Text)
			// And loop for the next Wav
		}
	
		client_print(id,print_console,"Sank Sound Plugin >> Configuration successfully written to %s", savefile)
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
public amx_sound_print_matrix(id,level,cid){
	if ( cmd_access(id,level,cid,1) || !id ){
		new i, j, join_snd_buff[TOK_LENGTH*MAX_RANDOM], exit_snd_buff[TOK_LENGTH*MAX_RANDOM]
		
		server_print("SND_WARN: %d^n", SND_WARN)
		server_print("SND_MAX: %d^n", SND_MAX)
		for( i = 0; i < MAX_RANDOM; i++ ){
			new tempstr[TOK_LENGTH]
			if ( strlen(Join_wavs[TOK_LENGTH*i]) ){
				format(tempstr,TOK_LENGTH,"%s;",Join_wavs[TOK_LENGTH*i])
				add(join_snd_buff,TOK_LENGTH*MAX_RANDOM,tempstr)
			}
			if ( strlen(Exit_wavs[TOK_LENGTH*i]) ){
				format(tempstr,TOK_LENGTH,"%s;",Exit_wavs[TOK_LENGTH*i])
				add(exit_snd_buff,TOK_LENGTH*MAX_RANDOM,tempstr)
			}
		}
		server_print("SND_JOIN: %s^n", join_snd_buff)
		server_print("SND_EXIT: %s^n", exit_snd_buff)
		server_print("SND_DELAY: %d^n", SND_DELAY)
		server_print("SND_SPLIT: %d^n", SND_SPLIT)
		server_print("EXACT_MATCH: %d^n", EXACT_MATCH)
		server_print("ADMINS_ONLY: %d^n", ADMINS_ONLY)
	
		// Print out the matrix of sound data, so we got what we think we did
		for( i = 0; i < MAX_KEYWORDS; i++ ){
			if ( strlen(WordWavCombo[i]) != 0 ){
				server_print("^n[%d] ^"%s^"", i, WordWavCombo[i][0])
				for( j = 1; j < MAX_RANDOM+1; j++ ){
					if ( strlen(WordWavCombo[i][j*TOK_LENGTH]) != 0 )
						server_print(" ^"%s^"", WordWavCombo[i][j*TOK_LENGTH])
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////
// Everything a person says goes through here, and we determine if we want to
// play a sound or not.
//
// Usage: say <anything>
//////////////////////////////////////////////////////////////////////////////
public HandleSay(id){
	new ListIndex = -1
	// If sounds are not enabled, then skip this whole thing
	if ( !bSoundsEnabled )
		return PLUGIN_CONTINUE
	
	new Speech[128]
	read_args(Speech,127)
	remove_quotes(Speech)
	
	// credit to SR71Goku for fixing this oversight:
	if( !strlen(Speech) )
		return PLUGIN_CONTINUE
	
	if ( equal(Speech,"/sounds",7) ){
		if ( Speech[7] == 'o' && Speech[8] == 'n' && Speech[9] == 0 )
			SndOn[id] = 1
		else if ( Speech[7] == 'o' && Speech[8] == 'f' && Speech[9] == 'f' && Speech[10] == 0 )
			SndOn[id] = 0
		else if ( Speech[7] == 0 )
			print_sound_list(id,1)
		
		return PLUGIN_HANDLED
	}
	
	if ( get_gametime() - LastSoundTime < SND_DELAY){
		client_print(id,print_chat,"Sank Sound Plugin >> Minimum sound delay time not yet reached")
		return PLUGIN_CONTINUE
	}
	
	// Remove @ from user's speech, incase non-admin is trying to impersonate real admin
	replace(Speech, 127, "@","")
	
	// Check to see if what the player said is a trigger for a sound
	new i, Text[TOK_LENGTH+1]
	for ( i = 0; i < MAX_KEYWORDS; i++ ){
		copy(Text, TOK_LENGTH, WordWavCombo[i])
		
		// Remove the possible @ sign from beginning (for admins only)
		if ( get_user_flags(id)&ACCESS_ADMIN )
			replace(Text, TOK_LENGTH, "@","")
		if ( equali(Speech, Text) || ( EXACT_MATCH == 0 && containi(Speech, Text) != -1 ) ){
			ListIndex = i
			break
		}
	}
	
	// If what the player said is a sound trigger, then handle it
	if ( ListIndex != -1 ){
		#if DEBUG
		new name[33]
		get_user_name(id,name,32)
		client_print(id,print_console,"Checking Quota for %i:  %s in %s^n", name, Text, Speech)
		#endif
		
		// If the user has not exceeded their quota, then play a Wav
		if ( !QuotaExceeded(id) ){
			new rand = random(MAX_RANDOM)
			new timeout
			new playFile[TOK_LENGTH]

			// This for loop runs around until it finds a real file to play
			// Defaults to the first Wav file, if no file is found at random.
			for( timeout = MAX_RANDOM;			// Initial condition
				timeout >= 0 && !strlen(playFile);	// While these are true
				timeout--, rand = random(MAX_RANDOM) ){	// Update each iteration
				// If for some reason we never find a file
				//  then default to the first Wav entry
				if ( !timeout )
					rand = 0

				copy(playFile, TOK_LENGTH, WordWavCombo[ListIndex][(rand+1)*TOK_LENGTH])

				// If this Wav was an admin-only Wav, but User is not an admin, then skip this one
				if ( equal(playFile, "@", 1) ){
					if ( !access(id,ACCESS_ADMIN) )
						playFile[0] = 0
					else
						replace(playFile, TOK_LENGTH, "@","")
				}
			}

			LastSoundTime = get_gametime()
			playsoundall(playFile, is_user_alive(id))
		}else
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
parse_sound_file(loadfile[]){
	new GotLine
	new iLineNum = 0, ListIndex = 0
	new strLineBuf[(MAX_RANDOM+1)*TOK_LENGTH], Text[128]
	new WadOstrings[(MAX_RANDOM+1)*TOK_LENGTH]	// same as [MAX_RANDOM][TOK_LENGTH]

	/************ File should have the following format: **************

	# Set the necessary variables
	SND_MAX;	20
	SND_WARN;	17
	SND_JOIN;	misc/hi.wav
	SND_EXIT;	misc/comeagain.wav
	SND_DELAY;	0
	SND_SPLIT;	0
	EXACT_MATCH;	1
	ADMINS_ONLY;	0

	# Now give the sound list
	crap;	misc/awwcrap.Wav;misc/awwcrap2.wav
	woohoo;	misc/woohoo.wav
	@ha ha;	misc/haha.wav
	doh;	misc/doh.wav;misc/doh2.wav;@misc/doh3.wav

	******************************************************************/
	
	if ( strlen(loadfile) == 0 )
		copy(loadfile, 127, FILENAME)
	if ( file_exists(loadfile) ){
		new i, temp = 0
		GotLine = read_file(loadfile, iLineNum, strLineBuf, MAX_RANDOM*TOK_LENGTH,temp)
		if ( GotLine <= 0 ){
			log_amx("Sank Sound Plugin >> Unable to read from %s file", loadfile)
			return -1
		}
		// Initialize WordWavCombo[][][] array before using it
		for( i = 0; i < MAX_KEYWORDS; i++ )
			WordWavCombo[i][0] = 0
		while ( ( GotLine = read_file(loadfile, iLineNum++, strLineBuf, MAX_RANDOM*TOK_LENGTH,temp) ) > 0 ){
			if ( ListIndex >= MAX_KEYWORDS ){
				log_amx("Sank Sound Plugin >> Sound list truncated. Increase MAX KEYWORDS")
				log_amx("Sank Sound Plugin >> Stopped parsing %s file^n", loadfile)
				break
			}
			// As long as the line isn't commented out, and isn't blank, then process it.
			if ( !equal(strLineBuf, "#", 1) && !equal(strLineBuf, "//", 2) && ( strlen(strLineBuf) != 0 ) ){
				new fatal_error
				// Take up to MAX_RANDOM Wav files for each keyWord, each separated by a ';'
				// Right now we fill the big WadOstrings[] with the information from the file.
				new is_wordwav_combo = 1
				for( i = 0; i <= MAX_RANDOM; i++ ){
					new temp_str[128]
					new check_for_semi = ( containi(strLineBuf,";") != -1 )
					if ( check_for_semi )
						copyc(temp_str,127,strLineBuf,';')
					else
						copy(temp_str,127,strLineBuf)
					
					new to_replace[127]
					format(to_replace,127,"%s%s",temp_str,check_for_semi ? ";" : "")
					replace(strLineBuf,MAX_RANDOM*TOK_LENGTH,to_replace,"")
					
					// Now remove any spaces or tabs from around the strings -- clean them up
					trim_spaces(temp_str)
					
					// check if file lenght is bigger than array
					if ( strlen(temp_str) > TOK_LENGTH ){
						log_amx("Sank Sound Plugin >> Word or Wav is too long: ^"%s^". It is %i but max is %i (change name/remove spaces in config or increase TOK LENGTH)",temp_str,strlen(temp_str),TOK_LENGTH)
						log_amx("Sank Sound Plugin >> Skipping this word/wav combo")
						fatal_error = 1
						break
					}
					
					// check if file exists, if not skip it
					if ( !i ){	// first is not a sound file
						if ( equali(temp_str,"SND_MAX") || equali(temp_str, "SND_WARN") || equali(temp_str, "SND_DELAY") || equali(temp_str, "SND_SPLIT") || equali(temp_str, "EXACT_MATCH") || equali(temp_str, "ADMINS_ONLY") )
							is_wordwav_combo = 0
					}else if ( is_wordwav_combo && strlen(temp_str) ){
						// check if not speech sounds
						if ( ( temp_str[0] != '@' && temp_str[0] != '^"' ) || ( temp_str[0] == '@' && temp_str[1] != '^"' ) ){
							new file_name[128]
							copy(file_name,127,temp_str)
							replace(file_name, TOK_LENGTH, "@","")
							if ( containi(file_name,".mp3") == -1 )		// ".mp3" in not in the string
								format(file_name,127,"sound/%s",file_name)
							if ( !file_exists(file_name) ){
								log_amx("Sank Sound Plugin >> Trying to load a file that dont exist. Skipping this file: ^"%s^"",file_name)
								i--
								continue
							}
						}
					}
					
					// sound exists and has correct lenght, so copy it into our big array
					copy(WadOstrings[TOK_LENGTH*i],TOK_LENGTH,temp_str)
					
					if ( !strlen(strLineBuf) ){
						strLineBuf[0] = 0
						break
					}
				}
				// If we finished MAX_RANDOM times, and strRest still has contents
				//  then we should have a bigger MAX_RANDOM
				if( strlen(strLineBuf) != 0 && !fatal_error ){
					log_amx("Sank Sound Plugin >> Sound list partially truncated. Increase MAX RANDOM")
					log_amx("Sank Sound Plugin >> Continuing to parse ^"%s^" file^n", loadfile)
				}
				
				// No error occured so continue
				if ( !fatal_error ){
					// First look for special parameters
					if ( equali(WadOstrings, "SND_MAX") )
						SND_MAX = str_to_num(WadOstrings[TOK_LENGTH*1])
					else if ( equali(WadOstrings, "SND_WARN") )
						SND_WARN = str_to_num(WadOstrings[TOK_LENGTH*1])
					else if ( equali(WadOstrings, "SND_JOIN") ){
						Join_snd_num = 0
						for( new j = 0; j < MAX_RANDOM; j++ ){
							copy(Join_wavs[TOK_LENGTH*j], TOK_LENGTH, WadOstrings[TOK_LENGTH*(j+1)])
							if ( strlen(Join_wavs[TOK_LENGTH*j]) )
								Join_snd_num += 1
						}
					}else if ( equali(WadOstrings, "SND_EXIT") ){
						Exit_snd_num = 0
						for( new j = 0; j < MAX_RANDOM; j++ ){
							copy(Exit_wavs[TOK_LENGTH*j], TOK_LENGTH, WadOstrings[TOK_LENGTH*(j+1)])
							if ( strlen(Exit_wavs[TOK_LENGTH*j]) )
								Exit_snd_num += 1
						}
					}else if ( equali(WadOstrings, "SND_DELAY") )
						SND_DELAY = str_to_num(WadOstrings[TOK_LENGTH*1])
					else if ( equali(WadOstrings, "SND_SPLIT") )
						SND_SPLIT = str_to_num(WadOstrings[TOK_LENGTH*1])
					else if ( equali(WadOstrings, "EXACT_MATCH") )
						EXACT_MATCH = str_to_num(WadOstrings[TOK_LENGTH*1])
					else if ( equali(WadOstrings, "ADMINS_ONLY") )
						ADMINS_ONLY = str_to_num(WadOstrings[TOK_LENGTH*1])
	
					// If it wasn't one of those essential parameters, then it should be
					//  a Keyword/Wav combo, so we'll treat it as such by copying it from our
					//  temporary structure into our global structure, WordWavCombo[][][]
					else{
						// Now we must transfer the contents of WadOstrings[] to
						//  our global data structure, WordWavCombo[Index][]
						//  with a really tricky "string copy"
						for ( i = 0; i < MAX_RANDOM*TOK_LENGTH; i++ )
							WordWavCombo[ListIndex][i] = WadOstrings[i]
						
						ListIndex++
					}
				}
			}
			// Initialize variables for next time  by clearing all the
			//  strings in the WadOstrings[]
			for ( i = 0; i < MAX_RANDOM; i++ )
				WadOstrings[i*TOK_LENGTH] = 0
			
			// Read in the next line from the file
			//GotLine = read_file(loadfile, iLineNum++, strLineBuf, MAX_RANDOM*TOK_LENGTH,temp)
		}
		// Now we have all of the data from the text file in our data structures.
		// Next we do some error checking, some setup, and we're done parsing!
		ErrorCheck()
		
		#if DEBUG
		// Log some info for the nosey admin
		log_amx("Sank Sound Plugin >> Sound quota set to %i", SND_MAX)
		
		amx_sound_print_matrix(0,0,0)
		server_print("Sank Sound Plugin >> Done parsing ^"%s^" file^n", loadfile)
		#endif
	}else{ // file exists returned false, meaning the file didn't exist
		format(Text, 127, "Sank Sound Plugin >> Cannot find ^"%s^" file", loadfile)
		log_amx(Text)
		server_print(Text)
		return 1
	}
	
#if ALLOW_SORT == 1
	HeapSort(ListIndex)
#endif
	
	server_print("Sank Sound Plugin >> ^"%s^" successfully loaded", loadfile)
	return 0
}

//////////////////////////////////////////////////////////////////////////////
// Returns 0 if the user is allowed to say things
// Returns 1 and mutes the user if the quota has been exceeded.
//////////////////////////////////////////////////////////////////////////////
QuotaExceeded(id){
	// If the sound limitation is disabled, then return happily.
	if ( SND_MAX == 0 )
		return 0

	// If the user is not really a user, then maybe a bot, maybe a bug...?
	if ( !is_user_connected(id) )
		return 0
	
	// check if is admin
	new admin_check = ( get_user_flags(id)&ACCESS_ADMIN )
	
	if ( ADMINS_ONLY && !admin_check )
		return 1
	
	if ( !admin_check ){
		new HowManyLeft = SND_MAX - SndCount[id]
		if ( SndCount[id] >= SND_MAX ){
			client_print(id,print_chat,"Sank Sound Plugin >> You were warned, you are muted")
			return 1
		}else if ( SndCount[id] >= SND_WARN ){
			client_print(id,print_chat,"Sank Sound Plugin >> You have almost used up your sound quota. Stop")
			client_print(id,print_chat,"Sank Sound Plugin >> You have %d left before you get muted", HowManyLeft)
		}

		// Increment their playsound count
		SndCount[id] = SndCount[id] + 1
	}
	return 0
}

//////////////////////////////////////////////////////////////////////////////
// Checks the input variables for invalid values
//////////////////////////////////////////////////////////////////////////////
ErrorCheck(){
	// Can't have negative delay between sounds
	if ( SND_DELAY < 0 ){
		log_amx("Sank Sound Plugin >> SND_DELAY cannot be negative")
		log_amx("Sank Sound Plugin >> SND_DELAY set to default value 0")
		SND_DELAY = 0
	}
	// If SND_MAX is zero, then sounds quota is disabled. Can't have negative quota
	if ( SND_MAX < 0 ){
		SND_MAX = 0	// in case it was negative
		log_amx("Sank Sound Plugin >> SND_MAX cannot be negative. Setting to value 0")
	}
	// If SND_WARN is zero, then we can't have warning every
	// time a keyWord is said, so we default to 3 less than max
	else if ( ( SND_WARN <= 0 && SND_MAX != 0 ) || SND_MAX < SND_WARN ){
		if ( SND_MAX > 3 )
			SND_WARN = SND_MAX - 3
		else
			SND_WARN = SND_MAX - 1
		
		if ( SND_MAX < SND_WARN  ){
			// And finally, if they want to warn after a person has been
			// muted, that's silly, so we'll fix it.
			log_amx("Sank Sound Plugin >> SND_WARN cannot be higher than SND_MAX")
			log_amx("Sank Sound Plugin >> SND_WARN set to default value")
		}else{
			log_amx("Sank Sound Plugin >> SND_WARN cannot be set to zero")
			log_amx("Sank Sound Plugin >> SND_WARN set to default value")
		}
	}
}

playsoundall(sound[], alive = 1){
	remove_quotes(sound)
	replace(sound,127," ^t","")
#if defined MP3_SUPPORT
	new is_mp3 = ( containi(sound,".mp3") != -1 )
#endif
	for( new i = 1; i <= g_max_players; i++ ){
		if ( is_user_connected(i) && !is_user_bot(i) ){
			if ( SndOn[i] ){
				if ( SND_SPLIT ){
					if ( is_user_alive(i) == alive ){
#if defined MP3_SUPPORT
						if ( is_mp3 )
							client_cmd(i,"mp3 play ^"%s^"",sound)
						else
#endif
							client_cmd(i,"spk ^"%s^"",sound)
					}
				}else{
#if defined MP3_SUPPORT
					if ( is_mp3 )
						client_cmd(i,"mp3 play ^"%s^"",sound)
					else
#endif
						client_cmd(i,"spk ^"%s^"",sound)
				}
			}
		}
	}
}

trim_spaces(str_to_trim[]){
	new lenght = strlen(str_to_trim)
	new char_end
	if ( lenght ){
		new j, char_start, char_num, char_found
		for( j = 0; j < lenght; j++ ){
			if ( isspace(str_to_trim[j]) ){
				if ( !char_found )
					char_start += 1
				else
					char_num += 1
			}else{
				char_found = 1
				char_num += 1
				char_end = char_num
			}
		}
		if ( char_start > 0 ){
			for( j = 0; j < char_end; j++ ){
				str_to_trim[j] = str_to_trim[char_start+j]
			}
		}
		
	}
	str_to_trim[char_end] = 0
	return str_to_trim
}

print_sound_list(id, motd_msg = 0){
	new text[256], motd_buffer[2048], ilen
	new info_text[64] = "say <keyword>: Plays a sound. Keywords are listed below:^n"
	if ( motd_msg )
		ilen = format(motd_buffer,2047,"<body bgcolor=#000000><font color=#FFB000><pre>%s",info_text)
	else
		client_print(id,print_console,info_text)
	// Loop once for each keyword
	new i, j = -1
	for( i = 0; i < MAX_KEYWORDS; i++ ){
		// If an invalid string, then break this loop
		if( strlen(WordWavCombo[i]) == 0 || strlen(WordWavCombo[i]) > TOK_LENGTH )
			break
		
		// check if player can see admin sounds
		j += 1
		new found_stricted = 0
		if ( contain(WordWavCombo[i],"@") != -1 ){
			if ( get_user_flags(id)&ACCESS_ADMIN ){
				if ( motd_msg )
					ilen += format(motd_buffer[ilen],2047-ilen,"%s",WordWavCombo[i])
				else
					add(text,255,WordWavCombo[i])
			}else{
				j -= 1
				found_stricted = 1
			}
		}else{
			if ( motd_msg )
				ilen += format(motd_buffer[ilen],2047-ilen,"%s",WordWavCombo[i])
			else
				add(text,255,WordWavCombo[i])
		}
		if ( !found_stricted ){
			if( j % NUM_PER_LINE == NUM_PER_LINE - 1 ){
				// We got NUM_PER_LINE on this line,
				//  so print it and start on the next line
				if ( motd_msg )
					ilen += format(motd_buffer[ilen],2047-ilen,"^n")
				else{
					client_print(id,print_console,"%s^n",text)
					text[0] = 0
				}
			}else{
				if ( motd_msg )
					ilen += format(motd_buffer[ilen],2047-ilen," | ")
				else
					add(text,255, " | ")
			}
		}
	}
	if ( motd_msg && strlen(motd_buffer) )
		show_motd(id,motd_buffer)
	else if( strlen(text) )
		client_print(id,print_console,text)
}

// 4 functions for array sort ( by Bailopan )
stock HeapSort(ListIndex){
	new i
	new aSize = ( ListIndex / 2 ) - 1
	for ( i = aSize; i >= 0; i-- )
		SiftDown(i, ListIndex)
	
	for ( i = ListIndex - 1; i >= 1; i-- ){
		switch_array_elements(0,i)
		SiftDown(0, i-1)
	}
}

stock fstrcmp(str1[], str2[]){
	new i = 0
	for ( i = 0; i < TOK_LENGTH; i++ ){
		if ( str1[i] != str2[i] ){
			if ( str1[i] > str2[i] )
				return 1
			else
				return -1
		}
	}
	return 0
}

stock SiftDown(root, bottom){
	new done, child
	while ( ( root * 2 <= bottom ) && !done ){
		if ( root * 2 == bottom )
			child = root * 2
		else if ( fstrcmp(WordWavCombo[root * 2], WordWavCombo[root * 2 + 1]) > 0 )
			child = root * 2
		else
			child = root * 2 + 1
		
		if ( fstrcmp(WordWavCombo[root], WordWavCombo[child]) < 0 ){
			switch_array_elements(root,child)
			root = child
		}else
			done = 1
	}
}

stock switch_array_elements(element_one,element_two){
	new temp_str[TOK_LENGTH*(MAX_RANDOM+1)], i
	for ( i = 0; i < TOK_LENGTH*(MAX_RANDOM+1); i++ )
		temp_str[i] = WordWavCombo[element_one][i]
	for ( i = 0; i < TOK_LENGTH*(MAX_RANDOM+1); i++ )
		WordWavCombo[element_one][i] = WordWavCombo[element_two][i]
	for ( i = 0; i < TOK_LENGTH*(MAX_RANDOM+1); i++ )
		WordWavCombo[element_two][i] = temp_str[i]
}