import haxepunk.*;
import haxepunk.debug.Console;
import haxepunk.input.*;
import haxepunk.input.gamepads.*;
import haxepunk.math.*;
import haxepunk.screen.UniformScaleMode;
import haxepunk.utils.*;
import openfl.Lib;
import scenes.*;


class Main extends Engine
{
    public static inline var GAMEPAD_LEFT_TRIGGER_AXIS = 4;
    public static inline var GAMEPAD_RIGHT_TRIGGER_AXIS = 5;
    public static inline var GAMEPAD_LEFT_BUMPER = 9;
    public static inline var GAMEPAD_RIGHT_BUMPER = 10;

    static function main() {
        new Main();
    }

    override public function init() {
#if debug
        Console.enable();
#end
        HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Expand);
        HXP.fullscreen = true;

        Key.define("forward", [Key.W, Key.UP]);
        Key.define("reverse", [Key.S, Key.DOWN]);
        Key.define("left", [Key.A, Key.LEFT]);
        Key.define("right", [Key.D, Key.RIGHT]);
        Key.define("drift", [Key.Z, Key.SPACE]);

        if(Gamepad.gamepad(0) != null) {
            defineGamepadInputs(Gamepad.gamepad(0));
        }

        Gamepad.onConnect.bind(function(newGamepad:Gamepad) {
            defineGamepadInputs(newGamepad);
        });

        HXP.scene = new GameScene();
    }

    private function defineGamepadInputs(gamepad) {
        gamepad.defineButton("forward", [XboxGamepad.DPAD_UP]);
        gamepad.defineButton("reverse", [XboxGamepad.DPAD_DOWN]);
        gamepad.defineButton("left", [XboxGamepad.DPAD_LEFT]);
        gamepad.defineButton("right", [XboxGamepad.DPAD_RIGHT]);
        gamepad.defineButton("drift", [XboxGamepad.A_BUTTON, GAMEPAD_RIGHT_BUMPER]);
        gamepad.defineAxis("forward", GAMEPAD_RIGHT_TRIGGER_AXIS, 0.5, 1);
        gamepad.defineAxis("reverse", GAMEPAD_LEFT_TRIGGER_AXIS, 0.5, 1);
        gamepad.defineAxis("left", XboxGamepad.LEFT_ANALOGUE_X, -0.5, -1);
        gamepad.defineAxis("right", XboxGamepad.LEFT_ANALOGUE_X, 0.5, 1);
    }

    override public function update() {
#if desktop
        if(Key.pressed(Key.ESCAPE)) {
            Sys.exit(0);
        }
#end
        super.update();
    }
}
