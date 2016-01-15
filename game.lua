

local composer = require( "composer" )
local mydata = require( "mydata" )

local scene = composer.newScene()

local physics = require "physics"
physics.start()
--physics.setDrawMode( 'debug' )


local speed = 200
local motionx = -1
local contentW, contentH = display.contentWidth, display.contentHeight
local bullet
local gameStarted = false
local vaisseau
local verCollisionFilter = { categoryBits=1, maskBits=30 } --collision avec mur(2) et shoot(4) et champignon (8) et player(16)
local murCollisionFilter = { categoryBits=2, maskBits=1 } --collision avec ver(1) 
local shootCollisionFilter = { categoryBits=4, maskBits=9 } --collision avec ver(1) et champignon 
local champCollisionFilter = { categoryBits=8, maskBits=5 } --collision avec ver(1) et shoot
local playerCollisionFilter = { categoryBits=16, maskBits=1 } --collision avec ver(1) 


local chenille = {}
local champignon ={}
local champ={}
local chenilleCount = 2
local chenilleHeight = 20
local color1 = { 1, 0, 0.5 }
local nbtouche = 0

local explosionOptions =		{
							    width = 64,
							    height = 64,
							    numFrames = 160
							}
local img_explosion = graphics.newImageSheet( "explosions.png", explosionOptions )

local function shoot( event )
    if event.phase == 'began' and vaisseau.width ~= nil then
        
        bullet = display.newRect(vaisseau.x + vaisseau.width * 0.5, vaisseau.y, 10, 30 )
        physics.addBody( bullet, 'dynamic',{filter=shootCollisionFilter} )
        bullet.gravityScale = 0
        bullet.isSensor = true
        bullet.isBullet = true
        bullet.type = 'bullet'
        bullet.myName="shoot"
        bullet:setLinearVelocity( 0, -500 )


    end
end

local function newChampignon (numtouche,new_x,new_y)
	print("new champignon "..numtouche.." x:"..new_x.." y:"..new_y)

    champignon[numtouche].x=new_x
    champignon[numtouche].y=new_y
    champignon[numtouche].alpha=1
	return true
end

local function spriteListener( event )

    local thisSprite = event.target  -- "event.target" references the sprite

    if ( event.phase == "ended" ) then  
        thisSprite:pause()
       composer.gotoScene( "restart" )
    end
end

local function wallCollision( event )
    if event.phase == 'began' then
    		--print(event.other.type)
    			  
			if event.other.type == 'wall' or event.other.type=="champ" then
		 		 --display.remove( event.other )
		 		 --print(event.target.myName)


		 		 


		 		 local vx, vy = event.target:getLinearVelocity()
		        print ("velocity "..vx.. vy)
		        --event.target.speed=-vx
		        if vx < 0 then vx=-200
		        	else vx =200
		        end
		        local d=event.target.delai


		 		 event.target:setLinearVelocity(-vx, vy )
		 		 event.target.speed = vx
		 		 --vx=event.target:getLinearVelocity()
		 		 --print ("after set velocity "..vx)
		 		-- event.target.speed = - event.target.speed
		 		timer.performWithDelay(10, function() 
						 		 				if event.target.y~=nil and vaisseau.y ~= nil then
						 		 						event.target.y=event.target.y + chenilleHeight*2.5 
						 		 						if event.target.y > vaisseau.y + chenilleHeight*2.5 then 
						 		 							event.target.y = vaisseau.y
					
						 		 						end

						 		 				end
					 		 				end,
					 		 			 1)
		 		 return true
		 		
			end


			 if event.other.type == 'bullet' and event.target.type=="champ" then
			 		
			 			--suppression de la balle
		            display.remove( event.other )
		           event.other = nil

		           if event.target.pv <= 1 then 

						local seq_explosion ={
													{
											        name = "explosionChampignon",
											        start = 1,
											        count = 32,
											        time = 500,
											        loopCount=1
											        
											    }
											}
						local explosion_champignon = display.newSprite( img_explosion, seq_explosion)
						explosion_champignon.x = event.target.x
						explosion_champignon.y = event.target.y
						explosion_champignon:play()
			           --suppression du champignon
			           display.remove(event.target)
			           event.target=nil
			           
			        else
			        	event.target.pv = event.target.pv - 1
			        	event.target:setFillColor(0.9,0.8,0.8)
			        	
			       end
			       return true
			 end

		    if event.other.type == 'bullet' and event.target.type=="ver" then
		        	
					nbtouche = nbtouche + 1	        	
		        	--suppression de la balle
		            display.remove( event.other )
		            event.other = nil

		            -- explosion de la chenille en deux
		            local numtouche=event.target.numero
		            local new_x=event.target.x
			  		local new_y=event.target.y

			  		local seq_explosion ={
													{
											        name = "explosionChenille",
											        start = 72,
											        count = 32,
											        time = 500,
											        loopCount=1
											        
											    }
											}
					local explosion_chenille = display.newSprite( img_explosion, seq_explosion)
					explosion_chenille.x = new_x
					explosion_chenille.y = new_y
					explosion_chenille:play()
					-- autre sens pour partie arriere
		          
		            chenille[numtouche].speed = 0
		            event.target.speed = 0
					
				    timer.performWithDelay(10,function() newChampignon (numtouche,new_x,new_y) end ,1) 
		            
		            display.remove ( event.target )
		            event.target = nil
					
					mydata.score = mydata.score + 1
					tb.text = mydata.score

					if nbtouche >= chenilleCount 
						then
						print ("GAGNE !!!!")
						composer.gotoScene( "restart" )
					end
					return true
		            
		    end  
	
    elseif event.phase == "ended" then
    
    
						
    	--print ("other "..event.other.type .. " target "..event.target.type)
    	if event.target.type=="ver" then
    		
			
    	 end   

    	  if event.other.type == "player"  then
    	  		display.remove(event.other)
    	  		local sheetOptions =
							{
							    width = 125,
							    height = 125,
							    numFrames = 14
							}
					local sheet_explosion = graphics.newImageSheet( "explosion_player.png", sheetOptions )
					local sequences_explosion ={
													{
											        name = "normalExplosion",
											        start = 1,
											        count = 14,
											        time = 800,
											        loopCount=1
											        
											    }
											}
					local explosion_player = display.newSprite( sheet_explosion, sequences_explosion)
					explosion_player.x = event.other.x
					explosion_player.y = event.other.y
					explosion_player:addEventListener( "sprite", spriteListener )
					explosion_player:play()

    	  		event.other=nil
    	  		--composer.gotoScene( "restart" )
    	  end       						

    end
end

local function moveVaisseau (event)
	 if event.phase == "began" then
			-- begin focus
			display.getCurrentStage():setFocus( vaisseau, event.id )
			vaisseau.isFocus = true

			vaisseau.markX = vaisseau.x
			--vaisseau.markY = vaisseau.y

		elseif vaisseau.isFocus then
				if event.phase == "moved" then
				--drag touch object
				vaisseau.x = event.x - event.xStart + vaisseau.markX
				--vaisseau.y = event.y - event.yStart + vaisseau.markY



				elseif event.phase == "ended" or event.phase == "cancelled" then
				-- end focus
				display.getCurrentStage():setFocus( vaisseau, nil )
				vaisseau.isFocus = false

				end
	
	end

-- event handled
	return true
end

local function moveVer(event)
	
	if (ver.x > 20 and motionx < 0) then 
	motionx = -speed
	elseif (ver.x > display.viewableContentWidth and motionx > 0) then
			motionx = -speed
		else motionx = speed
	 	
	end
	 ver.x = ver.x + motionx
end

local function onTimer( event )
   local obj = event.source.objectID
   obj:setLinearVelocity( 0, 0 )
end


-- "scene:create()"
function scene:create( event )

   local sceneGroup = self.view
   
   gameStarted = false
   mydata.score = 0

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   
   local background = display.newImageRect("foret_bg.png",1600,3000)
	sceneGroup:insert(background)

	--vaisseau = display.newImageRect("avion.png",40,40)
	vaisseau = display.newRect(contentW * 0.5,display.viewableContentHeight - 50,40,40)
	vaisseau.type = "player"
	--vaisseau.anchorX = 0
	--vaisseau.anchorY = 0
	--vaisseau.x = contentW * 0.5
	--vaisseau.y = display.viewableContentHeight - 50
	physics.addBody(vaisseau, "static",{  filter=playerCollisionFilter})
	sceneGroup:insert(vaisseau)    

	mur_g = display.newRect( 10, 0, 50, 3000)
	physics.addBody( mur_g, "static",{ bounce=0, friction=0,filter=murCollisionFilter })
 	mur_g.isSensor = true
 	mur_g.type="wall"
 	mur_g.myName="mur"

	sceneGroup:insert(mur_g) 

	mur_d = display.newRect( contentW-10,0, 50, 3000)
	physics.addBody( mur_d, "static",{bounce=0, friction=0,filter=murCollisionFilter })
	 mur_d.isSensor = true
	 mur_d.type="wall"
	sceneGroup:insert(mur_d) 
   
  
	for i = 1, chenilleCount do
		chenille[i] = display.newCircle( contentW / 4 + (chenilleHeight*2.5*i), 150,  chenilleHeight )
		if i == 1 then 
			chenille[i].fill = color1
		end

		physics.addBody( chenille[i] , "dynamic",{bounce=0,friction=0,filter=verCollisionFilter})
		chenille[i].gravityScale = 0
		chenille[i].alpha = 1
		chenille[i].numero = i
		chenille[i].speed = speed
		chenille[i].delai = 0
		chenille[i].type="ver"
		chenille[i]:setLinearVelocity( -chenille[i].speed, 0 )
	
		sceneGroup:insert(chenille[i]) 

		--creation des objets chamigong cache en reserve
	 champignon[i] = display.newImageRect( "champignon.png" , 40, 40 )
		champignon[i].x = 0
		champignon[i].y = 0
		champignon[i]:setFillColor( 0.9, 0.1, 0.16  )
	--champignon[i] =display.newRect( 0,0 , 20, 20 )
	    champignon[i].pv = 1 
	    champignon[i].type="champ"
		champignon[i].alpha=0
		physics.addBody (champignon[i], "static", {filter = champCollisionFilter})
		sceneGroup:insert( champignon[i] ) 

	end


	for i = 1, 20 do
		champ[i] = display.newImageRect( "champignon.png" , 40, 40 )
		
		local random_x = math.random(100,contentW-100)
		local random_y = math.random(200,contentH-150)
		champ[i].x=random_x
		champ[i].y=random_y
		champ[i]:setFillColor( 0.1, 0.8, 0.9  )
		champ[i].type="champ"
		champ[i].pv = 2 
		physics.addBody(champ[i], "static", {filter = champCollisionFilter})
		sceneGroup:insert(champ[i])
	end

	tb = display.newText(mydata.score,display.contentCenterX,
	50, "pixelmix", 58)
	tb:setFillColor(255,255,255)
	tb.alpha = 1
	sceneGroup:insert(tb)

end

-- "scene:show()"


function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
 --   	for i = 1, chenilleCount do
	-- 	chenille[i] = display.newCircle( contentW / 4 + (chenilleHeight*2.1*i)+1, 150,  chenilleHeight )
	-- 	if i == 1 then 
	-- 		chenille[i].fill = color1
	-- 	end

	-- 	physics.addBody( chenille[i] , "dynamic",{filter=verCollisionFilter})
	-- 	chenille[i].gravityScale = 0
	-- 	chenille[i].numero = i
	-- 	chenille[i].speed = speed
	-- 	chenille[i].type="ver"
	-- 	chenille[i]:setLinearVelocity( -chenille[i].speed, 0 )
	
	-- 	sceneGroup:insert(chenille[i]) 

	-- 	--creation des objets chamigong cache en reserve
	-- 	champignon[i] = display.newImageRect( "champignon" , 40, 40 )
	-- 	champignon[i].x=0
	-- 	champignon[i].y=0
	-- 	champignon[i].type="champ"
	-- 	champignon[i].alpha=0
	-- 	physics.addBody (champignon[i], "static", {filter = champCollisionFilter})


	-- end
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
	  
	
	vaisseau:addEventListener( 'touch', moveVaisseau )
	vaisseau:addEventListener( 'collision', wallCollision )

	--Runtime:addEventListener("enterFrame", moveVer)
	Runtime:addEventListener( 'touch', shoot )

	--ver:addEventListener( 'collision', wallCollision )
	for i = 1, #chenille do
		chenille[i]:addEventListener( 'collision', wallCollision )
		--chenille[i]:addEventListener( 'postCollision', afterCollision )

	end

	for i = 1, 20 do
		champ[i]:addEventListener( 'collision', wallCollision )
	end
--Runtime.addEventListener( 'collision', wallCollision )
	
	  
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

		

		Runtime:removeEventListener( 'touch', shoot )
		for i = 1, #chenille do
			if chenille[i].speed ~= 0  then
				chenille[i]:removeEventListener( 'collision', wallCollision )
			end
		end
	  
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
    if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.

		vaisseau:removeEventListener( 'touch', moveVaisseau )
		Runtime:removeEventListener( 'touch', shoot )
		for i = 1, #chenille do
			chenille[i]:removeEventListener( 'collision', wallCollision )
		end
	  
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene













