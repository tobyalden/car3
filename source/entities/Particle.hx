package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.utils.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class Particle extends Entity
{
    private var sprite:Spritemap;
    private var velocity:Vector2;

    public function new(
        x:Float, y:Float, velocity:Vector2, fadeTime:Float, scale:Float, color:Int = 0xFFFFFF
    ) {
	    super(x, y);
        this.velocity = velocity;
        sprite = new Spritemap("graphics/particle.png", 12, 12);
        sprite.add(
            "idle",
            [0, 1, 2, 3],
            Std.int(Math.random() * 4 + 2),
            false
        );
        sprite.play("idle");
        sprite.centerOrigin();
        sprite.scale = scale;
        sprite.color = color;
        var fadeTween = new MultiVarTween();
        fadeTween.tween(sprite, {"alpha": 0}, fadeTime);
        addTween(fadeTween, true);
        graphic = sprite;
    }

    public override function update() {
        var delta = HXP.elapsed * 60;
        moveBy(
            velocity.x * delta * 17,
            velocity.y * delta * 17
        );
        velocity.scale(0.97);
        if(sprite.complete) {
            scene.remove(this);
        }
    }
}
