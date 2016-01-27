local composer = require( "composer" )
local mydata = require( "mydata" )

local scene = composer.newScene()

local physics = require "physics"
physics.start()
--physics.setDrawMode( 'debug' )

local player = require("player")
local sheetChenille = require("sheetchenille")

print ("curret level "..mydata.settings.currentLevel)
print("speed "..mydata.settings.levels[mydata.settings.currentLevel].speed)
local speed = mydata.settings.levels[mydata.settings.currentLevel].speed
local chenilleCount = mydata.settings.levels[mydata.settings.currentLevel].chenilleCount
local champignonCount = mydata.settings.levels[mydata.settings.currentLevel].champignonCount
local pvBomb = mydata.settings.levels[mydata.settings.currentLevel].pvBomb

local motionx = -1
local contentW, contentH = display.contentWidth, display.contentHeight
local bullet
local gameStarted = false
local vaisseau
local sol
local verCollisionFilter = { categoryBits=1, maskBits=30 } --collision avec mur(2) et shoot(4) et champignon (8) et player(16)
local murCollisionFilter = { categoryBits=2, maskBits=33 } --collision avec ver(1) 
local shootCollisionFilter = { categoryBits=4, maskBits=41 } --collision avec ver(1) et champignon (8) et bomb(32)
local champCollisionFilter = { categoryBits=8, maskBits=37 } --collision avec ver(1) et shoot(4) et bomb(32)
local playerCollisionFilter = { categoryBits=16, maskBits=33 } --collision avec ver(1) et bomb(32)
local bombCollisionFilter = {categoryBits=32, maskBits=94 } -- collision avec player(16)  et champ(8) et mur(2) et shoot(4) + sol(64)
local solCollisionFilter = {categoryBits=64, maskBits= 32 } -- collision avec bomb (32)

local chenille = {}
local champignon ={}
local champ={}

local chenilleHeight = 15
local color1 = { 1, 0, 0.5 }
local nbtouche = mydata.levelScore
local bomb
local explosionOptions =		{
							    width = 64,
							    height = 64,
							    numFrames = 160
							}
local img_explosion = graphics.newImageSheet( "explosions.png", explosionOptions )
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


local function shoot( event )

	-- print ("shoot ")
 --    if event.phase == 'began' and 
       if  vaisseau.width ~= nil  then
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

local function explosionChampignon(x,y)
				
					explosion_champignon.x = x
					explosion_champignon.y = y
					explosion_champignon:play()

end

local function explosionChenille(x,y)
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
		explosion_chenille.x = x
		explosion_chenille.y = y
		explosion_chenille:play()
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
        print("game over "..mydata.levelScore
        	)
        composer.gotoScene( "restart" )
    end
end


local function bombCollision (event)

  if event.phase == 'began' then
		
  	 if event.other.type=="bullet" then

  	 	if event.target.pv<=1 then
  			print("bomb explosion ".. event.other.type.. " "..event.target.type)
					-- explosion_champignon.x = event.target.x
					-- explosion_champignon.y = event.target.y
					-- explosion_champignon:play()
					explosionChampignon(event.target.x,event.target.y)
					display.remove(event.target)
     				event.target=nil
     		else
     			event.target.pv = event.target.pv - 1
     			event.target:applyForce(0,-10,event.target.x,event.target.y)


     	end
     	display.remove(event.other)
     	event.other = nil

     elseif event.other.type=="sol" then
     	display.remove(event.target)
     	event.target=nil
     	print("destruciton bomb")
     end
  end
end

--Collision du player

local function playerCollision (event)
	if event.phase == 'began' then
		--print ("player Collision " .. event.other.type.. " "..event.target.type)
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

					-- explosion_champignon.x = event.target.x
					-- explosion_champignon.y = event.target.y
					-- explosion_champignon:play()
				explosionChampignon(event.target.x,event.target.y)
				display.remove(event.target)
				event.target= nil


				return true					

			end
			

end

local function createBomb( obj_x,obj_y,impact)
			local b_x=obj_x
			local b_y=obj_y
			local sens_x = 2
			if impact >0 then sens_x=2
				else sens_x=-2
			end

			bomb=display.newImageRect( "champignon.png" , 40, 40 )
			bomb.gravityScale = 3
			bomb.type="bomb"
			bomb.pv = 3
			bomb:setFillColor(0.9,0,0)
			bomb.x = b_x
			bomb.y= b_y 
			physics.addBody( bomb, 'dynamic',{bounce=0.6,friction=0, filter = bombCollisionFilter})
			bomb:applyForce(sens_x,2,bomb.x,bomb.y)
			bomb:addEventListener('collision', bombCollision)
				 		 				
	-- body
end


local function chenilleCollision( event )
    if event.phase == 'began' then
    		--print(event.other.type)
    			  
			if event.other.type == 'wall' or event.other.type=="champ" then
		 		 print (event.other.type.." collision chenille no "..event.target.numero.." pos y  "..event.target.y)
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
			
			

		    if event.other.type == 'bullet' and chenille[event.target.numero].alpha == 1 then
		        	local numtouche=event.target.numero
		            local new_x=event.target.x
			  		local new_y=event.target.y
		        
					nbtouche = nbtouche + 1	        	
		        	--suppression de la balle
		            display.remove( event.other )
		            event.other = nil

		            -- explosion de la chenille en deux
		         	explosionChenille(new_x,new_y)
				
		            chenille[numtouche].speed =0
		            -- event.target.speed = 0
					
				    timer.performWithDelay(10,function() newChampignon (numtouche,new_x,new_y) end ,1) 
		            
		            display.remove ( event.target )
		            event.target = nil
		             chenille[numtouche] = nil
					
					mydata.levelScore = mydata.levelScore + 1
					tb.text = mydata.levelScore

					if nbtouche >= chenilleCount 
						then
						print ("GAGNE !!!!")
						print ("reste "..#chenille)
						composer.gotoScene( "nextlevel" )
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

    	  if event.other.type == "wall"  and event.target.type == "ver"  and  event.target.y > 150 then
    	  		chenille[event.target.numero].alpha = 1
    	  end	
		 		

 		 if event.other.type == "champ" then
 		 	local num=event.other.numero
 		 	champ[num].pv = champ[num].pv + 1
	 		event.other:setFillColor( 0.9, 0.9,champ[num].pv/10 )
 		 	-- champignon devient object qui tombe
 		 	if champ[num].pv > pvBomb then
 		 			--objet qui tombe
 		 			local b_x=event.other.x
 		 			local b_y=event.other.y
 		 			local speedimpact=event.target.speed
 		 			timer.performWithDelay(1,function() createBomb(b_x,b_y,speedimpact) end,1)
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
  

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   
   local background = display.newImageRect("foret_bg.png",1600,3000)
	sceneGroup:insert(background)

    sol=display.newRect(0,display.viewableContentHeight,contentW*2,10)
    -- sol.alpha=0
    sol.type="sol"
    physics.addBody(sol, "static", {filter = solCollisionFilter})
    sceneGroup:insert(sol)
	--vaisseau = display.newImageRect("avion.png",40,40)
	vaisseau = display.newRect(contentW * 0.5,display.viewableContentHeight - 50,40,40)
	vaisseau.type = "player"
	--vaisseau.anchorX = 0
	--vaisseau.anchorY = 0
	--vaisseau.x = contentW * 0.5
	--vaisseau.y = display.viewableContentHeight - 50
	physics.addBody(vaisseau, "static",{  filter=playerCollisionFilter})
	sceneGroup:insert(vaisseau)    

	backplayer=display.newRect(contentW * 0.5,display.viewableContentHeight-50,50,50)
	backplayer.alpha=0
	sceneGroup:insert(backplayer)

	mur_g = display.newRect( -40, -200,100, 3000)
	physics.addBody( mur_g, "static",{  filter=murCollisionFilter })
 	mur_g.type="wall"
 	

	sceneGroup:insert(mur_g) 

	mur_d = display.newRect( contentW-10,-200, 50, 3000)
	physics.addBody( mur_d, "static",{ filter=murCollisionFilter })
	 mur_d.type="wall"
	sceneGroup:insert(mur_d) 
   
-- local sheetChenille =
-- 							{
-- 							    width = 20,
-- 							    height = 20,
-- 							    numFrames = 4
-- 							}
-- local chenilleSheet = graphics.newImageSheet( "chenille.png", sheetChenille)
-- 		local sequences_chenille ={
-- 													{
-- 											        name = "moveChenille",
-- 											        start = 1,
-- 											        count = 4,
-- 											        time = 800,
-- 											        loopCount=0
			        
-- 											    }
-- 											}
local chenilleSheet = graphics.newImageSheet( "chenille.png", sheetChenille:getSheet() )
-- 
	for i = 1, chenilleCount do
	
		
		local numpassage=math.floor(i / 11 )
		local start_y = 200 - ( numpassage *200 )
		local pos_x = i % 11
		print ("creation chenille "..i.." lot "..numpassage.." sur position x "..pos_x.." en y "..start_y)
		--chenille[i] = display.newCircle( contentW / 4 + (chenilleHeight*2.1*pos_x)+1, start_y,  chenilleHeight )
		--chenille[i] = display.newSprite( chenilleSheet , sequences_chenille)
chenille[i] = display.newSprite( chenilleSheet , {frames={sheetChenille:getFrameIndex("sprite")},loopCount=0} )
		--chenille[i] = display.newSprite( chenilleSheet , sequences_chenille)
		chenille[i].x=contentW / 4 + (chenilleHeight*2.1*pos_x)+1
		chenille[i].y=start_y
		chenille[i]:setFillColor(0.4,0.5,1)
		chenille[i]:play()
		chenille[i].numero = i
		chenille[i].speed = speed
		chenille[i].type="ver"
	
		physics.addBody( chenille[i] , "dynamic",{filter=verCollisionFilter})
		chenille[i].gravityScale = 0
		chenille[i]:setLinearVelocity( -speed, 0 )
		chenille[i].alpha = 1
		sceneGroup:insert(chenille[i]) 

		--creation des objets chamigong cache en reserve
	 champignon[i] = display.newImageRect( "champignon.png" , 40, 40 )
		champignon[i].x = 0
		champignon[i].y = 2500
		champignon[i]:setFillColor( 0.9, 0.1, 0.16  )
	--champignon[i] =display.newRect( 0,0 , 20, 20 )
	    champignon[i].pv = 1 
	    champignon[i].type="champ"
	    champignon[i].numero=i
		champignon[i].alpha=0
		physics.addBody (champignon[i], "static", {filter = champCollisionFilter})
		sceneGroup:insert( champignon[i] ) 

	end


	for i = 1, champignonCount do
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

	tb = display.newText(mydata.levelScore,display.contentCenterX,
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
	  
	
		vaisseau:addEventListener( 'touch',  moveVaisseau )
		vaisseau:addEventListener( 'collision', playerCollision )

		--Runtime:addEvebackplayerntListener("enterFrame", moveVer)
		Runtime:addEventListener( 'tap', shoot )

		--ver:addEventListener( 'collision', wallCollision )
		for i = 1, #chenille do
			chenille[i]:addEventListener( 'collision', chenilleCollision )
			champignon[i]:addEventListener( 'collision', champCollision )
			--chenille[i]:addEventListener( 'postCollision', afterCollision )
		end

		for i = 1, #champ do
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

		

		if vaisseau.width ~= nil then
			vaisseau:removeEventListener( 'touch', shoot )
		end
		Runtime:removeEventListener( 'tap', shoot )
		for i = 1, #chenille do
			if (chenille[i])   then
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

		vaisseau:removeEventListener( 'touch', moveVaisseau)
		Runtime:removeEventListener( 'tap', shoot )
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