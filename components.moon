import component from require "libs.Concord.concord" 

Position = component (c,p) ->
    c.p=p

Velocity = component (c,v) ->
    c.v=v

Sprite = component (c,image,ox,oy,z) ->
    c.image=image
    c.ox=ox
    c.oy=oy
    c.z=z

Health = component (c,hp,max_hp) ->
    c.hp=hp
    c.max_hp=max_hp

Collider = component (c,collider) ->
    c.collider=collider

Solid = component ->

Opaque = component ->

PlayerController = component (c,max_vel) ->
    c.max_vel=max_vel

EnemyController = component ->

Movable = component ->

{
    :Position,
    :Velocity,
    :Sprite,
    :Health,
    :Collider,
    :Solid,
    :Opaque,
    :PlayerController,
    :EnemyController,
    :Movable
}