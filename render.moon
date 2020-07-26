require "constants"

TILE_WIDTH=24
TILE_HEIGHT=13

world_to_isometric=(x,y)->
    {math.round((x*TILE_WIDTH)/(2*WORLD_TILE_SIZE)-(y*TILE_WIDTH)/(2*WORLD_TILE_SIZE)),
     math.round((x*TILE_HEIGHT)/(2*WORLD_TILE_SIZE)+(y*TILE_HEIGHT)/(2*WORLD_TILE_SIZE))}
    

draw=(drawable,x,y,deep,z=0)->
    if deep then 
        {ix, iy} = world_to_isometric x, y
        deep.queue math.round(iy)+z, love.graphics.draw, drawable, ix, iy
    else
        love.graphics.draw drawable, unpack (world_to_isometric x, y)

{:world_to_isometric, :draw}