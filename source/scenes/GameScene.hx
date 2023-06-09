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
    public static inline var POINTS_TO_WIN = 3;

    public static inline var MODE_CTF = 0;
    public static inline var MODE_KOTH = 1;

    public static var sfx(default, null):Map<String, Sfx> = null;

    public var level(default, null):Level;
    public var gameIsOver(default, null):Bool;
    private var score:Map<Int, Int>;
    private var scoreboard:Text;
    private var message:Text;
    private var players:Array<Player>;
    private var gameStarted:Bool;
    private var curtain:Curtain;

    override public function begin() {
        curtain = new Curtain();
        add(curtain);
        addGraphic(new Image("graphics/background.png"), 100);
        level = new Level('level${HXP.choose(0, 1, 2)}');
        add(level);
        players = [];
        for(entity in level.entities) {
            add(entity);
            if(entity.type =="player") {
                players.push(cast(entity, Player));
            }
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

        message = new Text("READY?", 0, 10, GAME_WIDTH, 0, {align: TextAlignType.CENTER, size: 64});
        message.y = GAME_HEIGHT / 2 - message.height / 2;
        message.alpha = 0;
        addGraphic(message, -100);
        gameStarted = false;
        gameIsOver = false;
        curtain.fadeOut(1);

        if(sfx == null) {
            sfx = [
                "airhorn" => new Sfx("audio/airhorn.wav"),
                "scorepoint" => new Sfx("audio/scorepoint.wav"),
                "returnflag" => new Sfx("audio/returnflag.ogg"),
                "pickupflag" => new Sfx("audio/pickupflag.wav"),
                "ready" => new Sfx("audio/ready.ogg")
            ];
        }
    }

    private function startSequence() {
        gameStarted = true;
        HXP.alarm(1, function() {
            message.alpha = 1;
            sfx["ready"].play();
        }, this);
        HXP.alarm(3, function() {
            message.text = "GO!";
            sfx["airhorn"].play();
        }, this);
        HXP.alarm(4, function() {
            message.alpha = 0;
            for(player in players) {
                player.canMove = true;
            }
        }, this);
    }

    public function scorePoint(team:Int) {
        sfx["scorepoint"].play();
        score[team] += 1;
        if(score[team] == POINTS_TO_WIN) {
            for(player in players) {
                if(player.getTeam() != team) {
                    player.die();
                    message.alpha = 1;
                    message.text = team == Player.RED_TEAM ? "RED TEAM WINS!" : "BLUE TEAM WINS!";
                    onGameOver();
                }
            }
        }
    }

    private function onGameOver() {
        if(gameIsOver) {
            return;
        }
        gameIsOver = true;
        sfx["airhorn"].play();
        HXP.alarm(5, function() {
            curtain.fadeIn(1);
        }, this);
        HXP.alarm(7, function() {
            HXP.scene = new GameScene();
        }, this);
    }

    override public function update() {
        if(!gameStarted) {
            startSequence();
        }
        scoreboard.richText = '<red>${score[Player.RED_TEAM]}</red> - <blue>${score[Player.BLUE_TEAM]}</blue>';
        super.update();
    }
}
