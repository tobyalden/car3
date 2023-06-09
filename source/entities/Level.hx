package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;

class Level extends Entity
{
    public var entities(default, null):Array<Entity>;
    public var spawnPoints(default, null):Map<Int, Array<Vector2>>;
    private var walls:Grid;
    private var tiles:Tilemap;

    public function new(levelName:String) {
        super(0, 0);
        type = "walls";
        loadLevel(levelName);
        mirrorHorizontally();
        updateGraphic();
    }

    override public function update() {
        super.update();
    }

    private function mirrorHorizontally() {
        var halfColumns = Std.int(walls.columns / 2);
        var flipVertically = Random.random < 0.5;
        for(tileX in 0...halfColumns) {
            for(tileY in 0...walls.rows) {
                if(flipVertically) {
                    walls.setTile(
                        walls.columns - 1 - tileX,
                        walls.rows - 1 - tileY,
                        walls.getTile(tileX, tileY)
                    );
                }
                else {
                    walls.setTile(
                        walls.columns - 1 - tileX,
                        tileY,
                        walls.getTile(tileX, tileY)
                    );
                }
            }
        }
    }

    private function loadLevel(levelName:String) {
        var levelData = haxe.Json.parse(Assets.getText('levels/${levelName}.json'));
        for(layerIndex in 0...levelData.layers.length) {
            var layer = levelData.layers[layerIndex];
            if(layer.name == "walls") {
                // Load solid geometry
                walls = new Grid(levelData.width, levelData.height, layer.gridCellWidth, layer.gridCellHeight);
                for(tileY in 0...layer.grid2D.length) {
                    for(tileX in 0...layer.grid2D[0].length) {
                        walls.setTile(tileX, tileY, layer.grid2D[tileY][tileX] == "1");
                    }
                }
                mask = walls;
            }
            else if(layer.name == "entities") {
                // Load entities
                entities = new Array<Entity>();
                spawnPoints = [
                    Player.RED_TEAM => [],
                    Player.BLUE_TEAM => []
                ];
                var solidsBag = [true, true, false, false, HXP.choose(true, false)];
                HXP.shuffle(solidsBag);
                var solidsCounter = 0;
                for(entityIndex in 0...layer.entities.length) {
                    var entity = layer.entities[entityIndex];
                    if(entity.name == "player") {
                        var player = new Player(entity.x, entity.y, entity.values.angle, entity.values.id);
                        entities.push(player);
                        spawnPoints[player.getTeam()].push(new Vector2(entity.x, entity.y));
                    }
                    if(entity.name == "base") {
                        var base = new Base(
                            entity.x, entity.y, entity.width, entity.height,
                            entity.values.isRedTeam ? Player.RED_TEAM : Player.BLUE_TEAM
                        );
                        entities.push(base);

                        // Spawn flag in base
                        var flag = new Flag(base.centerX, base.centerY, base.team);
                        flag.moveBy(-flag.width / 2, -flag.height / 2);
                        entities.push(flag);
                    }
                    if(entity.name == "optionalSolid") {
                        if(solidsBag[solidsCounter]) {
                            for(tileY in 0...Std.int(entity.height / walls.tileHeight)) {
                                for(tileX in 0...Std.int(entity.width / walls.tileWidth)) {
                                    walls.setTile(
                                        tileX + Std.int(entity.x / walls.tileHeight),
                                        tileY + Std.int(entity.y / walls.tileWidth),
                                        true
                                    );
                                }
                            }
                        }
                        solidsCounter += 1;
                        if(solidsCounter >= solidsBag.length) {
                            HXP.shuffle(solidsBag);
                            solidsCounter = 0;
                        }
                    }
                }
            }
        }
    }

    public function updateGraphic() {
        tiles = new Tilemap(
            'graphics/tiles.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(walls.getTile(tileX, tileY)) {
                    tiles.setTile(tileX, tileY, tileY * walls.columns + tileX);
                }
            }
        }
        graphic = tiles;
    }
}

