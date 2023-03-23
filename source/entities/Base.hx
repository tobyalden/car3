package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Base extends Entity
{
    public var team(default, null):Int;
    private var sprite:Image;

    public function new(x:Float, y:Float, width:Int, height:Int, team:Int) {
        super(x, y);
        this.team = team;
        type = "base";
        mask = new Hitbox(width, height);
        sprite = Image.createRect(width, height, 0xFFFFFF);
        sprite.color = team == Player.RED_TEAM ? 0xFF0000 : 0x0000FF;
        sprite.alpha = 0.2;
        graphic = sprite;
    }
}
