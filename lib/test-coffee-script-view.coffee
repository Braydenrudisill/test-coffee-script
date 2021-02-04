
# lib/test-coffee-script-view

{View} = require 'atom-space-pen-views'

module.exports =
class TestCoffeeScriptView extends View
    mouseDown = true

    @content: ->
        @div =>
            @h1 "The test-coffee-script package is Alive! It's ALIVE!"
            @canvas true, #for some reason you can't split onto multiple lines without this
                    width: 500,
                    height: 500,
                    style: "border:1px solid #FFFFFF;",
                    mouseDown: 'handleClickDown',
                    mouseUp: 'handleClickUp',
                    mouseMove: 'handleMove',
                    "canvas"

    handleMove: (event, element) ->
        if not @mouseDown
            return

        c = element.context
        ctx = c.getContext('2d')

        num_points = 200
        accuracy = 1/num_points
        p0 = {x: 100, y: 500}
        p1 = {x: 50, y: 100}
        p2 = {x: 150, y: 200}
        p3 = {x: event.offsetX, y: event.offsetY}


        ctx.moveTo(p0.x,p0.y)
        ctx.strokeStyle = "#FFFFFF"
        ctx.clearRect(0, 0, c.width, c.height);

        count = 0
        ctx.beginPath()
        while count <= 1
            p = bezier(count, p0, p1, p2, p3)
            ctx.lineTo(p.x, p.y)
            ctx.stroke()
            count+=accuracy

        ctx.beginPath()
        ctx.moveTo(p0.x,p0.y)
        ctx.arc(p0.x, p0.y, 5, 0, 2 * Math.PI, false)
        ctx.stroke()
        ctx.moveTo(p1.x,p1.y)
        ctx.arc(p1.x, p1.y, 5, 0, 2 * Math.PI, false)
        ctx.stroke()
        ctx.moveTo(p2.x,p2.y)
        ctx.arc(p2.x, p2.y, 5, 0, 2 * Math.PI, false)
        ctx.stroke()
        ctx.moveTo(p3.x,p3.y)
        ctx.arc(p3.x, p3.y, 5, 0, 2 * Math.PI, false)
        ctx.stroke()

    handleClickDown: (event, element) ->
        console.log "mouseDown"
        @mouseDown = true
        @handleMove(event, element)


    handleClickUp: (event, element) ->
        if @mouseDownId != false
            @mouseDown = false
            console.log "clicked up in"

    bezier = (t, p0, p1, p2, p3) ->
        cX = 3 * (p1.x - p0.x)
        bX = 3 * (p2.x - p1.x) - cX
        aX = p3.x - p0.x - cX - bX

        cY = 3 * (p1.y - p0.y)
        bY = 3 * (p2.y - p1.y) - cY
        aY = p3.y - p0.y - cY - bY

        x = (aX * Math.pow(t, 3)) + (bX * Math.pow(t, 2)) + (cX * t) + p0.x
        y = (aY * Math.pow(t, 3)) + (bY * Math.pow(t, 2)) + (cY * t) + p0.y
        # console.log(x,y)

        return {
            x: x
            y: y
        }
        
