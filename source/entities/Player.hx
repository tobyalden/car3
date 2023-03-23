package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;
import entities.Bullet;

class Player extends Entity
{
    public static inline var ACCEL = 50 * 8 / 1.75;
    public static inline var MAX_SPEED = 100 * 2 / 1.75;
    public static inline var TURN_SPEED = 100 * 3 / 1.75;
    public static inline var POST_DRIFT_BOOST = 3;
    public static inline var MAX_DRIFT_BOOST_DURATION = 1;
    public static inline var SOFT_CLAMP_APPROACH_SPEED = ACCEL * 1.75;

    public static inline var TURRET_TURN_SPEED = 100 * 3 / 1.75;
    public static inline var SHOT_SPEED = 150;

    public static var sfx:Map<String, Sfx> = null;

    public var id(default, null):Int;

    private var sprite:Spritemap;
    private var hitbox:Polygon;
    private var angle:Float;
    private var speed:Float;
    private var isDrifting:Bool;
    private var velocity:Vector2;
    private var driftTimer:Float;

    private var turretAngle:Float;
    private var turretSprite:Image;

    public function new(x:Float, y:Float, id:Int) {
        super(x, y);
        this.id = id;
        name = "player";
        sprite = new Spritemap('graphics/player${id}.png', 10, 16);
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
        angle = 0;
        speed = 0;
        velocity = new Vector2();
        driftTimer = 0;
        isDrifting = false;

        turretAngle = 0;
        turretSprite = new Image("graphics/turret.png");
        //turretSprite.x = width / 2;
        //turretSprite.y = height / 2;
        turretSprite.originX = turretSprite.width / 2;
        turretSprite.originY = turretSprite.height;

        graphic = new Graphiclist([sprite, turretSprite]);

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
        combat();
        animation();
        super.update();
    }

    private function combat() {
        if(Input.check('player${id}_turret_left')) {
            turretAngle += TURRET_TURN_SPEED * HXP.elapsed;
        }
        if(Input.check('player${id}_turret_right')) {
            turretAngle -= TURRET_TURN_SPEED * HXP.elapsed;
        }
        if(Input.pressed('player${id}_fire')) {
            shoot({
                radius: 2,
                angle: getShotAngleInRadians(),
                speed: SHOT_SPEED,
                color: 0xFFF7AB,
                collidesWithWalls: true
            });
        }
    }

    private function shoot(bulletOptions:BulletOptions) {
        var turretLength = new Vector2(0, turretSprite.height);
        turretLength.rotate(getShotAngleInRadians());
        var bullet = new Bullet(centerX - turretLength.x, centerY - turretLength.y, bulletOptions);
        scene.add(bullet);
    }

    private function getShotAngleInRadians() {
        return (angle + turretAngle) * 0.0174533 * -1;
    }

    private function movement() {
        isDrifting = Input.check('player${id}_drift');
        if(!isDrifting && driftTimer > 0) {
            var driftBoost = Math.min(driftTimer, MAX_DRIFT_BOOST_DURATION) / MAX_DRIFT_BOOST_DURATION;
            speed *= (1 + driftBoost);
            sfx["boost"].play(driftBoost);
            sfx["carloop"].volume = 1;
        }
        driftTimer = isDrifting ? driftTimer + HXP.elapsed : 0;
        var oldAngle = angle;
        var turnSpeed = isDrifting ? TURN_SPEED * 1.35 : TURN_SPEED;
        if(Input.check('player${id}_left')) {
            angle += turnSpeed * HXP.elapsed;
        }
        if(Input.check('player${id}_right')) {
            angle -= turnSpeed * HXP.elapsed;
        }
        if(Input.check('player${id}_forward')) {
            speed += ACCEL * HXP.elapsed;
        }
        else if(Input.check('player${id}_reverse')) {
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
        turretSprite.angle = angle + turretAngle;
        //turretSprite.angle = turretAngle;
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
