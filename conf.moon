love.conf=(t)->
    t.window.width = 320 -- Base Width that we scale up.
    t.window.height = 180 -- Base Height that we scale up.
    t.window.resizable = false -- Controled though allow_window_resize, set false in conf.
    t.window.minwidth = 320 -- Should match Width
    t.window.minheight = 180 -- Should match Height
    t.pixel_perfect_fullscreen = true