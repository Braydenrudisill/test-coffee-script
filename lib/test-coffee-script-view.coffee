
# lib/test-coffee-script-view

{View} = require 'atom-space-pen-views'

module.exports =
class TestCoffeeScriptView extends View
    mouseDown = true
    current = 0
    curves = []

    selectionRadius = null
    deleteMode = false

    canvas = null
    ctx = null
    code = null
    style = null
    drag = null
    dPoint = null

    animating = false
    currentAnimCurve = 0

    @animationSpeed = 1000
    animStart = 0
    date = new Date()

    translating = false
    translatingObject = false
    selectedBezier = null
    isSnapped = false
    tPoint = null

    @content: ->
        @div =>
            @h1 "Bezier Curve Editor"
            @h1     id: "startBut",
                    mouseDown: "Start",
                    "Start"
            @button id: "addCurveBut",
                    "Add Curve"
            @button id: "recPointsBut",
                    "Record Points"
            @canvas true, #for some reason you can't split onto multiple lines without this
                    width: 500,
                    height: 500,
                    style: "border:1px solid #FFFFFF;",
                    # mouseDown: 'DragStart',
                    id: 'canvas',
                    "canvas"

    handleMove: (event, element) ->
        if not @mouseDown
            return

        # c = element.context
        # ctx = c.getContext('2d')
        #
        # num_points = 200
        # accuracy = 1/num_points
        # p0 = {x: 100, y: 500}
        # p1 = {x: 50, y: 100}
        # p2 = {x: 150, y: 200}
        # p3 = {x: event.offsetX, y: event.offsetY}
        #
        #
        # ctx.moveTo(p0.x,p0.y)
        # ctx.strokeStyle = "#FFFFFF"
        # ctx.clearRect(0, 0, c.width, c.height);
        #
        # count = 0
        # ctx.beginPath()
        # while count <= 1
        #     p = bezier(count, p0, p1, p2, p3)
        #     ctx.lineTo(p.x, p.y)
        #     ctx.stroke()
        #     count+=accuracy
        #
        # ctx.beginPath()
        # ctx.moveTo(p0.x,p0.y)
        # ctx.arc(p0.x, p0.y, 5, 0, 2 * Math.PI, false)
        # ctx.stroke()
        # ctx.moveTo(p1.x,p1.y)
        # ctx.arc(p1.x, p1.y, 5, 0, 2 * Math.PI, false)
        # ctx.stroke()
        # ctx.moveTo(p2.x,p2.y)
        # ctx.arc(p2.x, p2.y, 5, 0, 2 * Math.PI, false)
        # ctx.stroke()
        # ctx.moveTo(p3.x,p3.y)
        # ctx.arc(p3.x, p3.y, 5, 0, 2 * Math.PI, false)
        # ctx.stroke()

    handleClickDown: (event, element) ->
        # console.log "mouseDown"
        if(@mouseDown)
            return
        @mouseDown = true
        console.log "starting"
        # @handleMove(event, element)
        @Start()


    handleClickUp: (event, element) ->
        if @mouseDownId != false
            # @mouseDown = false
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

    class curvePoint
        constructor: () ->
            @x = 0
            @y = 0
        computeDistance: (pt) ->
            xd = pt.x - @x
            yd = pt.y - @y

            return Math.sqrt xd*xd+yd*yd

    class curve_c
        constructor: () ->
            @isValid = false
            @p1 = new curvePoint
            @p2 = new curvePoint
            @cp1 = new curvePoint
            @cp2 = new curvePoint

        set: (params) ->
            params = params.replace(/[^0-9,]/g,'')
            params = params.replace(/[^0-9,]/g,'')
            split = params.split(",")
            @p1.x = 1 * split[0]
            @p1.y = 1 * split[1]
            @cp1.x = 1 * split[2]
            @cp1.y = 1 * split[3]
            @cp2.x = 1 * split[4]
            @cp2.y = 1 * split[5]
            @p2.x = 1 * split[6]
            @p2.y = 1 * split[7]

            @isValid = (split.length >= 8)



    addCurve: () =>
        curveParams = "100,250,150,100,350,100,400,250"
        @tCurve = new curve_c
        @tCurve.set(curveParams)

        if @tCurve.isValid
            @curves.push(@tCurve)
        @DrawCanvas()

    recPoints: () =>
        atom.workspace.open().then (editor) =>
            editor.insertText "#include <vector>\n\nusing namespace std;\n\n"
            editor.insertText "vector<vector<vector<double>>> curve_list = {\n"
            origin = {x: @curves[0].p1.x, y: @curves[0].p1.y}

            for curve in @curves
                # Record control points
                for point of curve
                    p = curve[point]
                    if p.x?
                        editor.insertText "// "+ (p.x-origin.x)
                        editor.insertText ","
                        editor.insertText ""+ -1*(p.y-origin.y)
                        editor.insertText "\n"
                console.log curve.p1.x

                # Record points on curve
                num_points = 200
                accuracy = 1/num_points
                count = 0
                editor.insertText "\t{\n"
                while count <= 1
                    p0 = {x: curve.p1.x-origin.x, y: curve.p1.y-origin.y}
                    p3 = {x: curve.p2.x-origin.x, y: curve.p2.y-origin.y}
                    p1 = {x: curve.cp1.x-origin.x, y: curve.cp1.y-origin.y}
                    p2 = {x: curve.cp2.x-origin.x, y: curve.cp2.y-origin.y}

                    p = bezier(count, p0,p1,p2,p3)
                    editor.insertText "\t\t{"+p.x
                    editor.insertText ","
                    editor.insertText ""+(-1*p.y)+"},\n"
                    count+=accuracy

                editor.insertText "\t},\n\n"
            editor.insertText "};"







    delCurve: () ->
        @deleteMode = !@deleteMode
        @DrawCanvas()

    Init: () =>
        @style = {
            curve: {
                width: 2,
                color: "#555"
            },
            cpline: {
                width: 1,
                color: "#AAA"
            },
            startpoint: {
                radius: 5,
                width: 2,
                color: "#090",
                fill: "rgba(0,200,0,1)",
                arc1: 0,
                arc2: 2 * Math.PI
            },
            endpoint: {
                radius: 5,
                width: 2,
                color: "#900",
                fill: "rgba(200,0,0,1)",
                arc1: 0,
                arc2: 2 * Math.PI
            },
            point: {
                radius: 5,
                width: 2,
                color: "#900",
                fill: "rgba(200,200,200,0.5)",
                arc1: 0,
                arc2: 2 * Math.PI
            },
            cppoint: {
                radius: 5,
                width: 1,
                color: "#000",
                fill: "rgba(200,200,200,0.5)",
                arc1: 0,
                arc2: 2 * Math.PI
            }
        }
        @selectionRadius = @style.point.radius * 1.5

        @ctx.lineCap = "round"
        @ctx.lineJoine = "round"

        @canvas.onmousedown = @DragStart
        @canvas.onmousemove = @Dragging
        @canvas.onmouseup = @canvas.onmouseout = @DragEnd

        @DrawCanvas()

    lerp: (start, end, amount) -> start + amount * (end-start)

    # LerpCurve: (bezier1, bezier2, time)

    DrawCurve: (point,start=false) ->
        if true
            @ctx.lineWidth = @style.cpline.width
            @ctx.strokeStyle = @style.cpline.color
            @ctx.beginPath()
            @ctx.moveTo(point.p1.x, point.p1.y)
            @ctx.lineTo(point.cp1.x, point.cp1.y)
            @ctx.moveTo(point.p2.x, point.p2.y)
            @ctx.lineTo(point.cp2.x, point.cp2.y)
            @ctx.stroke()


        @ctx.lineWidth = @style.curve.width
        # console.log @style.curve.width
        @ctx.strokeStyle = @style.curve.color
        @ctx.beginPath()
        @ctx.moveTo(point.p1.x, point.p1.y)
        @ctx.bezierCurveTo(point.cp1.x, point.cp1.y, point.cp2.x, point.cp2.y, point.p2.x, point.p2.y)
        @ctx.stroke()


        # console.log "Drawing curves from " +point

        for p of point
            # console.log "Tryna draw point "+p
            if p == "cp1" || p == "cp2"
                @ctx.lineWidth = @style.cppoint.width;
                @ctx.strokeStyle = @style.cppoint.color;
                @ctx.fillStyle = @style.cppoint.fill;
            else
                if (p == "p1")
                    @ctx.strokeStyle = @style.startpoint.color
                    @ctx.fillStyle = @style.startpoint.fill
                else if (p == "p2")
                    @ctx.strokeStyle = @style.endpoint.color
                    @ctx.fillStyle = @style.endpoint.fill
                else
                    @ctx.strokeStyle = @style.endpoint.color
                    @ctx.lineWidth = @style.point.width
                    @ctx.fillStyle = @style.point.fill

            if true || !(p == "cp1" || p == "cp2")
                @ctx.beginPath()
                @ctx.arc(point[p].x, point[p].y, @style.point.radius, @style.point.arc1, @style.point.arc2, true)
                # console.log "A- Drawing point"+p
                @ctx.fill()
                @ctx.stroke()

    MousePos: (event) ->
        event = (event ? event : window.event)
        return {
            x: event.offsetX,
            y: event.offsetY
        }

    DrawCanvas: () ->
        # console.log "draw"
        # console.log @style
        # @style.curve.width = 5;
        if @deleteMode
            @ctx.fillStyle = "#F5B8C2"
        else
            @ctx.fillStyle = "#FFFFFF"

        @ctx.fillRect(0, 0, @canvas.width, @canvas.height)

        # console.log "Curves: "+@curves

        if !@animating
            for i in [0...@curves.length]
                if i==0
                    @DrawCurve(@curves[i],true)
                else
                    @DrawCurve(@curves[i],false)

        else if @curves.length>1
            elapsedTime = new Date().getTime()-animStart
            if elapsedTime>((curves.length)*animationSpeed)
                animStart = new Date().getTime()
                elapsedTime = 0

            timeInAnim = (elapsedTime % 1000)/1000



            @currentAnimCurve = Math.floor(elapsedTime/animationSpeed)
            if @currentAnimCurve == @curves.length
                @currentAnimCurve = 0

            nextAnimCurve = @currentAnimCurve+1
            if(nextAnimCurve == @curves.length)
                nextAnimCurve = 0
            # console.log(timeInAnim + " "+currentAnimCurve+" "+nextAnimCurve)

            tCurve = LerpCurve(curves[currentAnimCurve], @curves[nextAnimCurve], timeInAnim)
            DrawCurve(tCurve)

    DragStart: (event, element) =>
        console.log "drag start"
        whichButton = event.which
        if whichButton == 3 || whichButton ==2
            event.preventDefault()

        ctrlPressed = event.ctrlKey
        event = @MousePos(event)
        dx = 0
        dy = 0

        for i in [0...@curves.length]
            @selectedPoint = @curves[i]
            # console.log @selectedPoint

            for p,value of @selectedPoint
                # console.log(p)
                dx = @selectedPoint[p].x - event.x
                dy = @selectedPoint[p].y - event.y


                if (dx*dx) + (dy*dy) < @selectionRadius * @selectionRadius
                    if whichButton == 2 || whichButton == 3
                        @selectedBezier = @curves[i]
                        @translatingObject = true
                        @dPoint = event
                        @canvas.style.cursor = "move"
                        return

                    if deleteMode
                        if p == "p1" || p == "p2"
                            @curves.splice(i,1)
                        else
                            return

                    # console.log(p)
                    @drag = p
                    @dPoint = event
                    @canvas.style.cursor = "move"
                    @isSnapped = false

                    movepoint =  if (@drag + "").length > 2 then @drag.substring(1)  else @drag
                    # console.log(movepoint)

                    for i in [0...@curves.length]
                        @tPoint = @curves[i]
                        # console.log "Tpoint / curves[i]: "+@tPoint+ ", "+@curves[i]
                        if @tPoint == @selectedPoint
                            continue
                        if @selectedPoint[movepoint].computeDistance(@tPoint.p1) <= @selectionRadius
                            @isSnapped = true
                            @selectedBezier = @selectedPoint
                        else if @selectedPoint[movepoint].computeDistance(@tPoint.p2) <= @selectionRadius
                            @isSnapped = true
                            @selectedBezier = @selectedPoint


                    return
        if whichButton == 2 || whichButton == 3
            @translating = true
            @dPoint = event
            @canvas.style.cursor = "move"



    Dragging: (event, element) =>

        if @translating
            event = @MousePos(event)
            for i in [0...@curves.length]
                @tPoint = @curves[i];
                @tPoint.p1.x += event.x - dPoint.x
                @tPoint.p1.y += event.y - dPoint.y
                @tPoint.p2.x += event.x - dPoint.x
                @tPoint.p2.y += event.y - dPoint.y
                @tPoint.cp1.x += event.x - dPoint.x
                @tPoint.cp1.y += event.y - dPoint.y
                @tPoint.cp2.x += event.x - dPoint.x
                @tPoint.cp2.y += event.y - dPoint.y
            @canvas.style.cursor = "move"
            @DrawCanvas()
            @dPoint = event
            return

        if @translatingObject
            event = @MousePos(event)
            @tPoint = selectedBezier;
            @tPoint.p1.x += e.x - dPoint.x;
            @tPoint.p1.y += e.y - dPoint.y;
            @tPoint.p2.x += e.x - dPoint.x;
            @tPoint.p2.y += e.y - dPoint.y;
            @tPoint.cp1.x += e.x - dPoint.x;
            @tPoint.cp1.y += e.y - dPoint.y;
            @tPoint.cp2.x += e.x - dPoint.x;
            @tPoint.cp2.y += e.y - dPoint.y;
            @canvas.style.cursor = "move"
            @DrawCanvas()
            @dPoint = event
            return

        if @drag
            event = @MousePos(event)
            # console.log "dragging"
            if @isSnapped
                # console.log "snapped"
                if @drag == "p1" || @drag == "p2"
                    for i in [0...@curves.length]
                        @tPoint = @curves[i]
                        if @tPoint == @selectedPoint
                            continue
                        lockedPoint = ""
                        if @selectedPoint[@drag].computeDistance(@tPoint.p1) <= @selectionRadius
                            lockedPoint = "p1"
                        else if @selectedPoint[@drag].computeDistance(@tPoint.p2) <= @selectionRadius
                            lockedPoint = "p2"

                        # console.log ("Locked: "+ lockedPoint)

                        if lockedPoint != ""
                            @tPoint[lockedPoint].x += event.x - @dPoint.x
                            @tPoint[lockedPoint].y += event.y - @dPoint.y

                            if lockedPoint == "p1" || lockedPoint == "p2"
                                @tPoint["c" + lockedPoint].x += event.x - @dPoint.x
                                @tPoint["c" + lockedPoint].y += event.y - @dPoint.y

            @selectedPoint[@drag].x += event.x - @dPoint.x
            @selectedPoint[@drag].y += event.y - @dPoint.y
            if @drag=="p1" || @drag=="p2"
                @selectedPoint["c" + @drag].x += event.x - @dPoint.x
                @selectedPoint["c" + @drag].y += event.y - @dPoint.y


            @dPoint = event
            @DrawCanvas()
        else
            event = @MousePos(event)
            @canvas.style.cursor = "default"

            for i in [0...@curves.length]
                @tPoint = @curves[i]
                # console.log "TPOINT: "+@tPoint.p1.x
                if @tPoint.p1.computeDistance(event) <= @selectionRadius || @tPoint.p2.computeDistance(event) <= @selectionRadius || (!@deleteMode && (@tPoint.cp1.computeDistance(event) <= @selectionRadius || @tPoint.cp2.computeDistance(event) <= @selectionRadius))
                    @canvas.style.cursor = @deleteMode ? "crosshair" : "move"

    printhi: () ->
        console.log "hi"

    DragEnd: (event, element) =>
        console.log "drag end"
        @translating = false
        @translatingObject = false

        # console.log @drag
        if @drag && true
            if @drag == "p1" ||  @drag == "p2"
                for i in [0...@curves.length]
                    # console.log i
                    @tPoint = @curves[i]
                    if (@tPoint == @selectedPoint)
                        continue
                    if (@selectedPoint[@drag].computeDistance(@tPoint.p1)<=@selectionRadius)
                        @selectedPoint[@drag].x = @tPoint.p1.x
                        @selectedPoint[@drag].y = @tPoint.p1.y
                    else if (@selectedPoint[@drag].computeDistance(@tPoint.p2)<=@selectionRadius)
                        @selectedPoint[@drag].x = @tPoint.p2.x
                        @selectedPoint[@drag].y = @tPoint.p2.y


        @drag = null
        @DrawCanvas()



    Start: () ->
        console.log "start"
        @canvas = document.getElementById("canvas")
        @snapping = true;
        @isSnapped = true;
        @animationSpeed = 1000;
        @curves = []
        @current = 0

        document.getElementById("addCurveBut").addEventListener("click", @addCurve, false)
        document.getElementById("recPointsBut").addEventListener("click", @recPoints, false)

        if (@canvas.getContext)
            @ctx = @canvas.getContext("2d")
            @Init()
            @addCurve()

            window.setInterval(()=>
                @DrawCanvas()
            ,20)
