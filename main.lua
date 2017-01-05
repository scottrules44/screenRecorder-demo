local screenRecorder
local myText = display.newText("Record", display.contentCenterX, display.contentCenterY, native.systemFont, 20)
local recordSwitch = 0
local someLoopingMusic = audio.loadStream( "sampleMusic.mp3" )
local apiLevel = system.getInfo('androidApiLevel')
local platform = system.getInfo('platform')
local isRecording = false
local myText2 
if platform == 'android' then
    if apiLevel >= 21 then
        print('Api level 21 (android 5.0) required for screen recording')
        screenRecorder = require( "plugin.screenRecorder" )
    end
else 
    screenRecorder = require( "plugin.screenRecorder" )
end

-- Play the background music on channel 1, loop infinitely, and fade in over 5 seconds
local someLoopingMusicChannel = audio.play( someLoopingMusic, { channel=1, loops=-1 } )
myText:addEventListener( "touch", function(e)
    if (e.phase =="ended")then
        if recordSwitch == 0 then
            if platform == 'android' then
                if apiLevel >= 21 then
                    screenRecorder.record(function ( ev )
                        if (ev.response== "permission denied(Record Display)") then
                            myText.text = "Permission Denied"
                            timer.performWithDelay( 2000, function (  )
                                myText.text = "Record"
                            end )
                        elseif(ev.response == "recording started") then
                            myText.text = "Stop Recording"
                            myText2.alpha = 0
                            isRecording = true
                            recordSwitch = (recordSwitch+1)%2
                        elseif(ev.response == "recording stopped") then
                            isRecording = false
                            myText.text = "Record"
                            myText2.alpha = 1
                            recordSwitch = (recordSwitch+1)%2
                        end
                    end, true)
                else
                    print('Api level 21 (android 5.0) required for screen recording')
                end
            else
                screenRecorder.record(function ( ev )
                    print(ev.response)
                    if (ev.response== "permission denied(Record Display)") then
                        myText.text = "Permission Denied"

                        timer.performWithDelay( 2000, function (  )
                            myText.text = "Record"
                        end )
                    elseif(ev.response == "recording started") then
                        isRecording = true
                        myText.text = "Stop Recording"
                        myText2.alpha = 0
                        recordSwitch = (recordSwitch+1)%2
                    elseif(ev.response == "recording stopped") then
                        isRecording = false
                        myText.text = "Record"
                        myText2.alpha = 1
                        recordSwitch = (recordSwitch+1)%2
                    end
                end, true)
            end
            
        else
            if platform == 'android' then
                if apiLevel >= 21 then
                    screenRecorder.stopRecording()
                else
                    print('Api level 21 (android 5.0) required for screen recording')
                end
            else
                screenRecorder.stopRecording()
            end
        end
    end
end)
myText2 = display.newText("Play Video", display.contentCenterX, display.contentCenterY+30, native.systemFont, 20)
myText2:addEventListener( "touch", function(e)
    if (e.phase =="ended")then
        audio.pause( someLoopingMusicChannel )
        media.playVideo( "screenCapture.mp4", system.TemporaryDirectory, true, function (  )
                audio.resume( someLoopingMusicChannel )
            end )
    end
end)
local function onSystemEvent( event )
    if (event.type == "applicationSuspend") then
        if platform == 'android' then
            if apiLevel >= 21 then
                if (isRecording == true) then
                   screenRecorder.stopRecording() 
                end
            else
                print('Api level 21 (android 5.0) required for screen recording')
            end
        else
            if (isRecording == true) then
                screenRecorder.stopRecording() 
            end
        end
   end
end
Runtime:addEventListener( "system", onSystemEvent )
-- this is the sample code from corona sdk DragMe

--this is sample I got from corona sample code
local arguments =
{
{ x=100, y=60, w=100, h=100, r=10, red=1, green=0, blue=0 },
{ x=60, y=100, w=100, h=100, r=10, red=0, green=1, blue=0 },
{ x=140, y=140, w=100, h=100, r=10, red=0, green=0, blue=1 }
}

local function getFormattedPressure( pressure )
if pressure then
return math.floor( pressure * 1000 + 0.5 ) / 1000
end
return "unsupported"
end

local function printTouch( event )
if event.target then
local bounds = event.target.contentBounds
end
end

local function onTouch( event )
local t = event.target

-- Print info about the event. For actual production code, you should
-- not call this function because it wastes CPU resources.
printTouch(event)

local phase = event.phase
if "began" == phase then
-- Make target the top-most object
local parent = t.parent
parent:insert( t )
display.getCurrentStage():setFocus( t )

-- Spurious events can be sent to the target, e.g. the user presses
-- elsewhere on the screen and then moves the finger over the target.
-- To prevent this, we add this flag. Only when it's true will "move"
-- events be sent to the target.
t.isFocus = true

-- Store initial position
t.x0 = event.x - t.x
t.y0 = event.y - t.y
elseif t.isFocus then
if "moved" == phase then
-- Make object move (we subtract t.x0,t.y0 so that moves are
-- relative to initial grab point, rather than object "snapping").
t.x = event.x - t.x0
t.y = event.y - t.y0

-- Gradually show the shape's stroke depending on how much pressure is applied.
if ( event.pressure ) then
t:setStrokeColor( 1, 1, 1, event.pressure )
end
elseif "ended" == phase or "cancelled" == phase then
display.getCurrentStage():setFocus( nil )
t:setStrokeColor( 1, 1, 1, 0 )
t.isFocus = false
end
end

-- Important to return true. This tells the system that the event
-- should not be propagated to listeners of any objects underneath.
return true
end

-- Iterate through arguments array and create rounded rects (vector objects) for each item
for _,item in ipairs( arguments ) do
local button = display.newRoundedRect( item.x, item.y, item.w, item.h, item.r )
button:setFillColor( item.red, item.green, item.blue )
button.strokeWidth = 6
button:setStrokeColor( 1, 1, 1, 0 )

-- Make the button instance respond to touch events
button:addEventListener( "touch", onTouch )
end

-- listener used by Runtime object. This gets called if no other display object
-- intercepts the event.
local function printTouch2( event )
end

Runtime:addEventListener( "touch", printTouch2 )
