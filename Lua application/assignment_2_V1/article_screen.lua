local composer = require( "composer" )

local scene = composer.newScene()

local widget = require( "widget" )

-- Setting global variable
-- File load depends on this var
-- called from home, faqs & contacts screen
button_call = composer.getVariable( "article_var" )

-- CONSTANTS used for adaptibility
X = display.contentCenterX
Y = display.contentCenterY
W = display.actualContentWidth
H = display.actualContentHeight
--print(H)

-- holds image to fill newRoundedRect
local article_mapper = 
{
	type = "image",
	filename = "images/main_UI/article_header.jpg"
}

-- holds image to fill newRoundedRect
local container_mapper = 
{
	type = "image",
	filename = "images/main_UI/article_container.jpg"
}

-- Scene groups 
main_group = display.newGroup()  
misc_group = display.newGroup() 

-- Global vars for UI
drop_container = 0
drop_down_open = 0
drop_down_close = 0
blur = 0
menu_icon = 0 
btn_value = 0
btn_id = 0 
btn_type = 0 
main_group_flag = 'true'
misc_group_flag = 'true'
scroll_view_Y = 0 
contents = 0
path = 0

-- -----------------------------------------------------------------------------------
-- FUNCTIONS >>
-- -----------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------Navigation between scenes >>
local function nav_back_screen()
	if main_group_flag == 'true' then 
		composer.gotoScene("home_screen", {time = 200, effect = "fade"})
	end	
end
---------------------------------------------------------------------------------------------------------Navigation between scenes ^^

---------------------------------------------------------------------------------------------------------Using the Global Var to get the path file >>
-- Uses this function to determine what file to call 
-- Sets a var for the scroll view y position as files are different heights 
function g_var()
	if button_call == 'rbt' then
		path = system.pathForFile( "app_data/rbt.txt", system.ResourcesDirectory )
	elseif button_call == 'rwpo' then
		path = system.pathForFile( "app_data/rwpo.txt", system.ResourcesDirectory )
	elseif button_call == 'rights' then
		path = system.pathForFile( "app_data/rights.txt", system.ResourcesDirectory )
	elseif button_call == 's&s' then
		path = system.pathForFile( "app_data/s&s.txt", system.ResourcesDirectory )
	end
end
---------------------------------------------------------------------------------------------------------Using the Global Var to get the path file ^^

---------------------------------------------------------------------------------------------------------File reader >>
-- Uses g_vars set "path" to get file from the ResourcesDirectory
function g_reader()
	-- Call g var to check the global var
	-- Standard IO reader to read all of the content in the file
	g_var()
	
	local file, errorString = io.open( path, "r" )
	if not file then
		-- Error occurred; output the cause
		print( "File error: " .. errorString )
	else
		-- Read data from file
		contents = file:read( "*a" )
		-- Close the file handle
		io.close( file )
	end
	file = nil
	-- gives button call value of 0, because we have used the global variable for what we needed too
	button_call = 0
end
---------------------------------------------------------------------------------------------------------File reader ^^ 

---------------------------------------------------------------------------------------------------------Scroll View >>
-- Standard scroll listener 
function scroll_listener (event)
	local phase = event.phase
	local direction = event.direction
  
	--Scroll Limit
	if event.limitReached then
		if "up" == direction then
			print ("Reached top limit")
			
		elseif "down" == direction then
			print ("Reached bottom limit")
		end
	end
		
	return true
end

-- Creates a scroll view to display info from the article files
function scroll_view()

	local sceneGroup = scene.view

	scroll_group = display.newGroup()

	-- Create scroll_view_widg using adaptive anchors
	local scroll_view_widg = widget.newScrollView
	{
		left = X * 0.12,
		top = Y * 0.38,
		  
		width = W * 0.88, 
		height = H * 0.77,
		scrollWidth = W,

		topPadding = 50,
		bottompadding = 50,
			
		horizontalScrollDisabled = true,
		hideBackground = true,
		listener = scroll_listener,		
	}

	-- Place the file text inside an object, to display the string 
	-- 400 = how much on a line, 30 = text size
	local scroll_obj = display.newText(contents, 0, 0, W * 0.7, 0, "font1", W * 0.05)
	scroll_obj:setTextColor(hex2rgb('#fff'))
	scroll_obj.x = X * 0.9
	scroll_obj.anchorY = 0
	scroll_view_widg:insert(scroll_obj)
	
	scroll_group:insert(scroll_view_widg)
	sceneGroup:insert(scroll_group)

end
---------------------------------------------------------------------------------------------------------Scroll View ^^

---------------------------------------------------------------------------------------------------------Drop Down Buttons >>
function btn_radio(x_mod, y_mod, w_mod, h_mod, btn_id)
	
	local sceneGroup = scene.view

	image_path = "images/drop_btn/"..btn_id..".jpg"
	group_flag = misc_group
	
	-- This function will reload the file, not the scene
	local function param_nav()
	
		--remove scrollview
		scroll_group:removeSelf()
		-- set the button call to what ever the button id from the radio button is
		button_call = btn_id
		
		-- use that var to read the file again
		g_reader()
		-- use the loaded contents to populate the scroll view with the new info
		scroll_view()
		
		-- auto delete the dropdown menu as something has been chosen
		drop_down_delete()
		
	end
	
	-- Creation of the button & properties 
	menu_icon = display.newImageRect(image_path, 140, 140)
	menu_icon.alpha = 0.95
	menu_icon.x = X * x_mod
	menu_icon.y = Y * y_mod
	menu_icon.height = W * h_mod
	menu_icon.width = W * w_mod
	
	-- Inserting into scene group		
	group_flag:insert(menu_icon)
	sceneGroup:insert(group_flag)
	
	menu_icon:addEventListener( "tap", param_nav)
end
---------------------------------------------------------------------------------------------------------Drop Down Buttons ^^

---------------------------------------------------------------------------------------------------------Drop Down EVENT>>
-- Loads the drop down menu
-- Uses seperate function to delete 
function drop_down_event()
	
	local sceneGroup = scene.view
	
	-- Flip these values, to not proceed with any event listeners except for ones in dropdown
	main_group_flag = 'false'
	misc_group_flag = 'true'
	
	-- Remove the dropdown logo, so we can flip the arrow 
	drop_down_open:removeSelf()
	
	-- Blur Background image
    blur = display.newImageRect("images/main_UI/blur.jpg", W * 3, H)
		blur.x = X
		blur.y = Y
		blur.alpha = 0.85
		
	-- Inserting into scene group
	misc_group:insert(blur)
	sceneGroup:insert(misc_group)
	
	-- Container to hold the whole dropp down menu, 
	-- adapt co-ords using CONSTANT values from this container regarding drop down menu features 
	-- Holds the whole drop down menu, by being the first declared (1st layer)
	drop_container = display.newRoundedRect(X * 1.175, Y * 0.875, W * 0.8, H * 0.625, 0)
		drop_container.strokeWidth = 5
		drop_container:setFillColor(hex2rgb('#fff'))
		drop_container:setStrokeColor(hex2rgb('#000'))
		drop_container.alpha = 0.95
	
	-- Inserting into scene group
	misc_group:insert(drop_container)
	sceneGroup:insert(misc_group)
	
	-- Remove the original drop down menu image
	-- Then replace with this image, (so we can create an adaptive image change) (arrow facing up)
	drop_down_close = display.newImageRect("images/main_UI/dropdown2.jpg", W * 0.20, H * 0.095)
		drop_down_close.x = X * 1.5
		drop_down_close.y = Y * 0.1755	
	
	-- Inserting into scene group
	misc_group:insert(drop_down_close)
	sceneGroup:insert(misc_group)
	
	-- After drop_down_close has been created, a listener is attached
	-- Calls function to delete the whole dropw  down menu  
	drop_down_close:addEventListener("tap", drop_down_delete)
	
	-- Call 4 radio buttons x_mod, y_mod, w_mod, h_mod & btn_id
	btn_radio(1.1, 0.40, 0.50, 0.25, 'rbt')
	btn_radio(1.1, 0.70, 0.50, 0.25, 'rwpo')
	btn_radio(1.1, 1, 0.50, 0.25, 'rights')
	btn_radio(1.1, 1.3, 0.50, 0.25, 's&s')
	
end
---------------------------------------------------------------------------------------------------------Drop Down EVENT^^

---------------------------------------------------------------------------------------------------------Drop Down delete>>
-- Deletes the drop down menu
function drop_down_delete()
	
	local sceneGroup = scene.view

	-- Error trap, else clicking on 2 unique buttons after menu called it crashes
	if  misc_group_flag == 'true' then 
	
		-- Flip these values, to proceed with event listeners in the main ui scene group
		main_group_flag = 'true'
		misc_group_flag = 'false'
		
		-- delete scene group here 
		misc_group:removeSelf()
		misc_group = display.newGroup() 
			
		-- Drop down menu button replaced to original image (arrow down) 
		drop_down_open = display.newImageRect( "images/main_UI/dropdown1.jpg", W * 0.20, H * 0.095)
			drop_down_open.x = X * 1.5
			drop_down_open.y = Y * 0.1755	
		
		sceneGroup:insert(drop_down_open)
		
		-- Adds listener so button is ready to call the drop down menu
		-- calls the drop_down_event function which calls all the contents in the menu, with ability to also close it 	
		drop_down_open:addEventListener("tap", drop_down_event)
	end	
end
---------------------------------------------------------------------------------------------------------Drop Down delete^^

-- -----------------------------------------------------------------------------------
-- FUNCTIONS ^^
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions ---------------------------------------------------------------------------------------------------------From Template (create,show,hide,destroy)>>
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

	--local sceneGroup = self.view
	local sceneGroup = scene.view
	-- Code here runs when the scene is first created but has not yet appeared on scree
	
	-- Background image
    local background = display.newImageRect(sceneGroup, "images/misc_ui/article_bg.jpg", 800, 1400)
		background.x = X
		background.y = Y
		
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------Header Container>>	
	-- x, y, x size, y size, corner radius	
	local header = display.newRoundedRect(sceneGroup, X, Y * 0.175, W * 0.90, H * 0.13, 40)
		header.strokeWidth = 3
		header:setFillColor(hex2rgb('#fff'))
		header:setStrokeColor(hex2rgb('#000'))
		header.alpha = 0.95
		
		-- Uses this to put image in a newRoundedRect
		header.fill = article_mapper
		
	-- back button TOP LEFT
	local back = display.newImageRect("images/main_UI/back.jpg", W * 0.13, H * 0.095)
		back.x = X * 0.5
		back.y = Y * 0.1755
		back:addEventListener( "tap", nav_back_screen )
		sceneGroup:insert(back)
		
	-- Drop down menu button TOP RIGHT
	-- On first load, so adaptive image can be used after opened and closed again 	
	drop_down_open = display.newImageRect(sceneGroup, "images/main_UI/dropdown1.jpg", W * 0.20, H * 0.095)
		drop_down_open.x = X * 1.5
		drop_down_open.y = Y * 0.1755
		
	-- Adds listener so button is ready to call the drop down menu function
	drop_down_open:addEventListener("tap", drop_down_event)
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------Header Container^^	
	
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------Main Container>>
	-- Holds a layer below the scroll view, to use as a background
	local container = display.newRoundedRect(sceneGroup, X, Y * 1.15, W * 0.90, H * 0.775, 0)
		container.strokeWidth = 1
		container:setFillColor(hex2rgb('#fff'))
		container:setStrokeColor(hex2rgb('#000'))
		container.alpha = 0.99
		
		-- Uses this to put image in a newRoundedRect
		container.fill = container_mapper
	
	-- call global reader to read correct file, and get correct data object to read	
	g_reader()
	
	-- Calls function for scrollview to place that data object inside
	scroll_view()
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------Main Container^^
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

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "article_screen" )
	end
end

-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
end

-- Scene event functions ---------------------------------------------------------------------------------------------------------From Template (create,show,hide,destroy)^^

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
