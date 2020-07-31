require "constants"
import system from require "libs.Concord.concord" 
import Position, Velocity, Sprite, PlayerController, Collider, Movable from require "components"
import draw from require "render"
import collisions from require "libs.HC"
vector = require "libs/hump/vector"

DrawSystem = system {Position, Sprite}

DrawSystem.draw = (deep) => 
    for _,e in ipairs @pool
        {image:image, ox:ox, oy:oy, z:z} = e[Sprite]
        x,y = e[Position].p\unpack!
        draw image, x, y, 0, 1, 1, ox, oy, deep, z

MoveSystem = system {Position, Velocity}

MoveSystem.update = (dt) =>
    for _,e in ipairs @pool
        e[Position].p += e[Velocity].v * dt
        if e[Collider]
            e[Collider].collider\move e[Velocity].v * dt

PlayerControlSystem = system {Velocity, PlayerController}

PlayerControlSystem.control = =>
    for _,e in ipairs @pool
        new_vel = vector(0,0)
        max_speed = e[PlayerController].max_vel
        if love.keyboard.isDown "up"
            new_vel+=vector(-max_speed,-max_speed)
        if love.keyboard.isDown "down"
            new_vel+=vector(max_speed,max_speed)
        if love.keyboard.isDown "left"
            new_vel+=vector(-max_speed,max_speed)
        if love.keyboard.isDown "right"
            new_vel+=vector(max_speed,-max_speed)
        
        e[Velocity].v=new_vel\normalized! * max_speed

ColliderSystem = system {Position, Collider, Velocity, Movable}

ColliderSystem.collide = (dt) =>
    for _,e in ipairs @pool
        cols = collisions e[Collider].collider
        for i=1,2
            maxx,maxy=0,0
            for _,v in pairs collisions(e[Collider].collider)
                if math.abs(v.x)>math.abs(maxx)
                    maxx=v.x
                if math.abs(v.y)>math.abs(maxy)
                    maxy=v.y
            e[Position].p+= vector(maxx,maxy)
            e[Collider].collider\move maxx,maxy


DebugDrawSystem = system {Position, Collider}

DebugDrawSystem.debug_draw = =>
    for _,e in ipairs @pool
        e[Collider].collider\draw!

{
    :DrawSystem,
    :MoveSystem,
    :PlayerControlSystem,
    :ColliderSystem
    :DebugDrawSystem
}