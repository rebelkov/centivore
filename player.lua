local player={}

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

player.explosion_player = display.newSprite( sheet_explosion, sequences_explosion)
					
					
return explosion_player