local composer = require( "composer" )

local scene = composer.newScene()

local widget = require( "widget" )

-- CONSTANTS used for adaptibility
X = display.contentCenterX
Y = display.contentCenterY
W = display.actualContentWidth
H = display.actualContentHeight

-- holds image to fill newRoundedRect
local image_mapper = 
{
	type = "image",
	filename = "images/main_UI/home_header.jpg"
}

-- holds image to fill newRoundedRect
local holder_mapper = 
{
	type = "image",
	filename = "images/main_UI/holder.jpg"
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
drop_down_group_flag = 'true'

-- -----------------------------------------------------------------------------------
-- FUNCTIONS >>
-- -----------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------Navigation between scenes with params >>
function nav_article_param(btn_value)
	if main_group_flag == 'true' then 
		composer.setVariable( "article_var", btn_value )
		composer.gotoScene("article_screen", {time = 200, effect = "fade"})
	end
end

function nav_drop_article_param(btn_value)
	if  misc_group_flag == 'true' then 
		composer.setVariable( "article_var", btn_value )
		composer.gotoScene("article_screen", {time = 200, effect = "fade"})
	end	
end
---------------------------------------------------------------------------------------------------------Navigation between scenes with params ^^

---------------------------------------------------------------------------------------------------------Navigation between scenes NO params >>
function nav_faqs_screen()
	if main_group_flag == 'true' then 
		composer.gotoScene("faqs_screen", {time = 200, effect = "fade"})
	end
end	

function nav_contacts_screen()
	if main_group_flag == 'true' then 
		composer.gotoScene("contacts_screen", {time = 200, effect = "fade"})
	end
end
---------------------------------------------------------------------------------------------------------Navigation between scenes NO params ^^

---------------------------------------------------------------------------------------------------------Buttons >>
function btn_article(x_mod, y_mod, w_mod, h_mod, btn_id)
	
	local sceneGroup = scene.view
	
	-- Use param to determine what picture to call 
	image_path = "images/article_btn/"..btn_id..".jpg"
	-- Assigning the scene group
	group_flag = main_group
	
	-- Add a param into a function for the event listener
	local function param_nav()
		nav_article_param(btn_id)
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

function btn_radio(x_mod, y_mod, w_mod, h_mod, btn_id)
	
	local sceneGroup = scene.view
	
	-- Use param to determine what picture to call 
	image_path = "images/drop_btn/"..btn_id..".jpg"
	-- Assigning the scene group
	group_flag =  misc_group
	
	-- Add a param into a function for the event listener
	local function param_nav()
		nav_drop_article_param(btn_id)
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
---------------------------------------------------------------------------------------------------------Buttons ^^

---------------------------------------------------------------------------------------------------------Drop Down EVENT >> 
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
		drop_down_close.y = Y * 0.175
	
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
---------------------------------------------------------------------------------------------------------Drop Down EVENT ^^

---------------------------------------------------------------------------------------------------------Drop Down delete >>
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
			drop_down_open.y = Y * 0.175
		
		sceneGroup:insert(drop_down_open)
		
		-- Adds listener so button is ready to call the drop down menu
		-- calls the drop_down_event function which calls all the contents in the menu, with ability to also close it 	
		drop_down_open:addEventListener("tap", drop_down_event)
	end	
end
---------------------------------------------------------------------------------------------------------Drop Down delete ^^

-- -----------------------------------------------------------------------------------
-- FUNCTIONS ^^
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions ---------------------------------------------------------------------------------------------------------From Template (create,show,hide,destroy)>>
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
	
	local sceneGroup = self.view
	
	-- Background image
    local background = display.newImageRect(sceneGroup, "images/main_UI/background.jpg", W * 3, H)
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
		header.fill = image_mapper
		
	-- Home button TOP LEFT
	local home = display.newImageRect(sceneGroup, "images/main_UI/home.jpg", W * 0.22, H * 0.12)
		home.x = X * 0.5
		home.y = Y * 0.175
	
	-- Drop down menu button TOP RIGHT
	-- On first load, so adaptive image can be used after opened and closed again 	
	drop_down_open = display.newImageRect(sceneGroup, "images/main_UI/dropdown1.jpg", W * 0.20, H * 0.095)
		drop_down_open.x = X * 1.5
		drop_down_open.y = Y * 0.175
	
	-- Adds listener so button is ready to call the drop down menu function
	drop_down_open:addEventListener("tap", drop_down_event)
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------Header Container^^
	
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------Main Container>>
	
	-- x pos, y pos, x size, y size, corner radius	
	local container = display.newRoundedRect(sceneGroup, X, Y, W * 0.90, H * 0.60, 40)
		container.strokeWidth = 3
		container:setFillColor(hex2rgb('#fff'))
		container:setStrokeColor(hex2rgb('#000'))
		container.alpha = 0.50
		
		-- Uses this to put image in a newRoundedRect
		container.fill = holder_mapper
		
	------------------------------------------------------------------------------------------------------------------------Article buttons>>
	
	-- RBT Rights (top left)
	btn_article(0.5, 0.725, 0.3, 0.335, 'rbt')
	-- Rights when pulled over (top right)
	btn_article(1.5, 0.725, 0.3, 0.335, 'rwpo')
	-- Community Rights (bottom left)
	btn_article(0.5, 1.275, 0.3, 0.335, 'rights')
	-- Stop & Search Rights (bottom right)
	btn_article(1.5, 1.275, 0.3, 0.335, 's&s')
	
	------------------------------------------------------------------------------------------------------------------------Article buttons^^	
	
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------Main Container^^
	
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------Footer Container>>
	-- x, y, x size, y size, corner radius	
	local footer = display.newRoundedRect(sceneGroup, X, Y * 1.825, W * 0.90, H * 0.13, 40)
		footer.strokeWidth = 3
		footer:setFillColor(hex2rgb('#fff'))
		footer:setStrokeColor(hex2rgb('#000'))
		footer.alpha = 0.95
		
		-- Uses this to put image in a newRoundedRect
		footer.fill = image_mapper
		
		-- question icon
		local question = display.newImageRect("images/main_UI/question.jpg", W * 0.20, H * 0.10)
			question.x = X * 0.5
			question.y = Y * 1.825
			
			-- Adding to scene group 
			main_group:insert(question)
			sceneGroup:insert(main_group)
		
		question:addEventListener( "tap", nav_faqs_screen)
		
		-- phone_call icon
		local phone_call = display.newImageRect("images/main_UI/phone_call.jpg", W * 0.20, H * 0.10)
			phone_call.x = X * 1.5
			phone_call.y = Y * 1.825
			
			-- Adding to scene group 
			main_group:insert(phone_call)
			sceneGroup:insert(main_group)
		
		phone_call:addEventListener( "tap", nav_contacts_screen)
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------Footer Container^^
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

-- hbtn_ide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "home_screen" )
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