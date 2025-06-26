package states;

#if sys
import sys.thread.Thread;
#end

#if DISCORD_ALLOWED
import utilities.Discord.DiscordClient;
#end

import utilities.MusicUtilities;
import modding.scripts.languages.HScript;
import modding.ModList;
import game.Conductor;
import utilities.Options;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import lime.app.Application;
import flixel.tweens.FlxTween;
import game.Song;
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
import flixel.effects.FlxFlicker;
// CARAJO DEITY DECIDE POR UNA VEZ LLEVO CAMBIANDO ESTE CODIGO 5 VECES 

import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

import states.SongsSubstate;

using StringTools;
using utilities.BackgroundUtil;


class CharterSelectorState extends MusicBeatState{
	var charters:Array<CharterMetaData> = [];

	private var grpCharters:FlxTypedGroup<Alphabet>;
	var chartersHola:FlxTypedGroup<FlxSprite>;

	static var curSelected:Int = 0;

	public static var charterSelected:String = "Story Mode";
	public static var charterIconSelected:String = "story";

	private var bg:FlxSprite;
	private var selectedColor:Int = 0xFF7F1833;
	private var charterBG:FlxSprite;

	public static var chartersReady:Bool = false;

	var canChooseCharter:Bool = true;

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

	// thx psych engine devs
	var colorTween:FlxTween;

	public var loading_charter:#if cpp Thread #else Dynamic #end;
	public var stop_loading_charter:Bool = false;

	var lastSelectedSong:Int = -1;

	/**
		Current instance of `CharterSelectorState`.
	**/
	public static var instance:CharterSelectorState = null;
	public inline function call(func:String, ?args:Array<Dynamic>) {
		if (stateScript != null ) stateScript.call(func, args);
	}
	

	override function create() {
		MusicBeatState.windowNameSuffix = " - Selecting Mode...";

		Conductor.changeBPM(102);

		var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			TitleState.playTitleMusic();
		
		#if NO_PRELOAD_ALL
		if (!chartersReady) {
			Assets.loadLibrary("songs").onComplete(function(_) {
				FlxTween.tween(black, {alpha: 0}, 0.5, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween) {
						remove(black);
						black.kill();
						black.destroy();
					}
				});

				chartersReady = true;
			});
		}
		#else
		chartersReady = true;
		#end

		var initCharterlist = CoolUtil.coolTextFile(Paths.txt('freeplaylist/modeList'));

		if(curSelected > initCharterlist.length)
			curSelected = 0;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Selecting Mode...", null);
		#end

		// Loops through all songs in chartersList.txt
		for (i in 0...initCharterlist.length) {
			if (initCharterlist[i].trim() != "") {
				// Creates an array of their strings
				var listArray = initCharterlist[i].split(":");

				// Variables I like yes mmmm tasty
				var charter = listArray[0];
				var icon = listArray[1];

				var color = listArray[2];
				var actualColor:Null<FlxColor> = null;

				if (color != null)
					actualColor = FlxColor.fromString(color);

				// similar to songmetadata
				charters.push(new CharterMetaData(charter, icon, actualColor));
			}
		}

		bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,[FlxColor.BLACK, FlxColor.fromString("#05ea2f")] , 1, 90, true);
		bg.antialiasing = Options.getData("antialiasing");
		bg.scrollFactor.set(0, 0); // que no siga la cámara
		add(bg);

		grpCharters = new FlxTypedGroup<Alphabet>();
		add(grpCharters);

		charterBG = new FlxSprite(0, -260).makeGraphic(FlxG.width, 360, FlxColor.BLACK);
		charterBG.alpha = 0.6;
		add(charterBG);

		var selectText:Alphabet = new Alphabet(0, 18,'Select Your Mode', true, false);
		selectText.isMenuItemCenter = true;
		add(selectText);

		chartersHola = new FlxTypedGroup<FlxSprite>();
		add(chartersHola);

		// Suponiendo que charters.length == 3
		for (i in 0...charters.length) {
			// factor: 0.0 para el primero, 0.5 para el segundo, 1.0 para el tercero
			var factor:Float = (10 * i) / (charters.length - 1);

			// posición X a lo largo de todo el ancho
			var xPos:Float = factor * FlxG.width;

			// Texto
			var charterText:Alphabet = new Alphabet((50 * i) - (FlxG.width / 2), 150, charters[i].charterName, true, false);
			charterText.isMenuItemCenter = true;
			charterText.isCharter = true;
			charterText.targetX = i;

			grpCharters.add(charterText);

			// Icono
			var icon:FlxSprite = new FlxSprite().loadGraphic(Paths.image("freeplay/menu/" + charters[i].charterIcon + "-icon"));
			icon.ID = i;
			icon.antialiasing = Options.getData("antialiasing");
			icon.screenCenter(X);
			chartersHola.add(icon);
		}


		if (!chartersReady) {
			add(black);
		} else {
			remove(black);
			black.kill();
			black.destroy();

			chartersReady = false;

			new FlxTimer().start(1, function(_) chartersReady = true);
		}

		if (charters.length != 0 && curSelected >= 0){
			selectedColor = charters[curSelected].color;
			bg.color = selectedColor;
		} else {
			bg.color = 0xFF7C689E;
		}

		super.create();
		call("createPost");
	}

	public function addCharter(charter:String, charterIcon:String) {
		call("addCharter", [charter, charterIcon]);
		charters.push(new CharterMetaData(charter, charterIcon));
		call("addCharterPost", [charter, charterIcon]);
	}

	var enteringCharter:Bool = false;

	override function update(elapsed:Float) {
		call("update", [elapsed]);

		super.update(elapsed);

		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		charterSelected = charters[curSelected].charterName;
		charterIconSelected = charters[curSelected].charterIcon;

		if (chartersReady) {
			if (-1 * Math.floor(FlxG.mouse.wheel) != 0  && !enteringCharter)
				changeSelection(-1 * Math.floor(FlxG.mouse.wheel));

			if (leftP && !enteringCharter){
				changeSelection(-1);
			}
			if (rightP && !enteringCharter){
				changeSelection(1);
			}

			if (controls.BACK && !enteringCharter) {
				if (colorTween != null)
					colorTween.cancel();

				#if cpp
				stop_loading_charter = true;
				#end

				FlxG.switchState(new MainMenuState());
			}
			
			if (FlxG.keys.justPressed.ENTER && canChooseCharter && !enteringCharter) {
				if (Assets.exists(Paths.txt("freeplaylist/" + charterIconSelected + 'Songlist'))) {
					FlxG.sound.play(Paths.sound('confirmMenu'));

					enteringCharter = true;
					
					trace("selected " + charterSelected + " charts");

					chartersHola.forEach(function(spr:FlxSprite) {
						if (curSelected == spr.ID)
							FlxFlicker.flicker(spr, 1, 0.06, false, false);
					});
					FlxG.switchState(new SongsSubstate());

					} else {

					CoolUtil.coolError(charterSelected + " doesn't match with any of the songlists files!\nTry fixing it's name in the songlists carpet.",
						"Leather Engine's No Crash, We Help Fix Stuff Tool");
				}
			}
		}

		chartersHola.forEach(function(spr:FlxSprite) {
			var menoresX = FlxMath.remapToRange(spr.ID, 0, 1, 0, 2);

			var menoresLerp:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
			 var factors:Array<Float> = [0.2, 0.5, 0.8];

   		 // tomamos el factor según el ID
   		 var factor:Float = factors[spr.ID];
    		var t:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);

			// posición objetivo centrada en la pantalla
			var targetX:Float = factor * FlxG.width;

			var centeredX:Float = targetX - spr.width * 0.5;
    		spr.x = FlxMath.lerp(spr.x, centeredX, menoresLerp);
			spr.y = FlxG.height - spr.height - 10;

			if (curSelected != spr.ID)
				spr.alpha = 0.4;
			else
				spr.alpha = 1;

			spr.scale.x = FlxMath.lerp(spr.scale.x, 1, elapsed * 6);
			spr.scale.y = FlxMath.lerp(spr.scale.y, 1, elapsed * 6);
		});

		
		
		
		
		call("updatePost", [elapsed]);
	}

	override function closeSubState() {
		changeSelection();
		FlxG.mouse.visible = false;
		super.closeSubState();
	}

	function changeSelection(change:Int = 0) {
		call("changeSelection", [change]);
		
		if(grpCharters.length <= 0) {
			return;
		}

		curSelected = FlxMath.wrap(curSelected + change, 0, grpCharters.length - 1);

		// Sounds

		// Scroll Sound
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (change != 0 && charters.length != 0) {
			var newColor:FlxColor = charters[curSelected].color;

			if (newColor != selectedColor) {
				if (colorTween != null) {
					colorTween.cancel();
				}

				selectedColor = newColor;

				colorTween = FlxTween.color(bg, 0.125, bg.color, selectedColor, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
				});
			}
		} else{
			if(charters.length != 0){
				bg.color = charters[curSelected].color;
			}
		}

		var semenDeCaballo:Int = 0;

		for (item in grpCharters.members) {
			item.targetX = semenDeCaballo - curSelected;
			semenDeCaballo++;
			item.alpha = 0.4;

			if (item.targetX == 0) {
				item.alpha = 1;
			}
		}
		
		call("changeSelectionPost", [change]);
	}

	override function beatHit() {
		super.beatHit();

		chartersHola.forEach(function(spr:FlxSprite) {
			if (spr != null)
				spr.scale.set(1.05, 1.05);
		});

		call("beatHit");
	}
}

class CharterMetaData {
	public var charterName:String = "Story Mode";
	public var charterIcon:String = "story";
	public var color:FlxColor = FlxColor.GRAY;

	public function new(?charter:String, ?charterIcon:String, ?color:FlxColor) {
		this.charterName = charter;

		this.charterIcon = charterIcon;
		if (color != null)
			this.color = color;
		else {
			this.color = CharterSelectorState.coolColors[0];
		}
	}
}