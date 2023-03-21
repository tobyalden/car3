package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Player extends Entity
{
    public static inline var ACCEL = 50 * 8;
    public static inline var MAX_SPEED = 100 * 2;
    public static inline var TURN_SPEED = 100 * 3;
    public static inline var POST_DRIFT_BOOST = 3;
    public static inline var MAX_DRIFT_BOOST_DURATION = 1;
    public static inline var SOFT_CLAMP_APPROACH_SPEED = ACCEL * 1.75;

    public static var sfx:Map<String, Sfx> = null;

    private var sprite:Spritemap;
    private var hitbox:Polygon;
    private var angle:Float;
    private var speed:Float;
    private var isDrifting:Bool;
    private var velocity:Vector2;
    private var driftTimer:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        sprite = new Spritemap("graphics/player.png", 10, 16);
        sprite.add("idle", [0]);
        sprite.add("drifting", [1]);
        sprite.play("idle");
        sprite.centerOrigin();
        hitbox = Polygon.createFromArray([
            -5, -8,
            -5, 8,
            5, 8,
            5, -8
        ]);
        mask = hitbox;
        graphic = sprite;
        angle = 0;
        speed = 0;
        velocity = new Vector2();
        driftTimer = 0;
        isDrifting = false;
        if(sfx == null) {
            sfx = [
                "die" => new Sfx("audio/die.wav"),
                "carloop" => new Sfx("audio/carloop.wav"),
                "drift" => new Sfx("audio/drift.wav"),
                "boost" => new Sfx("audio/boost.wav")
            ];
        }
    }

    override public function update() {
        movement();
        //collisions();
        animation();
        super.update();
    }

    private function movement() {
        isDrifting = Input.check("drift");
        if(!isDrifting && driftTimer > 0) {
            var driftBoost = Math.min(driftTimer, MAX_DRIFT_BOOST_DURATION) / MAX_DRIFT_BOOST_DURATION;
            speed *= (1 + driftBoost);
            sfx["boost"].play(driftBoost);
            sfx["carloop"].volume = 1;
        }
        driftTimer = isDrifting ? driftTimer + HXP.elapsed : 0;
        var oldAngle = angle;
        var turnSpeed = isDrifting ? TURN_SPEED * 1.35 : TURN_SPEED;
        if(Input.check("left")) {
            angle += turnSpeed * HXP.elapsed;
        }
        if(Input.check("right")) {
            angle -= turnSpeed * HXP.elapsed;
        }
        if(Input.check("forward")) {
            speed += ACCEL * HXP.elapsed;
        }
        else if(Input.check("reverse")) {
            speed -= ACCEL * HXP.elapsed;
        }
        else {
            speed = MathUtil.approach(speed, 0, ACCEL * HXP.elapsed);
        }

        // Soft clamp speed
        var maxSpeed = isDrifting ? MAX_SPEED * 1.25 : MAX_SPEED;
        if(speed > MAX_SPEED) {
            speed = MathUtil.approach(
                speed, MAX_SPEED, SOFT_CLAMP_APPROACH_SPEED * HXP.elapsed
            );
        }
        else if(speed < -MAX_SPEED) {
            speed = MathUtil.approach(
                speed, -MAX_SPEED, SOFT_CLAMP_APPROACH_SPEED * HXP.elapsed
            );
        }

        // Hard clamp speed
        var hardClamp = MAX_SPEED * POST_DRIFT_BOOST;
        speed = MathUtil.clamp(speed, -hardClamp, hardClamp);

        var heading = new Vector2();
        MathUtil.angleXY(heading, angle + 90, speed);
        if(!isDrifting) {
            heading.scale(0.75);
        }
        else {
            heading.scale(0.125);
        }
        velocity.add(heading);
        velocity.normalize(Math.abs(speed));
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        if(!sfx["carloop"].playing) {
            sfx["carloop"].loop();
        }
        sfx["carloop"].volume = Math.abs(speed) / MAX_SPEED * (isDrifting ? 0.25 : 1);
        if(isDrifting) {
            if(!sfx["drift"].playing) {
                sfx["drift"].loop();
            }
            sfx["drift"].volume = Math.abs(speed) / MAX_SPEED;
        }
        else {
            sfx["drift"].stop();
        }
    }

    private function animation() {
        sprite.play(isDrifting ? "drifting" : "idle");
        sprite.angle = angle;
    }

    //private function collisions() {
        //if(collide("hazard", x, y) != null) {
            //die();
        //}
    //}

    //private function explode() {
        //var numExplosions = 50;
        //var directions = new Array<Vector2>();
        //for(i in 0...numExplosions) {
            //var angle = (2/numExplosions) * i;
            //directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            //directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            //directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            //directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        //}
        //var count = 0;
        //for(direction in directions) {
            //direction.scale(0.8 * Math.random());
            //direction.normalize(
                //Math.max(0.1 + 0.2 * Math.random(), direction.length)
            //);
            //var explosion = new Particle(
                //centerX, centerY, directions[count], 1, 1
            //);
            //explosion.layer = -99;
            //scene.add(explosion);
            //count++;
        //}

//#if desktop
        //Sys.sleep(0.02);
//#end
        //scene.camera.shake(1, 4);
    //}
}
