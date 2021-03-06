local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local utility = require( "utility" )
local ads = require( "ads" )

local params

local myData = require( "mydata" )

local function handlePlayButtonEvent( event )
    if ( "ended" == event.phase ) then
        composer.removeScene( "levelselect", false )
        composer.gotoScene("levelselect", { effect = "crossFade", time = 333 })
    end
end

local function handleHelpButtonEvent( event )
    if ( "ended" == event.phase ) then
        composer.gotoScene("help", { effect = "crossFade", time = 333, isModal = true })
    end
end

local function handleCreditsButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.gotoScene("gamecredits", { effect = "crossFade", time = 333 })
    end
end

local function handleSettingsButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.gotoScene("gamesettings", { effect = "crossFade", time = 333 })
    end
end

--
-- Start the composer event handlers
--
function scene:create( event )
    local sceneGroup = self.view

    params = event.params
        
    --
    -- setup a page background, really not that important though composer
    -- crashes out if there isn't a display object in the view.
    --
    
    local background = display.newImageRect("foret_bg.png",1600,3000)

    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert( background )

    local title = display.newText("Centivore", 100, 32, native.systemFontBold, 64 )
    title.x = display.contentCenterX
    title.y = 80
    title:setFillColor( 1 )
    sceneGroup:insert( title )

    -- Create the widget
    local playButton = widget.newButton({
        id = "button1",
        defaultFile = "jouer.png",
        onEvent = handlePlayButtonEvent
    })
    playButton.x = display.contentCenterX
    playButton.y = display.contentCenterY - 200
    sceneGroup:insert( playButton )

    -- Create the widget
    local settingsButton = widget.newButton({
        id = "button2",
        defaultFile = "options.png",
        onEvent = handleSettingsButtonEvent
    })
    settingsButton.x = display.contentCenterX
    settingsButton.y = display.contentCenterY - 100
    sceneGroup:insert( settingsButton )

    -- Create the widget
    local helpButton = widget.newButton({
        id = "button3",
        defaultFile = "aide.png",
        onEvent = handleHelpButtonEvent
    })
    helpButton.x = display.contentCenterX
    helpButton.y = display.contentCenterY 
    sceneGroup:insert( helpButton )

    -- Create the widget
    local creditsButton = widget.newButton({
        id = "button4",
       defaultFile = "credits.png",
        onEvent = handleCreditsButtonEvent
    })
    creditsButton.x = display.contentCenterX
    creditsButton.y = display.contentCenterY + 100
    sceneGroup:insert( creditsButton )

end

function scene:show( event )
    local sceneGroup = self.view

    params = event.params
    utility.print_r(event)

    if params then
        print(params.someKey)
        print(params.someOtherKey)
    end

    if event.phase == "did" then
        composer.removeScene( "game" ) 
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    
    if event.phase == "will" then
    end

end

function scene:destroy( event )
    local sceneGroup = self.view
    
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
