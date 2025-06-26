package states;

#if (target.threaded)
import sys.thread.Thread;
#end
#if DISCORD_ALLOWED
import utilities.Discord.DiscordClient;
#end
import modding.scripts.languages.HScript;
import modding.ModList;
import game.Conductor;
import utilities.Options;
import flixel.util.FlxTimer;
import substates.ResetScoreSubstate;
import flixel.sound.FlxSound;
import lime.app.Application;
import flixel.tweens.FlxTween;
import game.SongLoader;
import game.Highscore;
import ui.HealthIcon;
import ui.Alphabet;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.graphics.frames.FlxAtlasFrames;
// CARAJO DEITY DECIDE POR UNA VEZ LLEVO CAMBIANDO ESTE CODIGO 5 VECES 

import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;


using StringTools;
using utilities.BackgroundUtil;

class FreeplayState extends MusicBeatState {
	public var songs:Array<SongMetadata> = [];

	public var selector:FlxText;

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;
	public static var curSpeed:Float = 1;

	public var scoreText:FlxText;
	//public var diffText:FlxText;
	public var speedText:FlxText;
	public var lerpScore:Int = 0;
	public var intendedScore:Int = 0;

	public var grpSongs:FlxTypedGroup<Alphabet>;
	public var curPlaying:Bool = false;

	public var iconArray:Array<HealthIcon> = [];

	public static var songsReady:Bool = false;

	public static var coolColors:Array<Int> = [
		0xFF7F1833,
		0xFF7C689E,
		-14535868,
		0xFFA8E060,
		0xFFFF87FF,
		0xFF8EE8FF,
		0xFFFF8CCD,
		0xFFFF9900,
		0xFF735EB0
	];

	public var bg:FlxSprite;
	public var selectedColor:Int = 0xFF7F1833;
	public var scoreBG:FlxSprite;

	public var curRank:String = "N/A";

	var ports:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	var songPortMap:Map<String, String> = new Map<String, String>();

	public var curDiffString:String = "normal";
	public var curDiffArray:Array<String> = ["easy", "normal", "hard"];
	var diffImageMap:Map<String, String> = [ // Solo dejar canon y 4kmania y god mode
		"NORMAL" => "normal",
		"EASY" => "easy",
		"HARD" => "hard",
		"MANIA" => "4kmania",
		"CANON" => "canon",
	];

	public var vocals:FlxSound = new FlxSound();

	public var canEnterSong:Bool = true;

	// thx psych engine devs
	public var colorTween:FlxTween;

	#if (target.threaded)
	public var loading_songs:Thread;
	public var stop_loading_songs:Bool = false;
	#end

	public var lastSelectedSong:Int = -1;

	/**
		Current instance of `FreeplayState`.
	**/
	public static var instance:FreeplayState = null;

	private var poster:FlxSprite;


	public inline function call(func:String, ?args:Array<Dynamic>) {
		if (stateScript != null)
			stateScript.call(func, args);
	}

	private var initSonglist:Array<String> = [];
	var difficultySprite:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var leftArrowsong:FlxSprite;
	var rightArrowsong:FlxSprite;
	var arrowbar:FlxSprite;

	var scrollSpeed:Float = 30; // píxeles por segundo

	var arrowHomeY:Float;
    var arrowHomeY2:Float;

    var lineas:FlxBackdrop;

	private var Catagories:Array<String> = ['dave', 'joke', 'extras'];

	private var CurrentPack:Int = 0;

	override function create() {
		instance = this;

		MusicBeatState.windowNameSuffix = " Freeplay";

		var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);

		#if NO_PRELOAD_ALL
		if (!songsReady) {
			Assets.loadLibrary("songs").onComplete(function(_) {
				FlxTween.tween(black, {alpha: 0}, 0.5, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween) {
						remove(black);
						black.kill();
						black.destroy();
					}
				});

				songsReady = true;
			});
		}
		#else
		songsReady = true;
		#end

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			TitleState.playTitleMusic();
		#if MODDING_ALLOWED
		if (!ModList.modList.get(Options.getData("curMod"))) {
			Options.setData("Friday Night Funkin'", "curMod");
			CoolUtil.coolError("Hmmm... I couldnt find the mod you are trying to switch to.\nIt is either disabled or not in the files.\nI switched the mod to base game to avoid a crash!",
				"Leather Engine's No Crash, We Help Fix Stuff Tool");
			CoolUtil.setWindowIcon("mods/" + Options.getData("curMod") + "/_polymod_icon.png");
		}
		if (sys.FileSystem.exists("mods/" + Options.getData("curMod") + "/data/freeplaySonglist.txt"))
			initSonglist = CoolUtil.coolTextFileSys("mods/" + Options.getData("curMod") + "/data/freeplaySonglist.txt");
		else if (sys.FileSystem.exists("mods/" + Options.getData("curMod") + "/_append/data/freeplaySongList.txt"))
			initSonglist = CoolUtil.coolTextFileSys("mods/" + Options.getData("curMod") + "/_append/data/freeplaySongList.txt");
		else if (sys.FileSystem.exists("mods/" + Options.getData("curMod") + "/_append/data/freeplaySonglist.txt"))
			initSonglist = CoolUtil.coolTextFileSys("mods/" + Options.getData("curMod") + "/_append/data/freeplaySonglist.txt");
		#else
		initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		#end

		if (curSelected > initSonglist.length)
			curSelected = 0;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		// Loops through all songs in freeplaySonglist.txt
		for (i in 0...initSonglist.length) {
			if (initSonglist[i].trim() != "") {
				// Creates an array of their strings
				var listArray = initSonglist[i].split(":");

				// Variables I like yes mmmm tasty
				var week = Std.parseInt(listArray[2]);
				var icon = listArray[1];
				var song = listArray[0];

				var diffsStr = listArray[3];
				var diffs = ["easy", "normal", "hard"];
				// Poner el poster code

				var color = listArray[4];
				var actualColor:Null<FlxColor> = null;

				if (color != null)
					actualColor = FlxColor.fromString(color);

				if (diffsStr != null)
					diffs = diffsStr.split(",");

				if (listArray[5] != null)
					{
						songPortMap.set(song, listArray[5]);
					}

				// Creates new song data accordingly
				songs.push(new SongMetadata(song, week, icon, diffs, actualColor));
			}
		}

		bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,[FlxColor.BLACK, FlxColor.fromString("#E1E1E1")] , 1, 90, true);
		bg.antialiasing = Options.getData("antialiasing");
		bg.scrollFactor.set(0, 0); // que no siga la cámara
		add(bg);

		lineas = new FlxBackdrop(
            Paths.image("freeplay/menu/cosa2"), // textura
            FlxAxes.XY,                        // tileo en X y en Y
            0,      // velocidad de scroll X
            1.16    // velocidad de scroll Y
        );
        lineas.antialiasing = Options.getData("antialiasing");
        lineas.screenCenter();    // centra el tileo… opcional
        lineas.y += 50;
        lineas.x += 25;
        // scrollFactor muy bajo para dar sensación de profundidad
        lineas.scrollFactor.set(0, 0.07);
		lineas.velocity.set(0, 40);
        add(lineas);

		var portList = CoolUtil.coolTextFile(Paths.file('images/freeplay/ports/data.txt'));
		for (portName in portList)
		{
			if (Options.getData("charsAndBGs"))
			{
				var port = new FlxSprite().loadGraphic(Paths.image('freeplay/ports/' + portName));

				if (port.width < 500 || port.height < 500)
				{
					var scaleX:Float = 500 / port.width;
					var scaleY:Float = 500 / port.height;
					// Se toma el menor de los dos para que ninguna dimensión supere los 500 pixeles
					var scaleFactor:Float = Math.min(scaleX, scaleY);
					port.scale.set(scaleFactor, scaleFactor);
					port.updateHitbox();
				}
							
				
				// Si la imagen es muy grande, ajusta su escala proporcionalmente
				else if (port.width > 500 || port.height > 500)
				{
					var scaleX:Float = 500 / port.width;
					var scaleY:Float = 500 / port.height;
					// Se toma el menor de los dos para que ninguna dimensión supere los 500 pixeles
					var scaleFactor:Float = Math.min(scaleX, scaleY);
					port.scale.set(scaleFactor, scaleFactor);
					port.updateHitbox();
				}
				
				port.alpha = 0;
				port.screenCenter();
				// Alinear a la izquierda y centrar verticalmente
				//port.x -= 90; // moverlo muy poco
				port.x = (FlxG.width - port.width) / 1.05;
				/*
				if (port.x > 0)
				{
					port.x = 0;
				}
				
				if (port.x + port.width > FlxG.width){
					port.x += 0;
				}
				*/
				port.y += 0; // moverlo muy poco
				add(port);
				ports.set(portName, port);
			}
		}


		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		scoreText = new FlxText(FlxG.width, 630, 0, "", 40);
		scoreText.antialiasing = Options.getData("antialiasing");

		scoreBG = new FlxSprite(scoreText.x, 0).makeGraphic(1, 1, FlxColor.BLACK);
		scoreBG.screenCenter(X);
		scoreBG.alpha = 0.0;

		scoreText.setFormat(Paths.font("contb.ttf"), 40, FlxColor.WHITE, RIGHT);

		// Antes estaba centrado a la derecha; ahora se ubica en la izquierda abajo.
		/*
		diffText = new FlxText(10, FlxG.height - 70, FlxG.width - 20, "", 32);
		diffText.font = scoreText.font;
		diffText.alignment = RIGHT;
		*/

		var arrow_Tex:FlxAtlasFrames = Paths.getSparrowAtlas('campaign menu/ui_arrow');

		leftArrow = new FlxSprite(840, FlxG.height - 720);
		leftArrow.frames = arrow_Tex;
		leftArrow.animation.addByPrefix('idle', "arrow0");
		leftArrow.animation.addByPrefix('press', "arrow push", 24, false);
		leftArrow.animation.play('idle');

		difficultySprite = new FlxSprite(leftArrow.x + leftArrow.width + 4, leftArrow.y);
		difficultySprite.loadGraphic(Paths.gpuBitmap("campaign menu/difficulties/default/"+curDiffString));
		difficultySprite.updateHitbox();

		rightArrow = new FlxSprite(difficultySprite.x + difficultySprite.width + 4, leftArrow.y);
		rightArrow.frames = arrow_Tex;
		rightArrow.animation.addByPrefix('idle', 'arrow0');
		rightArrow.animation.addByPrefix('press', "arrow push", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.flipX = true;

		leftArrowsong = new FlxSprite(0, 0).loadGraphic(Paths.image("freeplay/menu/flechamenu"));
		leftArrowsong.updateHitbox();
		leftArrowsong.antialiasing = false;
		leftArrowsong.screenCenter();
		leftArrowsong.scale.set(0.7, 0.7);
		leftArrowsong.y -= 230 - 150 - 10;
		leftArrowsong.x -= 300 + 295 + 15;

		rightArrowsong = new FlxSprite(0, 0).loadGraphic(Paths.image("freeplay/menu/flechamenu"));
		rightArrowsong.updateHitbox();
		rightArrowsong.antialiasing = false;
		rightArrowsong.screenCenter();
		rightArrowsong.scale.set(0.7, 0.7);
		rightArrowsong.angle = 180;
		rightArrowsong.y += 270 - 150 - 10;
		rightArrowsong.x -= 300 + 295 + 15;

		speedText = new FlxText(scoreText.x, scoreText.y + 33, 0, "", 30);
		speedText.font = scoreText.font;
		speedText.alignment = RIGHT;
		speedText.antialiasing = Options.getData("antialiasing");

		arrowbar = new FlxSprite().makeGraphic(80, 1000, FlxColor.BLACK);
		arrowbar.screenCenter();
		arrowbar.x = leftArrowsong.x;

		arrowHomeY = leftArrowsong.y;
		arrowHomeY2 = leftArrowsong.y;


		#if (target.threaded)
		if (!Options.getData("loadAsynchronously") || !Options.getData("healthIcons")) {
		#end
			for (i in 0...songs.length) {
				var scaleShit = (13 / songs[i].songName.length); // Suck it 
 				if (songs[i].songName.length <= 13)
 					scaleShit = 1;
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, scaleShit);
				songText.isMenuItem = true;
				songText.targetY = i;

				grpSongs.add(songText);

				if (Options.getData("healthIcons")) {
					var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);
				}
			}
		#if (target.threaded)
		}
		else {
			loading_songs = Thread.create(function() {
				var i:Int = 0;

				while (!stop_loading_songs && i < songs.length) {
					var scaleShit = (13 / songs[i].songName.length); // Suck it 
					if (songs[i].songName.length <= 13)
						scaleShit = 1;
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30 , songs[i].songName, true, false,scaleShit);
					songText.isMenuItem = true;
					songText.targetY = i;

					grpSongs.add(songText);

					var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
					icon.sprTracker = songText;
					iconArray.push(icon);
					add(icon);

					i++;
				}
			});
		}
		#end

		

		// layering
		add(scoreBG);
		add(scoreText);
		//add(diffText);
		add(leftArrow);
		add(difficultySprite);
		add(rightArrow);
		add(speedText);
		add(arrowbar);
		add(leftArrowsong);
		add(rightArrowsong);


		selector = new FlxText();

		selector.size = 40;
		selector.text = "<";

		if (!songsReady) {
			add(black);
		} else {
			remove(black);
			black.kill();
			black.destroy();

			songsReady = false;

			new FlxTimer().start(1, function(_) songsReady = true);
		}

		if (songs.length != 0 && curSelected >= 0 && curSelected < songs.length) {
			selectedColor = songs[curSelected].color;
			bg.color = selectedColor;
		} else {
			bg.color = 0xFF7C689E;
		}

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, FlxColor.BLACK);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press RESET to reset song score and rank ~ Press SPACE to play Song Audio ~ Shift + LEFT and RIGHT to change song speed";
		#else
		var leText:String = "Press RESET to reset song score ~ Shift + LEFT and RIGHT to change song speed";
		#end

		infoText = new FlxText(textBG.x - 1, textBG.y + 4, FlxG.width, leText, 18);
		infoText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		infoText.scrollFactor.set();
		infoText.screenCenter(X);
		add(infoText);

		super.create();
		call("createPost");
	}

	public var mix:String = null;

	public var infoText:FlxText;

	public function addSong(songName:String, weekNum:Int, songCharacter:String) {
		call("addSong", [songName, weekNum, songCharacter]);
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
		call("addSongPost", [songName, weekNum, songCharacter]);
	}

	override function update(elapsed:Float) {
		call("update", [elapsed]);
		#if sys
		if (FlxG.keys.justPressed.TAB) {
			openSubState(new modding.SwitchModSubstate());
			persistentUpdate = false;
		}
		#end

		super.update(elapsed);

		leftArrowsong.y = FlxMath.lerp(leftArrowsong.y, arrowHomeY + 50, elapsed*8);
		rightArrowsong.y = FlxMath.lerp(rightArrowsong.y, arrowHomeY2 + 150, elapsed*8);
		
		if (songs.length > 0)
		{
			for (portName => port in ports)
				{
					var alp = 0;
					if (songPortMap.exists(songs[curSelected].songName))
					{
						if (songPortMap.get(songs[curSelected].songName) == portName)
							alp = 1;
					}
					port.alpha = FlxMath.lerp(port.alpha, alp, elapsed*5);
				}
		}

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;

		for (i in 0...iconArray.length) {
			if (i == lastSelectedSong)
				continue;

			iconArray[i].scale.set(iconArray[i].startSize, iconArray[i].startSize);
		}

		if (lastSelectedSong != -1 && iconArray[lastSelectedSong] != null)
			iconArray[lastSelectedSong].scale.set(FlxMath.lerp(iconArray[lastSelectedSong].scale.x, iconArray[lastSelectedSong].startSize, elapsed * 9),
				FlxMath.lerp(iconArray[lastSelectedSong].scale.y, 1, elapsed * 9));

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		
		scoreBG.x = FlxG.width - 6;

		if (Std.int(scoreBG.width) != Std.int(scoreText.width + 6))
			scoreBG.makeGraphic(Std.int(scoreText.width + 6), 108, FlxColor.BLACK);

		scoreText.x = FlxG.width - scoreText.width - 50;
		scoreText.text = "PERSONAL BEST:" + lerpScore;

		//diffText.x = FlxG.width - diffText.width;

		curSpeed = FlxMath.roundDecimal(curSpeed, 2);

		if (curSpeed < 0.25)
			curSpeed = 0.25;

		speedText.text = "Speed: " + curSpeed + " (R+SHIFT)";
		speedText.x = FlxG.width - speedText.width - 50;

		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var shift = FlxG.keys.pressed.SHIFT;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;

		if (songsReady) {
			if (-1 * Math.floor(FlxG.mouse.wheel) != 0 && !shift)
				changeSelection(-1 * Math.floor(FlxG.mouse.wheel));
			else if (-1 * (Math.floor(FlxG.mouse.wheel) / 10) != 0 && shift)
				curSpeed += -1 * (Math.floor(FlxG.mouse.wheel) / 10);

			if (upP)
				changeSelection(-1);
			if (downP)
				changeSelection(1);

			if (leftP && !shift)
				changeDiff(-1);
			else if (leftP && shift)
				curSpeed -= 0.05;

			if (rightP && !shift)
				changeDiff(1);
			else if (rightP && shift)
				curSpeed += 0.05;

			if (FlxG.keys.justPressed.R && shift)
				curSpeed = 1;

			if (controls.BACK) {
				if (colorTween != null)
					colorTween.cancel();

				if (vocals.active && vocals.playing)
					destroyFreeplayVocals(false);
				if (FlxG.sound.music.active && FlxG.sound.music.playing)
					FlxG.sound.music.pitch = 1;

				#if (target.threaded)
				stop_loading_songs = true;
				#end

				FlxG.switchState(new CharterSelectorState());
			}

			#if PRELOAD_ALL
			if (FlxG.keys.justPressed.SPACE) {
				destroyFreeplayVocals();

				// TODO: maybe change this idrc actually it seems ok now
				if (Assets.exists(SongLoader.getPath(curDiffString, songs[curSelected].songName.toLowerCase(), mix))) {
					PlayState.SONG = SongLoader.loadFromJson(curDiffString, songs[curSelected].songName.toLowerCase(), mix);
					Conductor.changeBPM(PlayState.SONG.bpm, curSpeed);
				}

				vocals = new FlxSound();

				var voicesDiff:String = (PlayState.SONG != null ? (PlayState.SONG.specialAudioName ?? curDiffString.toLowerCase()) : curDiffString.toLowerCase());
				var voicesPath:String = Paths.voices(songs[curSelected].songName.toLowerCase(), voicesDiff, mix ?? '');

				if (Assets.exists(voicesPath))
					vocals.loadEmbedded(voicesPath);

				vocals.persist = false;
				vocals.looped = true;
				vocals.volume = 0.7;

				FlxG.sound.list.add(vocals);

				FlxG.sound.music = new FlxSound().loadEmbedded(Paths.inst(songs[curSelected].songName.toLowerCase(), curDiffString.toLowerCase(), mix));
				FlxG.sound.music.persist = true;
				FlxG.sound.music.looped = true;
				FlxG.sound.music.volume = 0.7;

				FlxG.sound.list.add(FlxG.sound.music);

				FlxG.sound.music.play();
				vocals.play();

				lastSelectedSong = curSelected;
			}
			#end

			if (FlxG.sound.music.active && FlxG.sound.music.playing && !FlxG.keys.justPressed.ENTER)
				FlxG.sound.music.pitch = curSpeed;
			if (vocals != null && vocals.active && vocals.playing && !FlxG.keys.justPressed.ENTER)
				vocals.pitch = curSpeed;

			if (controls.RESET && !shift) {
				openSubState(new ResetScoreSubstate(songs[curSelected].songName, curDiffString));
				changeSelection();
			}

			if (FlxG.keys.justPressed.ENTER && canEnterSong) {
				playSong(songs[curSelected].songName, curDiffString);
			}
		}
		call("updatePost", [elapsed]);
	}

	// TODO: Make less nested

	/**
		 * Plays a specific song
		 * @param songName
		 * @param diff
		 */
	public function playSong(songName:String, diff:String) {
		if (!CoolUtil.songExists(songName, diff, mix)) {
			CoolUtil.coolError(songName.toLowerCase() + " doesn't match with any song audio files!\nTry fixing it's name in freeplaySonglist.txt",
				"Leather Engine's No Crash, We Help Fix Stuff Tool");
			return;
		}
		PlayState.SONG = SongLoader.loadFromJson(diff, songName.toLowerCase(), mix);
		if (!Assets.exists(Paths.inst(PlayState.SONG.song, diff.toLowerCase(), mix))) {
			if (Assets.exists(Paths.inst(songName.toLowerCase(), diff.toLowerCase(), mix)))
				CoolUtil.coolError(PlayState.SONG.song.toLowerCase() + " (JSON) does not match " + songName + " (FREEPLAY)\nTry making them the same.",
					"Leather Engine's No Crash, We Help Fix Stuff Tool");
			else
				CoolUtil.coolError("Your song seems to not have an Inst.ogg, check the folder name in 'songs'!",
					"Leather Engine's No Crash, We Help Fix Stuff Tool");
			return;
		}
		PlayState.isStoryMode = false;
		PlayState.songMultiplier = curSpeed;
		PlayState.storyDifficultyStr = diff.toUpperCase();

		PlayState.storyWeek = songs[curSelected].week;

		#if (target.threaded)
		stop_loading_songs = true;
		#end

		colorTween?.cancel();

		PlayState.loadChartEvents = true;
		destroyFreeplayVocals();
		FlxG.switchState(() -> new PlayState());
	}

	override function closeSubState() {
		changeSelection();
		FlxG.mouse.visible = false;
		super.closeSubState();
	}

	function changeDiff(change:Int = 0) {
		call("changeDiff", [change]);
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, curDiffArray.length - 1);
		curDiffString = curDiffArray[curDifficulty].toUpperCase();

		if (difficultySprite == null)
			return;
		if (diffImageMap.exists(curDiffString))
		{
			difficultySprite.loadGraphic(Paths.image("campaign menu/difficulties/default/"+diffImageMap.get(curDiffString)));
			//difficultyImage.y = diffBGThing.y+(diffBGThing.height*0.5)-(difficultyImage.height*0.5);
			leftArrow.x = difficultySprite.x-leftArrow.width;
			rightArrow.x = difficultySprite.x+difficultySprite.width;
		}

		if (songs.length != 0) {
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDiffString);
			curRank = Highscore.getSongRank(songs[curSelected].songName, curDiffString);
		}

		/*
		if (curDiffArray.length > 1)
			diffText.text = "< " + curDiffString + " ~ " + curRank + " >";
		else
			diffText.text = curDiffString + " ~ " + curRank + "  ";
		
		// Cambia el color según la dificultad
		switch(curDiffString.toLowerCase()) {
			case "easy":
				 diffText.color = FlxColor.GREEN;
			case "normal":
				 diffText.color = FlxColor.YELLOW;
			case "hard":
				 diffText.color = FlxColor.RED;
			case "canon":
				diffText.color = FlxColor.WHITE;
			case "old":
				diffText.color = FlxColor.GRAY;
			default:
				 diffText.color = FlxColor.WHITE;
		}
		 */
		
		call("changeDiffPost", [change]);
	}

	function changeSelection(change:Int = 0) {
		call("changeSelection", [change]);

		if (grpSongs.length <= 0) {
			return;
		}
		
		curSelected = FlxMath.wrap(curSelected + change, 0, grpSongs.length - 1);

		if (change != 0)
			{
				if (change > 0)
					rightArrowsong.y += 20; //funni bopping thing
				else 
					leftArrowsong.y -= 20;
			}

		// Sounds

		// Scroll Sound
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		// Song Inst
		if (Options.getData("freeplayMusic") && curSelected <= 0) {
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName, curDiffString.toLowerCase()), 0.7);

			if (vocals.active && vocals.playing)
				destroyFreeplayVocals(false);
		}

		if (songs.length != 0) {
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDiffString);
			curRank = Highscore.getSongRank(songs[curSelected].songName, curDiffString);
		}

		if (songs.length != 0) {
			curDiffArray = songs[curSelected].difficulties;
			changeDiff();
		}

		var bullShit:Float = 0;

		
		if (iconArray.length > 0) {
			// 1. Reinicia todos los iconos (ocultándolos)
			for (i in 0...iconArray.length) {
				iconArray[i].alpha = 0.6;
				if (iconArray[i].animation.curAnim != null)
					iconArray[i].animation.play("neutral");
			}

			/*
			if (curSelected - 1 > iconArray.length) {
				iconArray[curSelected - 1].alpha = 0.6;
				if (iconArray[curSelected - 1].animation.curAnim != null)
					iconArray[curSelected - 1].animation.play("neutral");
			}
			
			// 3. Muestra el icono de la canción seleccionada, centrado y sin cambios en su alpha (siempre 1)
			if (curSelected >= 0 && curSelected < iconArray.length) {
				iconArray[curSelected].alpha = 1;
				if (iconArray[curSelected].animation.curAnim != null)
					iconArray[curSelected].animation.play("win");
			}
			
			// 4. Si existe, muestra el icono siguiente con alpha 0.6, posicionado a la derecha
			if (curSelected + 1 < iconArray.length) {
				iconArray[curSelected + 1].alpha = 0.6;
				if (iconArray[curSelected + 1].animation.curAnim != null)
					iconArray[curSelected + 1].animation.play("neutral");
			}
				*/

				if (iconArray != null && curSelected >= 0 && (curSelected <= iconArray.length) && iconArray.length != 0) {
					iconArray[curSelected].alpha = 1;
					iconArray[curSelected].animation.play("win");
				}
		}
		

		//var baseY:Float = FlxG.height * 1; // Centrado horizontalmente, pero más abajo (75% de la altura)
		var spacing:Float = 1; // Espaciado reducido entre items

		for (item in grpSongs.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;
			// Ubica cada item en función de su offset respecto al seleccionado:
			//item.y = baseY + (spacing * item.targetY);

			/*
			// Ajusta alpha y escala según su posición relativa:
			switch (item.targetY) {
				case 0:
					// Item seleccionado
					item.alpha = 1;
				case -1, 1:
					// Item anterior y siguiente
					item.alpha = 0.6;
				case -2, 2:
					// Item anterior y siguiente
					item.alpha = 0.6;
				default:
					// Oculta el resto
					item.alpha = 0;
			}
					*/
					item.alpha = 0.6;

			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}


		if (change != 0 && songs.length != 0) {
			var newColor:FlxColor = songs[curSelected].color;

			if (newColor != selectedColor) {
				if (colorTween != null) {
					colorTween.cancel();
				}

				selectedColor = newColor;

				colorTween = FlxTween.color(bg, 0.25, bg.color, selectedColor, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
				});
			}
		} else {
			if (songs.length != 0) {
				bg.color = songs[curSelected].color;
			}
		}
		call("changeSelectionPost", [change]);
	}

	public function destroyFreeplayVocals(?destroyInst:Bool = true) {
		call("destroyFreeplayVocals", [destroyInst]);
		if (vocals != null) {
			vocals.stop();
			vocals.destroy();
		}

		vocals = null;

		if (!destroyInst)
			return;

		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
			FlxG.sound.music.destroy();
		}

		FlxG.sound.music = null;
		call("destroyFreeplayVocalsPost", [destroyInst]);
	}

	override function beatHit() {
		call("beatHit");
		super.beatHit();

		if (lastSelectedSong != -1 && iconArray[lastSelectedSong] != null)
			iconArray[lastSelectedSong].scale.add(0.2, 0.2);
		call("beatHitPost");
	}
}

class SongMetadata {
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var difficulties:Array<String> = ["easy", "normal", "hard"];
	public var color:FlxColor = FlxColor.GREEN;

	public function new(song:String, week:Int, songCharacter:String, ?difficulties:Array<String>, ?color:FlxColor) {
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;

		if (difficulties != null)
			this.difficulties = difficulties;

		if (color != null)
			this.color = color;
		else {
			if (FreeplayState.coolColors.length - 1 >= this.week)
				this.color = FreeplayState.coolColors[this.week];
			else
				this.color = FreeplayState.coolColors[0];
		}
	}
}
