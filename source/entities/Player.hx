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
    public static inline var MAX_REVERSE_SPEED = MAX_SPEED * 0.7;
    public static inline var TURN_SPEED = 100 * 3 / 1.75;
    public static inline var POST_DRIFT_BOOST = 3;
    public static inline var MAX_DRIFT_BOOST_DURATION = 1;
    public static inline var SOFT_CLAMP_APPROACH_SPEED = ACCEL * 1.75;

    public static inline var TURRET_TURN_SPEED = 100 * 3 / 1.75;
    public static inline var SHOT_SPEED = 150;
    public static inline var MAX_SHOTS_ON_SCREEN = 3;
    public static inline var TURRET_TURN_INCREMENT = 90;

    private var sfx:Map<String, Sfx>;

    public var id(default, null):Int;

    private var sprite:Spritemap;
    private var hitbox:Hitbox;
    private var angle:Float;
    private var speed:Float;
    private var isDrifting:Bool;
    private var velocity:Vector2;
    private var driftTimer:Float;
    private var isDead:Bool;

    private var turretAngle:Float;
    private var turretSprite:Image;

    public var carrying(default, null):Entity;

    public function new(x:Float, y:Float, id:Int) {
        super(x, y);
        this.id = id;
        name = "player";
        type = "player";
        sprite = new Spritemap('graphics/player${id}.png', 10, 16);
        sprite.add("idle", [0]);
        sprite.add("drifting", [1]);
        sprite.play("idle");
        sprite.centerOrigin();
        hitbox = new Hitbox(10, 10, -5, -5);
        mask = hitbox;
        angle = 0;
        speed = 0;
        velocity = new Vector2();
        driftTimer = 0;
        isDrifting = false;
        isDead = false;

        turretAngle = 0;
        turretSprite = new Image("graphics/turret.png");
        //turretSprite.x = width / 2;
        //turretSprite.y = height / 2;
        turretSprite.originX = turretSprite.width / 2;
        turretSprite.originY = turretSprite.height;

        carrying = null;

        graphic = new Graphiclist([sprite, turretSprite]);

        sfx = [
            "die" => new Sfx("audio/die.wav"),
            "carloop" => new Sfx("audio/carloop.wav"),
            "drift" => new Sfx("audio/drift.wav"),
            "boost" => new Sfx("audio/boost.wav"),
            "shoot" => new Sfx("audio/shoot.ogg"),
            "turret" => new Sfx("audio/turret.wav")
        ];
    }

    override public function update() {
        if(!isDead) {
            movement();
            collisions();
            combat();
        }
        if(carrying != null) {
            carrying.moveTo(centerX, centerY - carrying.height);
        }
        animation();
        super.update();
    }

    private function combat() {
        if(Input.pressed('player${id}_turret_left')) {
            //turretAngle += TURRET_TURN_SPEED * HXP.elapsed;
            turretAngle += TURRET_TURN_INCREMENT;
        }
        if(Input.pressed('player${id}_turret_right')) {
            //turretAngle -= TURRET_TURN_SPEED * HXP.elapsed;
            turretAngle -= TURRET_TURN_INCREMENT;
        }
        if(Input.pressed('player${id}_fire')) {
            if(shotsOnScreen() < MAX_SHOTS_ON_SCREEN) {
                shoot({
                    radius: 6,
                    angle: getShotAngleInRadians(),
                    speed: SHOT_SPEED,
                    color: 0xFFF7AB,
                    collidesWithWalls: true,
                    playerId: id
                });
            }
        }
    }

    private function shotsOnScreen() {
        var shots:Array<Entity> = [];
        HXP.scene.getType("bullet", shots);
        var shotCount = 0;
        for(shot in shots) {
            if(cast(shot, Bullet).bulletOptions.playerId == id) {
                shotCount++;
            }
        }
        return shotCount;
    }

    private function shoot(bulletOptions:BulletOptions) {
        var turretLength = new Vector2(0, turretSprite.height);
        turretLength.rotate(getShotAngleInRadians());
        var bullet = new Bullet(centerX - turretLength.x, centerY - turretLength.y, bulletOptions);
        scene.add(bullet);
        sfx["shoot"].play();
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
        //var maxSpeed = isDrifting ? MAX_SPEED * 1.25 : MAX_SPEED;
        var maxSpeed = Input.check('player${id}_reverse') ? MAX_REVERSE_SPEED : MAX_SPEED;
        if(speed > maxSpeed) {
            speed = MathUtil.approach(
                speed, maxSpeed, SOFT_CLAMP_APPROACH_SPEED * HXP.elapsed
            );
        }
        else if(speed < -maxSpeed) {
            speed = MathUtil.approach(
                speed, -maxSpeed, SOFT_CLAMP_APPROACH_SPEED * HXP.elapsed
            );
        }

        // Hard clamp speed
        var hardClamp = maxSpeed * POST_DRIFT_BOOST;
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
        visible = !isDead;
        sprite.play(isDrifting ? "drifting" : "idle");
        sprite.angle = angle;
        turretSprite.angle = angle + turretAngle;
    }

    private function collisions() {
        var flag = collide("flag", x, y);
        if(flag != null && carrying == null && !cast(flag, Flag).isCarried()) {
            carrying = flag;
        }
        var bullet = collide("bullet", x, y);
        if(bullet != null && cast(bullet, Bullet).bulletOptions.playerId != id) {
            die();
        }
    }

    private function die() {
        isDead = true;
        carrying = null;
        sfx["die"].play();
        explode();
        HXP.alarm(2, function() {
            var spawnPoints = cast(HXP.scene, GameScene).level.spawnPoints;
            var spawnPoint = spawnPoints[Random.randInt(spawnPoints.length)];
            moveTo(spawnPoint.x, spawnPoint.y);
            isDead = false;
        });
    }

    private function explode() {
        var numExplosions = 50;
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
            direction.scale(0.8 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 1, 1
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }

#if desktop
        Sys.sleep(0.02);
#end
        scene.camera.shake(1, 4);
    }
}
