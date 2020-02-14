package;

import flixel.FlxCamera;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxSubState;

class DialogueSubstate extends FlxSubState
{
    private var dialogueText:TypeTextTwo;
    private var blackBarTop:FlxSprite;
    private var blackBarBottom:FlxSprite;

    public function new(d:String, startNow = true, ?onClose:()->Void) {
        super();
        
        closeCallback = onClose;
        
        var newCamera = new FlxCamera();
        newCamera.scroll.x -= newCamera.width * 2;//showEmpty
        FlxG.cameras.add(newCamera);
        newCamera.bgColor = 0;
        
        blackBarTop = new FlxSprite();
        blackBarTop.makeGraphic(FlxG.width, Std.int(FlxG.height * 0.22), FlxColor.BLACK);
        blackBarTop.scrollFactor.set();
        blackBarTop.y = -blackBarTop.height;
        blackBarTop.camera = newCamera;
        add(blackBarTop);

        blackBarBottom = new FlxSprite();
        blackBarBottom.makeGraphic(FlxG.width, Std.int(FlxG.height * 0.22), FlxColor.BLACK);
        blackBarBottom.scrollFactor.set();
        blackBarBottom.y = FlxG.height;
        blackBarBottom.camera = newCamera;
        add(blackBarBottom);

        FlxTween.tween(blackBarTop, {y: 0}, 0.25, {ease:FlxEase.quadIn});
        FlxTween.tween(blackBarBottom, {y: Std.int(FlxG.height - blackBarBottom.height)}, 0.25, {ease:FlxEase.quadIn});

        dialogueText = new TypeTextTwo(0, 0, FlxG.width, d, 16);
        dialogueText.scrollFactor.set();
        dialogueText.sounds = [FlxG.sound.load('assets/sounds/talksound' + BootState.soundEXT), FlxG.sound.load('assets/sounds/talksound1' + BootState.soundEXT)];
        dialogueText.finishSounds = true;
        dialogueText.skipKeys = [];
        dialogueText.camera = newCamera;
        dialogueText.active = false;
        add(dialogueText);

        if (startNow)
            start(0.25);
    }
    
    inline public function start(delay = 0.05):Void
    {
        dialogueText.active = true;
        dialogueText.start(delay);
    }

    override function update(elapsed:Float) {

        var gamepad = FlxG.gamepads.lastActive;
        if (dialogueText.active
        && (FlxG.keys.anyJustPressed([E, F, X, SPACE, Z, W, UP]) || (gamepad != null && gamepad.justPressed.ANY)))
        {
            if (dialogueText.isFinished)
                startClose();
            dialogueText.skip();
        }
        
        super.update(elapsed);
    }
    
    override function close()
    {
        FlxG.cameras.remove(dialogueText.camera);
        
        super.close();
    }
    
    function startClose():Void
    {
        FlxTween.tween(blackBarTop, {y:-blackBarTop.height}, 0.25, {ease:FlxEase.quadIn});
        FlxTween.tween(blackBarBottom, {y: FlxG.height}, 0.25,
            { ease:FlxEase.quadIn, onComplete: (_)->close() }
        );
        dialogueText.kill();
    }
}