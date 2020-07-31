require "constants"

world_to_isometric=(x,y)->
    {math.round((x*TILE_WIDTH)/(2*WORLD_TILE_SIZE)-(y*TILE_WIDTH)/(2*WORLD_TILE_SIZE)),
     math.round((x*(TILE_HEIGHT+1))/(2*WORLD_TILE_SIZE)+(y*(TILE_HEIGHT+1))/(2*WORLD_TILE_SIZE))}
    

draw=(drawable,x,y,r=0,sx=1,sy,ox=0,oy=0,deep,z=0)->
    sy=sy or sx
    if deep then 
        {ix, iy} = world_to_isometric x, y
        deep.queue math.round(x+y+z), love.graphics.draw, drawable, ix, iy, r, sx, sy, ox, oy
    else
        {ix, iy} = world_to_isometric x, y
        love.graphics.draw drawable, ix, iy, r, sx, sy, ox, oy

{:world_to_isometric, :draw}