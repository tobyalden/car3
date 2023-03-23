package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

typedef BulletOptions = {
    @:optional var playerId:Int;
    @:optional var width:Int;
    @:optional var height:Int;
    @:optional var radius:Int;
    var angle:Float;
    var speed:Float;
    @:optional var collidesWithWalls:Bool;
    @:optional var callback:Bullet->Void;
    @:optional var callbackDelay:Float;
    @:optional var color:Int;
    @:optional var gravity:Float;
    @:optional var accel:Float;
    @:optional var tracking:Float;
    @:optional var duration:Float;
}

class Bullet extends Entity
{
    public var velocity:Vector2;
    public var sprite:Image;
    public var angle:Float;
    public var speed:Float;
    public var gravity:Float;
    public var accel:Float;
    public var tracking:Float;
    public var duration:Float;
    // Wait... i should just be checking the bullet options instead of creating redundant variables
    public var bulletOptions:BulletOptions;

    public function new(x:Float, y:Float, bulletOptions:BulletOptions) {
        super(x - bulletOptions.radius, y - bulletOptions.radius);
        this.bulletOptions = bulletOptions;
        this.angle = bulletOptions.angle - Math.PI / 2;
        this.speed = bulletOptions.speed;
        type = "bullet";
        bulletOptions.collidesWithWalls = (
            bulletOptions.collidesWithWalls == null ? false : bulletOptions.collidesWithWalls
        );
        var color = bulletOptions.color == null ? 0xFFFFFF : bulletOptions.color;
        gravity = bulletOptions.gravity == null ? 0 : bulletOptions.gravity;
        accel = bulletOptions.accel == null ? 0 : bulletOptions.accel;
        tracking = bulletOptions.tracking == null ? 0 : bulletOptions.tracking;
        duration = bulletOptions.duration == null ? 999 : bulletOptions.duration;
        mask = new Circle(bulletOptions.radius);
        sprite = Image.createCircle(bulletOptions.radius, color);
        graphic = sprite;
        velocity = new Vector2();
        var callbackDelay = (
            bulletOptions.callbackDelay == null ? 0 : bulletOptions.callbackDelay
        );
        if(bulletOptions.callback != null) {
            addTween(new Alarm(callbackDelay, function() {
                bulletOptions.callback(this);
            }), true);
        }
        velocity.x = Math.cos(angle);
        velocity.y = Math.sin(angle);
        velocity.normalize(speed);
    }

    override public function moveCollideX(_:Entity) {
        onCollision();
        return true;
    }

    override public function moveCollideY(_:Entity) {
        onCollision();
        return true;
    }

    private function onCollision() {
        scene.remove(this);
    }

    override public function update() {
        duration -= HXP.elapsed;
        if(duration <= 0) {
            HXP.scene.remove(this);
        }
        velocity.y += gravity * HXP.elapsed;
        velocity.normalize(velocity.length + accel * HXP.elapsed);
        if(tracking > 0) {
            //var towardsPlayer = new Vector2(getPlayer().centerX - centerX, getPlayer().centerY - centerY);
            //towardsPlayer.normalize(tracking * HXP.elapsed);
            //var speed = velocity.length;
            //velocity.add(towardsPlayer);
            //velocity.normalize(speed);
        }
        if(bulletOptions.collidesWithWalls) {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        }
        else {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        }
        if(collide("player", x, y) != null) {
            trace('d');
        }
        if(!collideRect(x, y, scene.camera.x, scene.camera.y, HXP.width, HXP.height)) {
            scene.remove(this);
        }
        super.update();
    }
}

