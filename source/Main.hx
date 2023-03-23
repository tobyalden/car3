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
    public static inline var GAMEPAD_RIGHT_ANALOG_X_AXIS = 2;
    public static inline var GAMEPAD_RIGHT_ANALOG_Y_AXIS = 3;
    public static inline var NUM_PLAYERS = 4;

    static function main() {
        new Main();
    }

    override public function init() {
#if debug
        Console.enable();
#end
        HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Expand);
        HXP.fullscreen = true;

        for(i in 0...NUM_PLAYERS) {
            Key.define('player${i}_forward', [Key.W, Key.UP]);
            Key.define('player${i}_reverse', [Key.S, Key.DOWN]);
            Key.define('player${i}_left', [Key.A, Key.LEFT]);
            Key.define('player${i}_right', [Key.D, Key.RIGHT]);
            //Key.define('player${i}_drift', [Key.Z, Key.SPACE]);
            Key.define('player${i}_fire', [Key.X]);
        }

        if(Gamepad.gamepad(0) != null) {
            defineGamepadInputs(Gamepad.gamepad(0));
        }

        Gamepad.onConnect.bind(function(newGamepad:Gamepad) {
            defineGamepadInputs(newGamepad);
        });

        HXP.scene = new GameScene();
    }

    private function defineGamepadInputs(gamepad:Gamepad) {
        gamepad.defineButton('player${gamepad.id}_forward', [XboxGamepad.DPAD_UP, XboxGamepad.A_BUTTON]);
        gamepad.defineButton('player${gamepad.id}_reverse', [XboxGamepad.DPAD_DOWN, XboxGamepad.B_BUTTON]);
        gamepad.defineButton('player${gamepad.id}_left', [XboxGamepad.DPAD_LEFT]);
        gamepad.defineButton('player${gamepad.id}_right', [XboxGamepad.DPAD_RIGHT]);
        //gamepad.defineButton('player${gamepad.id}_drift', [XboxGamepad.A_BUTTON, GAMEPAD_LEFT_BUMPER]);
        //gamepad.defineButton('player${gamepad.id}_fire', [XboxGamepad.X_BUTTON, GAMEPAD_RIGHT_BUMPER]);
        gamepad.defineButton('player${gamepad.id}_fire', [XboxGamepad.X_BUTTON]);
        gamepad.defineAxis('player${gamepad.id}_forward', GAMEPAD_RIGHT_TRIGGER_AXIS, 0.5, 1);
        gamepad.defineAxis('player${gamepad.id}_reverse', GAMEPAD_LEFT_TRIGGER_AXIS, 0.5, 1);
        gamepad.defineAxis('player${gamepad.id}_left', XboxGamepad.LEFT_ANALOGUE_X, -0.5, -1);
        gamepad.defineAxis('player${gamepad.id}_right', XboxGamepad.LEFT_ANALOGUE_X, 0.5, 1);
        //gamepad.defineAxis('player${gamepad.id}_turret_left', GAMEPAD_RIGHT_ANALOG_X_AXIS, -0.5, -1);
        //gamepad.defineAxis('player${gamepad.id}_turret_right', GAMEPAD_RIGHT_ANALOG_X_AXIS, 0.5, 1);
        gamepad.defineButton('player${gamepad.id}_turret_left', [GAMEPAD_LEFT_BUMPER]);
        gamepad.defineButton('player${gamepad.id}_turret_right', [GAMEPAD_RIGHT_BUMPER]);
    }

    override public function update() {
#if desktop
        if(Key.pressed(Key.F)) {
            HXP.fullscreen = !HXP.fullscreen;
        }
        if(Key.pressed(Key.ESCAPE)) {
            Sys.exit(0);
        }
#end
        super.update();
    }
}
