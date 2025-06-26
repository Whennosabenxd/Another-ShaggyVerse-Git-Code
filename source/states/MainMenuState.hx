package states;

#if DISCORD_ALLOWED
import utilities.Discord.DiscordClient;
#end
#if MODDING_ALLOWED
import modding.PolymodHandler;
#end
import modding.scripts.languages.HScript;
import flixel.system.debug.interaction.tools.Tool;
import utilities.Options;
import flixel.util.FlxTimer;
import utilities.MusicUtilities;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import flixel.util.FlxGradient;


using utilities.BackgroundUtil;

class MainMenuState extends MusicBeatState {
	/**
		Current instance of `MainMenuState`.
	**/
	public static var instance:MainMenuState = null;

	static var curSelected:Int = 0;

	public var menuItems:FlxTypedGroup<FlxSprite>;

	public var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];

	public var bg:FlxSprite;
	public var negro:FlxSprite;


	public var logoBl:FlxSprite;
	public var camFollow:FlxObject;
	public var lineas:FlxBackdrop;

	var ports:Map<String, FlxSprite> = new Map<String, FlxSprite>();


	public inline function call(func:String, ?args:Array<Dynamic>) {
		if (stateScript != null) {
			stateScript.call(func, args);
		}
	}

	public override function create() {
		instance = this;

		#if MODDING_ALLOWED
		if (PolymodHandler.metadataArrays.length > 0)
			optionShit.push('mods');
		#end

		if (Options.getData("developer"))
			optionShit.push('toolbox');

		call("buttonsAdded");

		MusicBeatState.windowNameSuffix = "";

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music == null || !FlxG.sound.music.playing || OptionsMenu.playing) {
			OptionsMenu.playing = false;
			TitleState.playTitleMusic();
		}

		persistentUpdate = persistentDraw = true;

		bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,[FlxColor.fromString("#238a07"), FlxColor.fromString("#37ff00")] , 1, 90, true);
		bg.antialiasing = Options.getData("antialiasing");
		bg.scrollFactor.set(0, 0); // que no siga la cámara
		add(bg);

		negro = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/menu/MINIATURAS_INSANIDI"));
		negro.scrollFactor.set(0, 0); // que no siga la cámara
		negro.screenCenter(X);
		add(negro);

		lineas = new FlxBackdrop(
            Paths.image("freeplay/menu/cosa2"), // textura
            FlxAxes.XY,                        // tileo en X y en Y
            0,      // velocidad de scroll X
            1.0    // velocidad de scroll Y
        );
        lineas.antialiasing = Options.getData("antialiasing");
        lineas.screenCenter();    // centra el tileo… opcional
        lineas.y += 0;
        lineas.x += 50;
        // scrollFactor muy bajo para dar sensación de profundidad
        lineas.scrollFactor.set(0, 0.07);
		lineas.velocity.set(0, 20);
        add(lineas);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);


		logoBl = new FlxSprite(0, 0);
		logoBl.x += 100;
		logoBl.y += 70;
		logoBl.frames = Paths.getSparrowAtlas('title/logoBumpin');
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.scrollFactor.set(0, 0); // que no siga la cámara
		logoBl.scale.set(0.4, 0.4);
		logoBl.updateHitbox();
		logoBl.antialiasing = false;
		add(logoBl);

		var portList = CoolUtil.coolTextFile(Paths.file('images/freeplay/ports/data.txt'));
		for (portName in portList)
		{
			if (Options.getData("charsAndBGs"))
			{
				var port = new FlxSprite().loadGraphic(Paths.image('freeplay/main/'+'anectota'));
				port.alpha = 1;
				port.scale.set(0.7, 0.7);
				port.updateHitbox();				
				port.screenCenter();
				port.scrollFactor.set(0, 0); // que no siga la cámara
				port.x -= 310;
				port.y += 70;
				add(port);
				ports.set(portName, port);
			}
	
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length) {
			var menuItem:FlxSprite = new FlxSprite(20, 60 + (i * 160));
			if (!Assets.exists(Paths.image('ui skins/' + Options.getData("uiSkin") + '/' + 'buttons/' + optionShit[i], 'preload')))
				menuItem.frames = Paths.getSparrowAtlas('ui skins/' + 'default' + '/' + 'buttons/' + optionShit[i], 'preload');
			else
				menuItem.frames = Paths.getSparrowAtlas('ui skins/' + Options.getData("uiSkin") + '/' + 'buttons/' + optionShit[i], 'preload');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.x += 700;
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.updateHitbox();
			menuItem.scrollFactor.set(0.45, 0.45);
			menuItem.scale.set(0.9, 0.9);
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, TitleState.version, 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		#if MODDING_ALLOWED
		var switchInfo:FlxText = new FlxText(5, versionShit.y - versionShit.height, 0, 'Hit TAB to switch mods.', 16);
		switchInfo.scrollFactor.set();
		switchInfo.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(switchInfo);

		var modInfo:FlxText = new FlxText(5, switchInfo.y - switchInfo.height, 0,
			'${modding.PolymodHandler.metadataArrays.length} mods loaded, ${modding.ModList.getActiveMods(modding.PolymodHandler.metadataArrays).length} mods active.',
			16);
		modInfo.scrollFactor.set();
		modInfo.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(modInfo);
		#end

		changeItem();

		super.create();

		call("createPost");
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float) {
		#if sys
		if (!selectedSomethin && FlxG.keys.justPressed.TAB) {
			openSubState(new modding.SwitchModSubstate());
			persistentUpdate = false;
		}
		#end

		#if (flixel < "6.0.0")
		FlxG.camera.followLerp = elapsed * 3.6;
		#end

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!selectedSomethin) {
			if (-1 * Math.floor(FlxG.mouse.wheel) != 0) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1 * Math.floor(FlxG.mouse.wheel));
			}

			if (controls.UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (Options.getData("flashingLights")) {
				}

				menuItems.forEach(function(spr:FlxSprite) {
					if (curSelected != spr.ID) {
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: (_) -> spr.kill()
						});
					} else {
						if (Options.getData("flashingLights")) {
							FlxFlicker.flicker(spr, 1, 0.06, false, false, (_) -> selectCurrent());
						} else {
							new FlxTimer().start(1, (_) -> selectCurrent(), 1);
						}
					}
				});
			}
			
			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new TitleState());
			}

		}

		call("update", [elapsed]);

		super.update(elapsed);

		call("updatePost", [elapsed]);

		menuItems.forEach((spr:FlxSprite) -> {
			spr.screenCenter(X);
			spr.x += 300;
		});
	}

	function selectCurrent() {
		var selectedButton:String = optionShit[curSelected];

		switch (selectedButton) {
			case 'story mode':
				FlxG.switchState(new StoryMenuState());

			case 'freeplay':
				FlxG.switchState(new CharterSelectorState());

			case 'options':
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.switchState(new OptionsMenu());

			#if MODDING_ALLOWED
			case 'mods':
				FlxG.switchState(new ModsMenu());
			#end

			case 'toolbox':
				FlxG.switchState(new toolbox.ToolboxState());
		}
		call("changeState");
	}

	function changeItem(itemChange:Int = 0) {
		curSelected += itemChange;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');

			if (spr.ID == curSelected) {
				spr.animation.play('selected');
				camFollow.setPosition(FlxG.width / 2, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
		call("changeItem", [itemChange]);
	}
}
