package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
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
    public var level(default, null):Level;

    override public function begin() {
        addGraphic(new Image("graphics/background.png"), 100);
        level = new Level("level");
        add(level);
        for(entity in level.entities) {
            add(entity);
        }
    }

    override public function update() {
        super.update();
    }
}
