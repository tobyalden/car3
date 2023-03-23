package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    public static inline var GAME_WIDTH = 640;
    public static inline var GAME_HEIGHT = 360;

    public var level(default, null):Level;
    private var score:Map<Int, Int>;
    private var scoreboard:Text;

    override public function begin() {
        addGraphic(new Image("graphics/background.png"), 100);
        level = new Level("level");
        add(level);
        for(entity in level.entities) {
            add(entity);
        }
        score = [
            Player.RED_TEAM => 0,
            Player.BLUE_TEAM => 0
        ];
        scoreboard = new Text("TEST", 0, 10, GAME_WIDTH, 0, {align: TextAlignType.CENTER, richText: true});
        scoreboard.addStyle("red", {color: 0xFF0000});
        scoreboard.addStyle("blue", {color: 0x0000FF});
        scoreboard.richText = "<red>0</red> - <blue>0</blue>";
        addGraphic(scoreboard, -100);
    }

    public function scorePoint(team:Int) {
        score[team] += 1;
    }

    override public function update() {
        scoreboard.richText = '<red>${score[Player.RED_TEAM]}</red> - <blue>${score[Player.BLUE_TEAM]}</blue>';
        super.update();
    }
}
