COLORS = {
    DEFAULT: 0,
    LARGE_ROOM: 1,
    DEAD_END: 2,
    INTERSECTION: 3,
    ROOM_INTERSECTION: 4,
    ROOM_DOORS: 5
}

DEBUG_COLORING_MAP = {
    [0]: {255,255,255},
    [1]: {  0,  0,255},
    [2]: {255,255,  0},
    [3]: {  0,255,  0},
    [4]: {255,  0,255},
    [5]: {  0,255,255}
}

class Node 
    new: (color=COLORS.DEFAULT) =>
        @color = color
        @edges = {}
        @tags = {}
        @distances = {}
        @eccentricity = 0
        @run_dijkstra = false

    add_edge: (node) =>
        @edges[node] = node
    
    _remove_edge: (node) =>
        @edges[node] = nil

    remove_edge: (node) =>
        @edges[node] = nil
        node\_remove_edge @
    
    clear_edges: () =>
        for _,node in pairs @edges
            node\_remove_edge @
        @edges = {}
    
    count_connected: (counted, no_count) =>
        counted[@] = @
        count = 1
        for _,node in pairs @edges
            if counted[node] or no_count[node] then continue
            count += node\count_connected counted, no_count
        count
    
    draw: (x, y, node_radius, edge_length, distance_node) =>
        love.graphics.setColor unpack DEBUG_COLORING_MAP[@color]
        node_distance = node_radius * 2 + edge_length
        love.graphics.circle "fill", x * node_distance, y * node_distance, node_radius
        if distance_node
            love.graphics.setColor 0,0,0
            distance = @\distance_to distance_node
            love.graphics.print distance, x * node_distance-node_radius/2, y * node_distance - node_radius/2, 0, 0.5

    get_edges: =>
        @edges
    
    get_degree: =>
        count = 0
        for _,_ in pairs @edges
            count += 1
        count

    get_cycle: (start, length, checked, without) =>
        if length < 1
            return false
        
        checked[@] = @

        for _,node in pairs @edges
            if length == 1 and node == start
                return checked
            
            if checked[node] or without[node] then continue

            if new_checked = node\get_cycle start, length - 1, checked, without
                return new_checked
        
        checked[@] = nil

        return nil           

    get_connected: (checked={})=>
        checked[@] = @
        for _,node in pairs @edges
            if checked[node] then continue
            checked = node\get_connected checked
        
        checked

    dijkstra: =>
        unvisited = @\get_connected!
        visited = {}
        current = @
        @\set_distance @, 0

        while current
            neighbor_distance = (@\distance_to current) + 1
            for _,node in pairs current.edges
                if visited[node] then continue
                if @\distance_to(node) == nil or @\distance_to(node) > neighbor_distance
                    @\set_distance node, neighbor_distance

            unvisited[current] = nil
            visited[current] = current

            current = nil
            for _,node in pairs unvisited
                if not @\distance_to node then continue
                if not current or @\distance_to(node) < @\distance_to(current)
                    current = node
            if current then current\set_distance @, @\distance_to current
        @run_dijkstra = true

    distance_to: (node) =>
        @distances[node]

    set_distance: (node, distance) =>
        @distances[node] = distance
        if distance > @eccentricity then @eccentricity = distance

class Graph
    new: (width,height) =>
        @width     = width
        @height    = height
        @length    = width*height
        @count     = 0
        @nodes     = {}
        @node_list = {}
        for x = 1, width
            for y = 1, height
                @\add_node x, y
        for x = 1,width
            for y = 1,height
                if x > 1
                    @\add_edge x,y,x-1,y
                if x < width
                    @\add_edge x,y,x+1,y
                if y > 1
                    @\add_edge x,y,x,y-1
                if y < height
                    @\add_edge x,y,x,y+1

    add_node: (x,y) =>
        if not @nodes[x] then @nodes[x] = {}
        @nodes[x][y] = Node color.DEFAULT
        @count += 1
        table.insert @node_list, {x,y}

    add_edge: (x1,y1,x2,y2) =>
        node1 = @\get_node x1, y1
        node2 = @\get_node x2, y2
        node1\add_edge node2
        node2\add_edge node1
    
    get_node: (x,y) =>
        @nodes[x] and @nodes[x][y]
    
    get_node_coords: (node) =>
        for {x,y} in *@node_list
            if node == @\get_node x,y
                return x,y
    
    remove_node: (x,y) =>
        node = @\get_node(x,y)
        node\clear_edges!
        @nodes[x][y] = nil
        @count -= 1
        for i = 1,#@node_list
            {ix,iy} = @node_list[i]
            if ix==x and iy==y
                table.remove @node_list, i 
                break
    
    -- not guaranteed to give different nodes, just a node
    get_a_node: =>
        {x,y} = @node_list[1]
        @\get_node x,y

    get_random_coords: =>
        unpack @node_list[math.random 1, @count]

    remove_random_node: =>
        @\remove_node (unpack @\get_random_coords!)

    is_connected: (start, no_check={}) =>
        start = start or @\get_a_node!
        count = 0
        for _,e in pairs no_check
            count += 1
        count += start\count_connected {}, no_check
        count == @count

    is_cut_node: (x,y) =>
        cut = @\get_node x, y
        start =  @\get_a_node!
        for i=1,@count
            if start == cut
                {x,y} = @node_list[i]
                start = @\get_node x,y
            else
                break
        
        not @\is_connected start, {[cut]:cut}
    
    remove_random_without_disconnect: =>
        x,y = @\get_random_coords!
        while @\is_cut_node x,y
            x,y = @\get_random_coords!

        @\remove_node x,y
    
    get_cycle_at: (i,length, without={}) =>
        {x,y} = @node_list[i]
        start = @\get_node x,y
        start\get_cycle length, {}, without


    color_cycle_at: (color, i, length) =>
        {x,y} = @node_list[i]
        start = @\get_node x,y
        if cycle = start\get_cycle start, length, {}, {}
            for _,node in pairs cycle
                node.color = color
    
    color_dead_end_at: (color, i, ignore_colors = {}) =>
        {x,y} = @node_list[i]
        node = @\get_node x, y
        if not ignore_colors[node.color] and node\get_degree! == 1
            node.color = color

    color_intersection_at: (color, i, ignore_colors = {}) =>
        {x,y} = @node_list[i]
        node = @\get_node x, y
        if not ignore_colors[node.color] and  node\get_degree! >= 3
            node.color = color

    color_room_intersection_at: (color, i, room_color) =>
        {x,y} = @node_list[i]
        node = @\get_node x, y
        if node\get_degree! != 4 then return

        if node.color != room_color then return

        for _,node in pairs node.edges
            if node.color != room_color then return
        
        cycles = 0

        for _,node1 in pairs node.edges
            for _,node2 in pairs node.edges
                if node1==node2 then continue
                if node\get_cycle node, 4, {}, {[node1]:node1,[node2]:node2} then cycles+=1

        if cycles != 4 then return

        node.color = color
    
    color_room_door_at: (color, i, room_color) =>
        {x,y} = @node_list[i]
        node = @\get_node x, y
        if node.color != room_color then return
        if node\get_degree! != 3 then return

        found_other_door = false
        found_non_room = false

        cycles = 0

        for _,node1 in pairs node.edges
            if node1.color != color and node1.color != room_color then return
            if node\get_cycle node, 4, {}, {[node1]:node1} then cycles+=1

        if cycles != 1 then return

        node.color = color


    color_features: =>
        for i=1,@count
            @\color_cycle_at COLORS.LARGE_ROOM, i, 4
        for i=1,@count
            @\color_dead_end_at COLORS.DEAD_END, i
        for i=1,@count
            @\color_intersection_at COLORS.INTERSECTION, i, {[COLORS.LARGE_ROOM]: true}
        for i=1,@count
            @\color_room_intersection_at COLORS.ROOM_INTERSECTION, i, COLORS.LARGE_ROOM
        for i=1,@count
            @\color_room_door_at COLORS.ROOM_DOORS, i, COLORS.LARGE_ROOM        

    draw: (node_radius, edge_length, completed) =>     
        if completed and not @distance_node 
            x,y = @\get_random_coords!
            @distance_node = @get_node x, y
            @distance_node\dijkstra!
        
        node_spacing = node_radius * 2 + edge_length 
        for {x,y} in *@node_list
            if node = @\get_node x,y
                for node2,_ in pairs node\get_edges!
                    x2,y2 = @\get_node_coords node2
                    love.graphics.line x * node_spacing, y * node_spacing, x2 * node_spacing, y2 * node_spacing
        
        for {x,y} in *@node_list
            (@\get_node x,y)\draw x, y, node_radius, edge_length, @distance_node
            love.graphics.setColor 255,255,255

{:Graph}