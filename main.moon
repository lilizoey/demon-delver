(require "libs.batteries")\export!
require "constants"
gscreen = require "libs.Sysl-Pixel.pixel"
import world_to_isometric, draw from require "render"
import collisions, rectangle, circle from require "libs.HC"
Camera = require "libs.hump.camera"
deep = require "libs.deep.deep"


gscreen.load(4)

_24x13debug=love.graphics.newImage "assets/tiles/24x13debugtile.png"
_24x24debug=love.graphics.newImage "assets/tiles/24x24debugtile.png"

scale=4

walls={}

player=circle(50,50,10)
px,py=50,50

speed=100

cols={}

local camera

empty=(t)->
    for _,_ in pairs t
        return false
    return true

for x=1,10
    walls[x]={}
    for y=1,10
        if x==1 or x==10 or y==1 or y==10
            walls[x][y]=rectangle(x*24,y*24,24,24)

love.load=->
    gscreen.set_cursor 0
    gscreen.show_system_cursor_startup = true
    {pix,piy} = world_to_isometric px,py
    camera = Camera(pix, piy)


love.draw=->
    gscreen.start!
    camera\attach 0, 0, love.graphics.getWidth! / gscreen.scale, love.graphics.getHeight! / gscreen.scale, "noclip"
    {pix,piy} = world_to_isometric px,py
    deep.queue piy-1, love.graphics.circle, "fill",pix,piy,6
    for x=1,10
        for y=1,10
            if walls[x] and walls[x][y]
                draw _24x24debug,(x-1.5) * WORLD_TILE_SIZE, (y-0.5) * WORLD_TILE_SIZE,deep
            else 
                draw _24x13debug,(x-0.5) * WORLD_TILE_SIZE, (y+0.5) * WORLD_TILE_SIZE,deep
        
    deep.execute!
    camera\detach!
    gscreen.stop!
        
love.update=(dt)->
    gscreen.update(dt)

    dx,dy=0,0
    if love.keyboard.isDown "up" 
        dx-=speed*dt
        dy-=speed*dt
    if love.keyboard.isDown "down" 
        dx+=speed*dt
        dy+=speed*dt
    if love.keyboard.isDown "left" 
        dx-=speed*dt
        dy+=speed*dt
    if love.keyboard.isDown "right" 
        dx+=speed*dt
        dy-=speed*dt
    
    dx=dx
    dy=dy
    i=0
    player\move dx, dy
    px+=dx
    py+=dy
    cols = collisions player
    while not empty(cols) and i<30
        for other,delta in pairs cols
            player\move delta[1], delta[2]    
            px+=delta[1]
            py+=delta[2]
        cols = collisions player
        i+=1
    camera\lookAt unpack (world_to_isometric px,py)
    