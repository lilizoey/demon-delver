(require "libs.batteries")\export!
require "constants"
gscreen = require "libs.Sysl-Pixel.pixel"
import world_to_isometric, draw from require "render"
import collisions, rectangle, circle from require "libs.HC"
Camera = require "libs.hump.camera"
deep = require "libs.deep.deep"
import entity, component, system, world from require "libs.Concord.concord" 
vector = require "libs.hump.vector"

import DrawSystem, MoveSystem, PlayerControlSystem, ColliderSystem, DebugDrawSystem from require "systems"
import Position, Velocity, Sprite, PlayerController, Collider, Movable from require "components"

import draw_graph, update_graph from require "dungeon_generator.main"

main_world = world()
main_world\addSystems DrawSystem, MoveSystem, PlayerControlSystem, ColliderSystem, DebugDrawSystem
gscreen.load(4)

math.randomseed( os.time() )

_24x11debug=love.graphics.newImage "assets/tiles/24x11debugtile.png"
_24x24debug=love.graphics.newImage "assets/tiles/24x24debugtile.png"
_24x36debug=love.graphics.newImage "assets/tiles/24x36debugtile.png"

MAIN_MODE = 0
DEBUG_MAP = 1
GRAPH = 2

display_mode = 0

player = entity main_world 
with player
    \give Position, vector(100,100) 
    \give Velocity, vector(0,0)
    \give Sprite, _24x24debug, 12,17
    \give PlayerController, 100
    \give Collider, (rectangle 100,100,24,24)
    \give Movable

for x=1,10
    for y=1,10
        if x==1 or x==10 or y==1 or y==10 or (x==3 and y==2)
            with entity main_world
                \give Position, vector(x*WORLD_TILE_SIZE,y*WORLD_TILE_SIZE)
                \give Sprite, _24x24debug, 12,17
                \give Collider, (rectangle x*WORLD_TILE_SIZE,y*WORLD_TILE_SIZE,24,24)
        else
            with entity main_world
                \give Position, vector(x*WORLD_TILE_SIZE,y*WORLD_TILE_SIZE)
                \give Sprite, _24x11debug, 12, 6,  -48

local camera

love.load=->
    gscreen.set_cursor 0
    gscreen.show_system_cursor_startup = true
    camera = Camera 0, 0

love.draw=->
    gscreen.start!
    camera\attach 0, 0, love.graphics.getWidth! / gscreen.scale, love.graphics.getHeight! / gscreen.scale, "noclip"

    if display_mode == MAIN_MODE
        main_world\emit "draw", deep
    elseif display_mode == DEBUG_MAP
        main_world\emit "debug_draw"
    elseif display_mode == GRAPH
        draw_graph!
        
    deep.execute!
    camera\detach!
    gscreen.stop!
        
pressed = false

love.update=(dt)->
    gscreen.update(dt)

    main_world\emit "control"
    main_world\emit "update", dt
    main_world\emit "collide", dt

    if (love.keyboard.isDown "space") and not pressed
        display_mode+=1
        display_mode = display_mode % 3  
        pressed = true
    elseif not love.keyboard.isDown "space"
        pressed = false

    p = player[Position].p

    if display_mode == MAIN_MODE
        camera\lookAt unpack (world_to_isometric p.x, p.y)
    elseif display_mode == DEBUG_MAP
        camera\lookAt p.x, p.y 
    elseif display_mode == GRAPH
        update_graph dt
        camera\lookAt p.x, p.y 

    