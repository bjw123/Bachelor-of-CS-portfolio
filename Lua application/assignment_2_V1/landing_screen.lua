local composer = require( "composer" )

local scene = composer.newScene()

local widget = require( "widget" )

-- CONSTANTS used for adaptibility
X = display.contentCenterX
Y = display.contentCenterY
W = display.actualContentWidth
H = display.actualContentHeight

print(display.pixelHeight)
print(display.pixelWidth)
print(H)
print(W)

-- holds image to fill newRoundedRect
local image_mapper = 
{
	type = "image",
	filename = "images/main_UI/container_load.jpg"
}
-- -----------------------------------------------------------------------------------
-- FUNCTIONS >>
-- -----------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------Navigation between scenes >>
function nav_home_screen()
    composer.gotoScene("home_screen", {time = 600, effect = "fade"})
end
---------------------------------------------------------------------------------------------------------Navigation between scenes ^^

---------------------------------------------------------------------------------------------------------Enter buttons >> 
function enter_btn()	

-- Creates button widget, to enter to home screen
enter_button = widget.newButton(
	{
		label = "ENTER",
		labelColor = {default={hex2rgb('#fff')}, over={hex2rgb('#fff')}},
		shape = "roundedRect",
		x = X,
		y = Y * 1.6,
		width = W * 0.325,
		height = W * 0.15,
		cornerRadius = 20,
		fontSize = W * 0.04,
		font = "font1",	
		emboss = true, 
	}
)
	enter_button:setFillColor(hex2rgb('#000'))
	enter_button:addEventListener( "tap", nav_home_screen )
end	
---------------------------------------------------------------------------------------------------------Enter buttons ^^

-- -----------------------------------------------------------------------------------
-- FUNCTIONS ^^
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions ---------------------------------------------------------------------------------------------------------From Template (create,show,hide,destroy) >>
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

	local sceneGroup = self.view
	
	-- Background image
	local background = display.newImageRect(sceneGroup, "images/main_UI/background.jpg", W * 3, H)
		background.x = X
		background.y = Y
	
	-- Global Container (Put all UI inside)	
	local container = display.newRoundedRect(sceneGroup, X, Y, W * 0.90, H * 0.90, 40)
		container.strokeWidth = 5
		container:setFillColor(hex2rgb('#fff'))
		container:setStrokeColor(hex2rgb('#000'))
		container.alpha = 0.93
		
		-- Uses this to put image in a newRoundedRect
		container.fill = image_mapper
			
	-- lawbook icon
	local law_book = display.newImageRect(sceneGroup, "images/main_UI/law_book.jpg", W * 0.3, W * 0.3)
		law_book.x = X
		law_book.y = Y * 0.4	
		
	-- Heading for landing screen
	local heading = display.newText(sceneGroup, "Know Your Rights", X, Y * 0.675, "font_h", W * 0.06)
		heading:setFillColor(hex2rgb('#000')) 
		
	-- Slogan for landing screen
	local slogan = display.newText(sceneGroup, "*Always Prepared*", X, Y * 1.35, "font1", W * 0.06)
		slogan:setFillColor(hex2rgb('#383838'))
	
	--Calls enter button, so user can proceed to home screen	
	enter_btn(sceneGroup)
end

-- show()
function scene:show( event )

	local sceneGroup = self.view

	local phase = event.phase
	
	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
	end
end

-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		enter_button:removeSelf()
		enter_button = nil
		
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "landing_screen" )
	end
end

-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
end

-- Scene event functions ---------------------------------------------------------------------------------------------------------From Template (create,show,hide,destroy) ^^

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene