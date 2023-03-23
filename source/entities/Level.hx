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
        updateGraphic();
    }

    override public function update() {
        super.update();
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
                for(entityIndex in 0...layer.entities.length) {
                    var entity = layer.entities[entityIndex];
                    if(entity.name == "player") {
                        var player = new Player(entity.x, entity.y, entity.values.id);
                        entities.push(player);
                        spawnPoints[player.getTeam()].push(new Vector2(entity.x, entity.y));
                    }
                    if(entity.name == "flag") {
                        entities.push(new Flag(
                            entity.x, entity.y,
                            entity.values.isRedTeam ? Player.RED_TEAM : Player.BLUE_TEAM
                        ));
                    }
                    if(entity.name == "optionalSolid") {
                        if(Random.random < 0.5) {
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

