package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Flag extends Entity
{
    public var team(default, null):Int;
    private var sprite:Image;

    public function new(x:Float, y:Float, team:Int) {
        super(x, y);
        this.team = team;
        type = "flag";
        mask = new Hitbox(15, 15);
        sprite = new Image('graphics/flag.png');
        sprite.color = team == Player.RED_TEAM ? 0xFF0000 : 0x0000FF;
        graphic = sprite;
    }

    public function reset() {
        var bases = new Array<Entity>();
        HXP.scene.getType("base", bases);
        for(base in bases) {
            if(cast(base, Base).team == team) {
                moveTo(base.centerX - width / 2, base.centerY - height / 2);
            }
        }
    }

    public function isCarried() {
        var players = new Array<Entity>();
        HXP.scene.getType("player", players);
        for(player in players) {
            if(cast(player, Player).carrying == this) {
                return true;
            }
        }
        return false;
    }
}
