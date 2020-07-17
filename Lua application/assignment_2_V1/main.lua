-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--Variables

local composer = require( "composer" )
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

require('tools.hex2rgb')

-- Go to the menu screen
composer.gotoScene( "landing_screen" )