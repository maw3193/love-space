local orders = require"orders.lua"
function love.load()
	ui = require"ui.lua"
	camera = require"lib/camera"
	vector = require"lib/vector"
	local ship = require "ship.lua"
	local waypoint = require "waypoint.lua"
	local projectile = require "projectile.lua"
	local panels = require "panels.lua"
	require"inputcallbacks.lua"
	love.graphics.setLineWidth(1.5)

	game = {}
	game.things = {}
	game.selected = {}
	game.manualship = nil
	game.worldminx = -400
	game.worldminy = -300
	game.worldmaxx = 400
	game.worldmaxy = 300
	game.wallthickness = 100
	game.worldemptyoutside = 100
	game.paused = false

	game.collgroups = {}
	game.collgroups.walls = 1
	game.collgroups.ships = 2
	game.collgroups.projectiles = 4
	game.collgroups.other = 8
	--Collision rules: Projectiles pass through walls.
	--Nothing of the same player collides with itself.

	game.selstartx = 0
	game.selstarty = 0
	game.mousepressed = false

	game.world = love.physics.newWorld(game.worldminx - game.wallthickness - game.worldemptyoutside,game.worldminy - game.wallthickness - game.worldemptyoutside,game.worldmaxx + game.wallthickness + game.worldemptyoutside,game.worldmaxy + game.wallthickness + game.worldemptyoutside)
	game.world:setCallbacks(add, persist, rem)

	game.static = love.physics.newBody(game.world,0,0,0,0)
	game.topwall = love.physics.newRectangleShape(game.static, 0, game.worldminy - game.wallthickness/2 + 1, game.worldmaxx - game.worldminx + game.wallthickness * 2 - 2, game.wallthickness - 1, 0)
	game.leftwall = love.physics.newRectangleShape(game.static, game.worldminx - game.wallthickness/2+1, 0, game.wallthickness - 1, game.worldmaxy - game.worldminy + game.wallthickness * 2 - 2, 0)
	game.bottomwall = love.physics.newRectangleShape(game.static, 0, game.worldmaxy + game.wallthickness/2 - 1, game.worldmaxx - game.worldminx + game.wallthickness * 2 - 2, game.wallthickness - 1, 0)
	game.rightwall = love.physics.newRectangleShape(game.static, game.worldmaxx + game.wallthickness/2 - 1, 0, game.wallthickness - 1, game.worldmaxy - game.worldminy + game.wallthickness*2 - 2, 0)
	game.topwall:setData("wall")
	game.bottomwall:setData("wall")
	game.leftwall:setData("wall")
	game.rightwall:setData("wall")
	game.topwall:setFilterData(game.collgroups.walls, game.collgroups.ships, 0)
	game.bottomwall:setFilterData(game.collgroups.walls, game.collgroups.ships, 0)
	game.leftwall:setFilterData(game.collgroups.walls, game.collgroups.ships, 0)
	game.rightwall:setFilterData(game.collgroups.walls, game.collgroups.ships, 0)
	
	table.insert(game.things, ship.newship(50,50,1,16,"art/ship32.png", ui.blue, 1))
	table.insert(game.things, ship.newship(-50,50,1,16,"art/ship32.png", ui.blue, 1))
	table.insert(game.things, ship.newship(50,-50,1,16,"art/ship32.png", ui.red, 2))
	table.insert(game.things, ship.newship(-50,-50,1,16,"art/ship32.png", ui.red, 2))
	game.manualship = game.things[1]
	
	game.cam = camera(vector(0,0),1,0)
	game.cam:attach()

	table.insert(ui.elements, game)
	table.insert(ui.elements, panels.newpanel())

	--[[
	local modes = love.graphics.getModes()
	for k,v in pairs(modes) do
		print("w=" .. v.width .. "  h=" .. v.height)
	end
	--]]
	function game:drawthings()
		for k,v in pairs(self.things) do
			if v.isalive then
				v:draw()
			end
		end
	end
	function game:drawselected()
		for k,v in pairs(self.selected) do
			v:drawselected()
		end
	end
	function game:drawwalls()
		local boundbegin = game.cam:cameraCoords(game.worldminx,game.worldminy)
		local boundend = game.cam:cameraCoords(game.worldmaxx,game.worldmaxy)
		love.graphics.setColor(ui.wallcolour)
		love.graphics.line(boundbegin.x, boundbegin.y, boundend.x, boundbegin.y, boundend.x, boundend.y, boundbegin.x, boundend.y, boundbegin.x, boundbegin.y) --square loop	
	end
	function game:drawselbox()
		if game.mousepressed then
			love.graphics.setColor(ui.selboxcolour)
			love.graphics.rectangle( "line", game.selstartx, game.selstarty, love.mouse:getX() - game.selstartx, love.mouse:getY() - game.selstarty)
		end
	end
	function game:draw()
		game:drawwalls()
		game:drawthings()
		game:drawselected()
		game:drawselbox()
	end
	function game:clickdown(x, y, button)
		if button == "l" then
			game.mousepressed = true
			game.selstartx = x
			game.selstarty = y
		end
	end
	function game:clickup(x, y, button)
		if button == "l" then
			game.selected = nil
			game.selected = {}
			game.mousepressed = false
			local selstart = game.cam:worldCoords(game.selstartx, game.selstarty)
			local selend = game.cam:worldCoords(x,y)
			--constrain to within the active area
			if selstart.x > game.worldmaxx then selstart.x = game.worldmaxx end
			if selstart.x < game.worldminx then selstart.x = game.worldminx end
			if selstart.y > game.worldmaxy then selstart.y = game.worldmaxy end
			if selstart.y < game.worldminy then selstart.y = game.worldminy end
			if selend.x > game.worldmaxx then selend.x = game.worldmaxx end
			if selend.x < game.worldminx then selend.x = game.worldminx end
			if selend.y > game.worldmaxy then selend.y = game.worldmaxy end
			if selend.y < game.worldminy then selend.y = game.worldminy end

			if (math.abs(selend.x - selstart.x) < 3) or (math.abs(selend.y - selstart.y) < 3) then --selection is small enough to be a click	
				for k,v in pairs(game.things) do
					if v.shape:testPoint(selend.x,selend.y) then 
						if v.isship then table.insert(game.selected, v) end
					end
				end
			else
				for k,v in pairs(game.things) do
					local xmax
					local xmin
					local ymax
					local ymin
					if selend.x > selstart.x then
						xmax = selend.x
						xmin = selstart.x
					else
						xmax = selstart.x
						xmin = selend.x
					end
					if selend.y > selstart.y then
						ymax = selend.y
						ymin = selstart.y
					else
						ymax = selstart.y
						ymin = selend.y
					end
					if v.body:getX() <= xmax and v.body:getX() >= xmin and v.body:getY() <= ymax and v.body:getY() >= ymin then
						if v.isship then table.insert(game.selected, v) end
					end
				end

			end
		elseif button == "r" then
			local clickedthing = false --Checks if the click hits anything
			local selend = game.cam:worldCoords(x,y)
			--restrict coordinates to within the world
			if selend.x > game.worldmaxx then selend.x = game.worldmaxx end
			if selend.x < game.worldminx then selend.x = game.worldminx end
			if selend.y > game.worldmaxy then selend.y = game.worldmaxy end
			if selend.y < game.worldminy then selend.y = game.worldminy end

			for k,v in pairs(game.things) do
				if v.shape:testPoint(selend.x, selend.y) then 
					clickedthing = true
					for k2,v2 in pairs (game.selected) do
						if v2 ~= v then
							v2.order.func = orders.follow --Currently, ordered to follow whatever is clicked
							v2.order.data = v
						end
					end
				end
			end
			if clickedthing == false then
				--Right-clicked empty space
				local empty = true --If empty, I have nothing selected.
				for k,v in pairs(game.selected) do
					empty = false
				end
				if empty == false then --I have some ships selected to give orders to.
					for k,v in pairs(game.selected) do
						v.order.func = orders.move --Currently, ordered to move to wherever was clicked
						v.order.data = waypoint.newwaypoint(selend.x, selend.y)
					end
				end
			end

		end
	end
	function game:getcollide(x,y)
		return true
	end

end


function love.draw()
	ui:draw()
end

function love.update(dt)
	ui:update(dt)
	local camspeed = 100
	local turnspeed = 1000

	if love.keyboard.isDown("left") then
		game.cam:move(-camspeed*dt, 0)
	end
	if love.keyboard.isDown("right") then
		game.cam:move(camspeed*dt,0)
	end
	if love.keyboard.isDown("up") then
		game.cam:move(0,-camspeed*dt)
	end
	if love.keyboard.isDown("down") then
		game.cam:move(0,camspeed*dt)
	end
	if love.keyboard.isDown("kp+") then
		game.cam.zoom = 2
	end
	if love.keyboard.isDown("kp-") then
		game.cam.zoom = 0.5
	end
	if love.keyboard.isDown("kpenter") then
		game.cam.zoom = 1
	end

	ui:update(dt)

	if game.paused == false then
		game.world:update(dt)
		for k,v in pairs(game.things) do
			if v.isalive then
				v:update(dt)
			elseif v.body:isFrozen() then
				table.remove(game.things, k)
			end
		end
		if game.manualship then
			if love.keyboard.isDown("w") then
				game.manualship.body:applyForce(game.manualship.thrust * dt * math.cos(game.manualship.body:getAngle()), game.manualship.thrust * dt * math.sin(game.manualship.body:getAngle()))
			end
			if love.keyboard.isDown("s") then
				game.manualship.body:applyForce(-game.manualship.thrust * dt * math.cos(game.manualship.body:getAngle()), -game.manualship.thrust * dt * math.sin(game.manualship.body:getAngle()))
			end
			if love.keyboard.isDown("a") then
				game.manualship.body:applyTorque(-game.manualship.torque*dt)
			end
			if love.keyboard.isDown("d") then
				game.manualship.body:applyTorque(game.manualship.torque*dt)
			end
		end
	end
end


