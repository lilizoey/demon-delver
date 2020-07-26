import polygon from require "libs/HC"

diamond=(x,y,a,b)->
    polygon(x-a,y,x,y-b,x+a,y,x,y+b)

{:diamond}