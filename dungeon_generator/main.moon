import Graph from require "dungeon_generator.graph"

current_graph = Graph 12,12

t = 0
i=0
completed = false

draw_graph = ->
    current_graph\draw 6, 2, completed

done = false

update_graph = (dt) ->
    t += dt
    if t > 0.01 and i <= current_graph.length * 380 / 1000
        current_graph\remove_random_without_disconnect {0,0,0,1}
        t -= 0.01
        i+=1

    if t > 0.1 and i >= current_graph.length * 380 / 1000 and not done
        current_graph\color_features!
        completed = true
        i+=1
        done = true

{:draw_graph, :update_graph}