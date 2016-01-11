

local composer = require( "composer" )
local scene = composer.newScene()

local physics = require "physics"
physics.start()
--physics.setDrawMode( 'debug' )

local speed = 10
local motionx = 0
local mydata = require( "mydata" )
local contentW, contentH = display.contentWidth, display.contentHeight
local bullet
local gameStarted = false
local vaisseau


local function shoot( event )
    if event.phase == 'began' then
        bullet = display.newRect(vaisseau.x + vaisseau.width * 0.5, vaisseau.y, 10, 30 )
        physics.addBody( bullet, 'dynamic' )
        bullet.gravityScale = 0
        bullet.isSensor = true
        bullet.isBullet = true
        bullet.type = 'bullet'
        bullet:setLinearVelocity( 0, -500 )
    end
end

local function wallCollision( event )
    if event.phase == 'began' then
        if event.other.type == 'bullet' then
        	print('touche')
            display.remove( event.other )
            event.other = nil
        end
    end
end

local function moveVaisseau(event)
	
	if (vaisseau.x > 1 and motionx < 0) or (vaisseau.x < display.viewableContentWidth - 50 and motionx > 0) then
	 vaisseau.x = vaisseau.x + motionx
	 
	end
end


local function navigueToRight( event )
	
    if event.x <= display.contentCenterX and event.x > 0 --and motionx >= 0
       then
			motionx = -speed
			vaisseau.xScale = -1
			vaisseau.anchorX = 1
	elseif event.phase == "ended" then
			motionx = 0
	end
    return true
end


local function navigueToLeft( event )

    if event.x  >= display.contentCenterX --and motionx <= 0
     then
			motionx = speed
			vaisseau.xScale = 1
			vaisseau.anchorX = 0
	elseif event.phase == "ended" then
			motionx = 0
	end
    return true
end


-- "scene:create()"
function scene:create( event )

   local sceneGroup = self.view
   
   gameStarted = false
   mydata.score = 0

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   
   local background = display.newImage("bg.png")
	sceneGroup:insert(background)

	vaisseau = display.newImage("avion.png")
	vaisseau.anchorX = 0
	vaisseau.anchorY = 1
	vaisseau.x = contentW * 0.5
	vaisseau.y = display.viewableContentHeight - 50
	physics.addBody(vaisseau, 'kinematic')
	sceneGroup:insert(vaisseau)    


	local fleche_g = display.newImage("fleche_gauche.png")
	fleche_g.anchorX = 0
	fleche_g.anchorY = 1
	fleche_g.x = 0
	fleche_g.y =  display.viewableContentHeight - 25
	sceneGroup:insert(fleche_g)  

	local fleche_d = display.newImage("fleche_droite.png")
	fleche_d.anchorX = 1
	fleche_d.anchorY = 1
	fleche_d.x =  display.viewableContentWidth 
	fleche_d.y =  display.viewableContentHeight - 25
	sceneGroup:insert(fleche_d)    

   
   wall = display.newRect( contentW / 2, 250, contentW, 50 )
	physics.addBody( wall, 'static' )
	wall.isSensor = true
	wall.type = 'wall'
	sceneGroup:insert(wall) 


	fleche_g:addEventListener( "touch", navigueToRight )
	fleche_d:addEventListener( "touch", navigueToLeft )

end

-- "scene:show()"


function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
	  
	
	Runtime:addEventListener("enterFrame", moveVaisseau)
	Runtime:addEventListener( 'touch', shoot )
	wall:addEventListener( 'collision', wallCollision )

	
	  
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.

	Runtime:removeEventListener("enterFrame", moveVaisseau)
	Runtime:removeEventListener( 'touch', shoot )
	wall:removeEventListener( 'collision', wallCollision )
	  
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view
 
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene













