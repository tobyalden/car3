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
    private var sprite:Image;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "flag";
        mask = new Hitbox(15, 15);
        sprite = new Image('graphics/flag.png');
        graphic = sprite;
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
