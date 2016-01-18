--calculate the aspect ratio of the device:
local aspectRatio = display.pixelHeight / display.pixelWidth
local max_width = 800
local max_height = 1200
--max_width=480
--max_height=520

application = {
   content = {
	  -- graphicsCompatibility = 1,  -- Turn on V1 Compatibility Mode
      width = aspectRatio > 1.5 and max_width or math.ceil( max_height / aspectRatio ),
      height = aspectRatio < 1.5 and max_height or math.ceil( max_width * aspectRatio ),
      scale = "letterBox",
      fps = 30,

      imageSuffix = {
         ["@2x"] = 1.3
      },
   },
    license = {
      google = {
         key = "reallylonggooglelicensekeyhere",
         policy = "serverManaged", 
      },
   },
}