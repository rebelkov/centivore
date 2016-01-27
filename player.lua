local player={}


local function player_explosion(event)
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
	explosion_player.x = event.target.x
	explosion_player.y = event.target.y			
					
	return explosion_player

end



player.player_explosion= player_explosion


return player
