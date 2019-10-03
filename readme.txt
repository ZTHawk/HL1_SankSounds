1.1) Installation
1.2) How is the configfile structured ?

2.1) Special-Options inside configfile
2.2) WAV, MP3 and SPEECH correctly inside configfile
2.3) Adding a new keyword/sound
2.4) Custom access levels per Word/Sound

3) CVAR's and their description

4.1) WAV is not equal WAV, here is the corrrect format
4.2) More sounds added than working/displayed ?
4.3) Plugin is not working or problems with sounds ?
4.4) Server crashed ?

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 1.1)

- Put the configfile "snd-list.cfg" to "addons/amxmodx/configs" folder
- put the "sank_sounds.amxx" file to AmxModX plugins folder

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 1.2)

- Filenames may not contain spaces

- File has to look like this:
	SND_MAX;		20			// maximum of sounds a player can use each map
	SND_MAX_DUR		180.0			// maximum lenght of sounds in seconds a player can play each map
	SND_WARN;		17			// how many sounds a player can use until he gets a warning how many sounds left each map
	SND_JOIN;		sound/misc/hi.wav		// sounds that are played when someone joins
	SND_EXIT;		sound/misc/comeagain.wav	// sounds that are played when someone leaves
	SND_DELAY;		0.0			// time to wait between 2 sounds
	SND_MODE;		15			// Determinates who can play and who can hear sounds (dead and alive)
	SND_IMMUNITY;		"l"         // Determine the access levels which shall have immunity to warn/kick/ban (default ADMIN_LEVEL_A for backwards compatability)
	                                // "ab" = everyone with flag "a" or "b" has immunity
	                                // "" = noone will have immunity (quotes are important!)
	EXACT_MATCH;		1			// defines if word in chat must be exactly what is defined in config or be a part of sentence
	ADMINS_ONLY;		0			// defines if only admins can use sounds
	DISPLAY_KEYWORDS;	1			// set to 0 if you do not want the keywords of sounds to be displayed in chat

	# Word/Wav combinations:
	crap;			sound/misc/awwcrap.Wav;sound/misc/awwcrap2.wav
	woohoo;			sound/misc/woohoo.wav
	@ha ha;			sound/misc/haha.wav
	doh;			sound/misc/doh.wav;sound/misc/doh2.wav;@sound/misc/doh3.wav
	mp3;			sound/mymp3.mp3;music/mymp3s/number2.mp3;mainfolder.mp3
	target;			"target destroyed"
	
	mapname TESTMAP
	testmap;		music/doh.wav
	mapname TESTMAP2
	testmap2;		maps/haha.wav;sound/mymp3.mp3
	testmap3;		sound/misc/hi.wav
	mapnameonly TESTMAP3
	testmap3;		sound/misc/hi.wav
	
	package 1
	haha2;			sound/misc/haha.wav
	doh3;			sound/misc/doh3.wav
	package 2
	hi;				sound/misc/hi.wav
	
	modspecific
	<keyword>;		<location>/<name>.wav

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 2.1)

SND_MODE:
Choose options below add add then together
1   = dead can play sounds
2   = alive can play sounds
4   = dead can hear sounds
8   = alive can hear sounds
16  = alive and dead are isolated
32  = dead can hear sounds from alive ( even if isolated )
64  = alive can hear sounds from dead ( even if isolated )
128 = bots can use sounds

eg: 1 + 4 = 5, means only dead can play and hear sounds

The three options 16 + 32 + 64 together are the same as if you do not set any of them

Additional Configs: ( those are optional )

mapname:
	- type mapname <space> the real mapname (without .bsp) (eg: mapname de_dust)
	- everthing below this line will only be precached on this map but used on every map

mapnameonly:
	- type mapnameonly <space> the real mapname (without .bsp) (eg: mapname de_dust)
	- everthing below this line will only be used on this map

package:
	- type package <space> number (eg: package 2)
	- everthing below will be loaded only once and switched to next package on map-change
	- if only one package this package will be used on every map-change

modspecific:
	- every sound below that line must be inside half-life.gcf or <yourmod>.gcf (eg: counter-strike.gcf)
	- if you add other files (eg: you are running CS and add sounds from TFC) they may/will crash your server as these sounds are assumed to be existent

INFO:
mapname		= precaching of sounds on specified map, BUT you can use sounds on all maps
mapnameonly	= precaching of sounds on specified map, BUT you can only use these sounds on this map

INFO2:
Starting a new OPTION will result that the following sounds are bound to that option ONLY.

EG:
mapname de_dust
haha;		misc/haha.wav
mapname cs_italy
hi;		misc/hi.wav

"misc/hi.wav" is bound to option "mapname cs_italy"

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 2.2)

Different sound types need different settings:

WAV files: and
MP3 Files:
	- base directory is "mod-dir/"
	- put the EXACT PATH to the mp3
	- when your sound is loacted in "cstrike/sound/misc/good.mp3" then you have to add to conifg "sound/misc/good.mp3"
SPEECH Files:
	- base directory is "mod-dir/sound/vox/"
	- these files are inside the steam package
	- speech sounds must be put in quotes (eg: target; "target destroyed")
	you may not put different speech types into 1 speech or the speech will not be played
	speech without directory is used from "vox/.."
	first specify the speech type (ONLY ONCE eg hgrunt/) and then put the words with spaces between each speech
	eg "hgrunt/yessir barney/stop1" will not work as 2 different speeches
	BUT "hgrunt/yessir no" will work
	find all available speech sounds here:
		"http://www.adminmod.org/help/online/Admin_Mod_Reference/Half_Life_Sounds.htm"

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 2.3)

- When you want to add a new keyword add it somewhere below "# Word/Wav combinations:" as a NEW line.
- Adding a " @ " infront of a keyword will make that keyword only accessable for ADMINs.
- After each keyword and between sounds there MUST be a " ; " .
- Sounds that are bound to a keyword must be in the same line !!!
- Adding a " @ " infront of a sound will make that sound only accessable for ADMINs. So if keyword is
  public and it has 2 sounds, 1 public and one with an " @ " this will result in:
  when players uses this keyword only this one sound can be played, BUT if ADMIN uses this keyword
  it is possible to that the second one is played.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 2.4)

Infront of a word/sound add @<ACCESS_LEVELS>@
Replace <ACCESS_LEVELS> with the access levels you desire

eg:
@abc@hallo;   sound/misc/hallo.wav; @ab@sound/misc/hi.wav

the keyword "hallo" can be used by everyone with access "a", "b" or "c"
only players with access "a" or "b" may play "sound/misc/hi.wav"
BUT all can play "sound/misc/hallo.wav"

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 3)

CVARS:

"mp_sank_sounds_download" 0 or 1 :

This one enables or disables the "Internal download system"
In other word, Sank Sounds will take care so players will download all sounds

"mp_sank_sounds_freezetime" <time in seconds> :

This one defines how long to wait till first join/leave sound is played after mapchange
(to prevent mass sound spamm on map change)

"mp_sank_sounds_obey_duration" <mode> :

This one defines who has to obey the sound duration before they can play a sound again.
0 = noone
1 = public
2 = admins
4 = RCON

eg: 1 + 2 = 3, means normal players and normal admins have to obey sound duration
7, means that RCON admins have to obey sound duration too

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 4.1)

The WAVs you create yourself must have this format:
- PCM
- mono
- maximum 22 KHz
- 8 or 16 bit

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 4.2)

When you have problems with sounds check your server console and amxmodX logs.
The logs are located in "<mod-dir>/addons/amxmodx/logs/L<month><day>.log".
Open it (with notepad).
A Log made by Sank Sounds looks like this:
"L <month>/<day>/<year> - <time>: [sank_sounds.amxx] Sank Sound Plugin >> XXXXX"

XXXXX is the message that is important.
It tells you what is wrong.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 4.3)

If you added many sounds and not all are played possibly you have more than
Sank Sounds support by default ( default = 80 ).
You will need to open the .sma and search these lines and adjust their values:

#define MAX_KEYWORDS	80	// Maximum number of keywords
#define MAX_RANDOM	15	// Maximum number of wavs per keyword
#define TOK_LENGTH	60	// Maximum length of keyword and wav/mp3 file strings
#define MAX_BANS	32	// Maximum number of bans stored
#define NUM_PER_LINE	6	// Number of words per line from amx_sound_help

BUT attention:
( MAX_RANDOM + 1 ) * TOK_LENGTH must be smaller than 2048

eg default:
( 15 + 1 ) * 60 = 960

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 4.4)

a)

If you get an error like:
"Host_Error: PF_precache_sound_I : Sound ´fgrunt/medic.wav´ failed to precache because
the item count is over the 512 limit."
you will need to decrease your amount of sounds
this is a Half-Life bug, there is NO way to fix this

b)

SERVER CRASH:
This can only happen when the "Internal download system" is on (or these sounds are downloaded by another plugin)
You have 2 possibilities:

1) Disable the "Internal download system" by changing the cvar "mp_sank_sounds_download" to 0
In server console "mp_sank_sounds_download 0"
Or to make it permanent, add this line to amxmodx.cfg:
"mp_sank_sounds_download 0"

2) Decrease your sound list

IMPORTANT:
Using other download plugins for all sounds will NOT help. This is a HL bug and NOT possible to fix.