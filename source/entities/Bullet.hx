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
    private var sfx:Map<String, Sfx>;

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
        sfx = [
            "bullethit" => new Sfx("audio/bullethit.ogg")
        ];
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
        explode();
        sfx["bullethit"].play();
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
        if(!collideRect(x, y, scene.camera.x, scene.camera.y, HXP.width, HXP.height)) {
            scene.remove(this);
        }
        super.update();
    }

    private function explode() {
        var numExplosions = 3;
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2/numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.25 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 0.5, 0.5, bulletOptions.color
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }
    }
}

