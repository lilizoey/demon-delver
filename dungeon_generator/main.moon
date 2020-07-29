import Graph from require "dungeon_generator.graph"

current_graph = Graph 20,20

draw_graph = ->
    current_graph\draw 3, 2

t = 0
i=0
update_graph = (dt) ->
    t += dt
    if t > 0.01 and i <= current_graph.length * 375 / 1000
        current_graph\remove_random_without_disconnect!
        t -= 0.01
        i+=1

    if t > 0.1 and i >= current_graph.length * 375 / 1000
        current_graph\color_features!
        i+=1

{:draw_graph, :update_graph}