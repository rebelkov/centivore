local composer = require( "composer" )
local mydata = require( "mydata" )

local scene = composer.newScene()

local physics = require "physics"
physics.start()
--physics.setDrawMode( 'debug' )

local player = require("player")

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
local bombCollisionFilter = {categoryBits=32, maskBits=16 } -- collision avec player(16) 

local chenille = {}
local champignon ={}
local champ={}
local chenilleCount = 10
local chenilleHeight = 15
local color1 = { 1, 0, 0.5 }
local nbtouche = 0
local bomb
local explosionOptions =		{
							    width = 64,
							    height = 64,
							    numFrames = 160
							}
local img_explosion = graphics.newImageSheet( "explosions.png", explosionOptions )

local function shoot( event )
    if event.phase == 'began' and vaisseau.width ~= nil then
        
        bullet = display.newRect(vaisseau.x , vaisseau.y, 10, 30 )
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


local function bombCollision (event)

  if event.phase == 'began' then
  	print (event.other.type)
  	print (event.target.type)
  end
end

--Collision du player

local function playerCollision (event)
	if event.phase == 'began' then
		print ("player Collision " .. event.other.type.. " "..event.target.type)
		if event.target.type == "player"  then
    	  		display.remove(event.target)
    	  		
				local explosion_player = player.player_explosion(event)
				explosion_player:addEventListener( "sprite", spriteListener )
				explosion_player:play()

    	  		event.target=nil
    	  		--composer.gotoScene( "restart" )
    	  end       	
	elseif event.phase == "ended" then
	
	end
end

local function champCollision(event)

	if event.other.type == 'bullet'  then
	print ("champignon Collision " .. event.other.type.. " "..event.target.type)
				--suppression de la balle
		        display.remove( event.other )
		        event.other = nil

		        
		        local seq_explosion_champ ={
													{
											        name = "explosionChampignon",
											        start = 1,
											        count = 32,
											        time = 500,
											        loopCount=1
											        
											    }
											}
					local explosion_champignon = display.newSprite( img_explosion, seq_explosion_champ)
					explosion_champignon.x = event.target.x
					explosion_champignon.y = event.target.y
					explosion_champignon:play()

				display.remove(event.target)
				event.target= nil


				return true					

			end
			

end



local function chenilleCollision( event )
    if event.phase == 'began' then
    		--print(event.other.type)
    			  
			if event.other.type == 'wall' or event.other.type=="champ" then
		 		 	
		 		 timer.performWithDelay(1, function() 
						 		 				if event.target.y~=nil and vaisseau.y ~= nil then
						 		 						event.target.y=event.target.y + chenilleHeight*2.5 
						 		 						if event.target.y > vaisseau.y + chenilleHeight*2.5 then 
						 		 							event.target.y = vaisseau.y
						 		 						end

						 		 				end
					 		 				end,
					 		 			 1)
						
		 		 event.target:setLinearVelocity(event.target.speed, 0 )
		 		 event.target.speed = - event.target.speed
		 		 return true
		 		
			end
			
			

		    if event.other.type == 'bullet' then
		        	
		        
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
		            -- event.target.speed = 0
					
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
    		event.target:setLinearVelocity(-event.target.speed, 0 )
				if event.target.x < 20 then
					event.target:setLinearVelocity(event.target.speed, 0 )
				end
				--gestiin du ver bloque 
				--local vx, vy = myRect:getLinearVelocity()
			
    	 end   

    	  	
		 		

 		 if event.other.type == "champ" then
 		 	local num=event.other.numero
 		 	
 		 	champ[num].pv = champ[num].pv + 1
 		 	if champ[num].pv  >= 2 then
 		 			
 		 		event.other:setFillColor( 0.9, 0.9,0.1  )
 		 	end
 		 	if champ[num].pv > 5 then
 		 			
 		 			--objet qui tombe
 		 			local b_x=event.other.x
 		 			local b_y=event.other.y
 		 			 timer.performWithDelay(1, function() 
				 		 				bomb=display.newImageRect( "champignon.png" , 40, 40 )
										bomb.gravityScale = 3
										bomb.type="bomb"
										bomb:setFillColor(0.9,0,0)
										bomb.x = b_x
				 		 				bomb.y= b_y 
				 		 				physics.addBody( bomb, 'dynamic',{bounce=0.6,friction=0})
			 		 				end,
			 		 			 1)

 		 			 display.remove(event.other)
 		 			event.other=nil

 		 	end
 		 	 return true
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
	physics.addBody( mur_g, "static",{  filter=murCollisionFilter })
 	mur_g.isSensor = true
 	mur_g.type="wall"
 	mur_g.myName="mur"

	sceneGroup:insert(mur_g) 

	mur_d = display.newRect( contentW-10,0, 50, 3000)
	physics.addBody( mur_d, "static",{ filter=murCollisionFilter })
	 mur_d.isSensor = true
	 mur_d.type="wall"
	sceneGroup:insert(mur_d) 
   

	for i = 1, chenilleCount do
	
		chenille[i] = display.newCircle( contentW / 4 + (chenilleHeight*2.1*i)+1, 150,  chenilleHeight )
		
		
		chenille[i].numero = i
		chenille[i].speed = speed
		chenille[i].type="ver"
		
	

		physics.addBody( chenille[i] , "dynamic",{filter=verCollisionFilter})
		chenille[i].gravityScale = 0
		chenille[i]:setLinearVelocity( -speed, 0 )
		sceneGroup:insert(chenille[i]) 

		--creation des objets chamigong cache en reserve
	 champignon[i] = display.newImageRect( "champignon.png" , 40, 40 )
		champignon[i].x = 0
		champignon[i].y = 0
		champignon[i]:setFillColor( 0.9, 0.1, 0.16  )
	--champignon[i] =display.newRect( 0,0 , 20, 20 )
	    champignon[i].pv = 1 
	    champignon[i].type="champ"
	    champignon[i].numero=i
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
		champ[i].numero=i
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
 
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
	  
	
		vaisseau:addEventListener( 'touch', moveVaisseau )
		vaisseau:addEventListener( 'collision', playerCollision )

		--Runtime:addEventListener("enterFrame", moveVer)
		Runtime:addEventListener( 'touch', shoot )

		--ver:addEventListener( 'collision', wallCollision )
		for i = 1, #chenille do
			chenille[i]:addEventListener( 'collision', chenilleCollision )
			champignon[i]:addEventListener( 'collision', champCollision )
			--chenille[i]:addEventListener( 'postCollision', afterCollision )
		end

		for i = 1, 20 do
			champ[i]:addEventListener( 'collision', champCollision )
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
				chenille[i]:removeEventListener( 'collision', chenilleCollision )
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
			chenille[i]:removeEventListener( 'collision', chenilleCollision )
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
