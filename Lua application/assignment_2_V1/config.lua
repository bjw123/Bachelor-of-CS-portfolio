--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

application =
{
	content =
	{
		width = 1920,
		height = 1080, 
		scale = "zoomEven",
		fps = 60,
		
		scale = "adaptive",
		
		imageSuffix =
		{
			    ["@2x"] = 1.5,
			    ["@4x"] = 3.0,
		},
		
	},
}
