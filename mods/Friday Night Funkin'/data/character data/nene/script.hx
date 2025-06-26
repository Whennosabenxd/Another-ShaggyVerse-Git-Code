import game.ABotVis;
import flixe.sound.FlxSound;

var pupilState:Int = 0;
var PUPIL_STATE_NORMAL = 0;
var PUPIL_STATE_LEFT = 1;
var abot:FlxAnimate;
var stereoBG:FlxSprite;
var eyeWhites:FlxSprite;
var pupil:FlxAtlasSprite;
var abotViz:ABotVis;
var time:Float;

// stuff to copy properties to.
var objects:Array<FlxSprite> = [];

function createPost() {
	stereoBG = new FlxSprite(0, 0, Paths.image('characters/abot/stereoBG', 'shared'));
	stereoBG.scrollFactor.set(0.95, 0.95);
	objects.push(stereoBG);
	eyeWhites = new FlxSprite().makeGraphic(160, 60, FlxColor.WHITE);
	objects.push(eyeWhites);

	pupil = new FlxAtlasSprite(0, 0, Paths.getTextureAtlas("characters/abot/systemEyes", "shared"));
	pupil.x = character.x;
	pupil.y = character.y;
	pupil.scrollFactor.set(0.95, 0.95);
	objects.push(pupil);

	abot = new FlxAnimate(0, 0, Paths.getTextureAtlas("characters/abot/abotSystem", "shared"));
	abot.x = character.x;
	abot.y = character.y;
	abot.scrollFactor.set(0.95, 0.95);
	objects.push(abot);

	FlxG.sound.music = new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song,
		(PlayState.SONG.specialAudioName == null ? PlayState.instance.storyDifficultyStr.toLowerCase() : PlayState.SONG.specialAudioName), PlayState.instance.boyfriend.curCharacter));
	FlxG.sound.music.play();
	FlxG.sound.music.volume = 0;
	abotViz = new ABotVis();
	abotViz.x = character.x + 105;
	abotViz.y = character.y + 400;
	abotViz.scrollFactor.set(0.95, 0.95);
	objects.push(abotViz);
	FlxG.sound.music.pause();

	abot.x = character.x - 100;
	abot.y = character.y + 316; // 764 - 740

	PlayState.instance.addBehindGF(stereoBG);
	PlayState.instance.addBehindGF(eyeWhites);
	PlayState.instance.addBehindGF(pupil);
	PlayState.instance.addBehindGF(abotViz);
	PlayState.instance.addBehindGF(abot);

	eyeWhites.x = abot.x + 40;
	eyeWhites.y = abot.y + 250;
	eyeWhites.scrollFactor.set(0.95, 0.95);

	pupil.x = character.x - 607;
	pupil.y = character.y - 176;

	stereoBG.x = abot.x + 150;
	stereoBG.y = abot.y + 30;

	character.x += 30;
	character.y += 5;
}

function dance() {
	if (abot != null) {
		abot.anim.play("");
		abot.anim.curFrame = 1; // we start on this frame, since from Flash the symbol has a non-bumpin frame on frame 0
	}
}

function startSong() {
	FlxG.sound.music.play();
	FlxG.sound.music.volume = 1;
	movePupilsLeft();
}

function updatePost(elapsed:Float) {
	// Set the properties of ABot to match Nene's.
	for (object in objects) {
		object.visible = character.visible;
		object.alpha = character.alpha;
		object.shader = character.shader;
		object.color = character.color;
		object.colorTransform = character.colorTransform;
		object.scrollFactor = character.scrollFactor;
	}

	if (pupil.anim.isPlaying) {
		switch (pupilState) {
			case PUPIL_STATE_NORMAL:
				if (pupil.anim.curFrame >= 17) {
					pupilState = PUPIL_STATE_LEFT;
					pupil.anim.pause();
				}

			case PUPIL_STATE_LEFT:
				if (pupil.anim.curFrame >= 31) {
					pupilState = PUPIL_STATE_NORMAL;
					pupil.anim.pause();
				}
		}
	}
}

function turnChange(turn:String) {
	switch (turn) {
		case 'dad':
			(PlayState.SONG.chartType == "LEGACY") ? movePupilsRight() : movePupilsLeft(); // workaround to some really strange issue where its flipped on vslice charts?
		case 'bf':
			(PlayState.SONG.chartType == "LEGACY") ? movePupilsLeft() : movePupilsRight();
		default:
			trace('no match!');
	}
}

function movePupilsLeft():Void {
	if (pupilState == PUPIL_STATE_LEFT)
		return;
	pupil.anim.play('');
	pupil.anim.curFrame = 0;
	// pupilState = PUPIL_STATE_LEFT;
}

function movePupilsRight():Void {
	if (pupilState == PUPIL_STATE_NORMAL)
		return;
	pupil.anim.play('');
	pupil.anim.curFrame = 17;
	// pupilState = PUPIL_STATE_NORMAL;
}
