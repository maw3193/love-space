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
	game.selendx = 0
	game.selendy = 0
	game.mousepressed = false
	game.wallcolour = {255,0,0,255}
	game.selboxcolour = {0,255,0,255}
	game.selectedcolour = {0,255,0,127}

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
	

	game.things.ship1 = ship.defaultship()
	table.insert(game.things, ship.newship(50,50,1,16,"art/ship32.png", ui.red, 2))
	table.insert(game.things, ship.newship(-50,50,1,16,"art/ship32.png", ui.white, 2))
	table.insert(game.things, ship.newship(50,-50,1,16,"art/ship32.png", ui.green, 2))
	table.insert(game.things, ship.newship(-50,-50,1,16,"art/ship32.png", ui.blue, 2))
	game.cam = camera(vector(0,0),1,0)
	game.cam:attach()

	table.insert(ui.panels, panels.newpanel())

	--[[
	local modes = love.graphics.getModes()
	for k,v in pairs(modes) do
		print("w=" .. v.width .. "  h=" .. v.height)
	end
	--]]
end

function love.draw()
	local boundbegin = game.cam:cameraCoords(game.worldminx,game.worldminy)
	local boundend = game.cam:cameraCoords(game.worldmaxx,game.worldmaxy)
	love.graphics.setColor(game.wallcolour)
	love.graphics.line(boundbegin.x, boundbegin.y, boundend.x, boundbegin.y, boundend.x, boundend.y, boundbegin.x, boundend.y, boundbegin.x, boundbegin.y) --square loop

	if game.mousepressed then 
		love.graphics.setColor(game.selboxcolour)
		love.graphics.rectangle("line", game.selstartx, game.selstarty, love.mouse.getX() - game.selstartx, love.mouse.getY() - game.selstarty)
	end

	for k,v in pairs(game.things) do
		if v.isalive then
			v:draw()
		end
	end
	for k,v in pairs(game.selected) do
		v:drawselected()
	end

	--DRAW UI LAST
	for k,v in pairs(ui.panels) do
		v:draw()
	end
end

function love.update(dt)
	local camspeed = 100
	local thrust = 1000	
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

	for k,v in pairs(ui.panels) do
		v:update(dt)
	end

	if game.paused == false then
		game.world:update(dt)
		for k,v in pairs(game.things) do
			if v.isalive then
				v:update(dt)
			elseif v.body:isFrozen() then
				table.remove(game.things, k)
			end
		end

		if love.keyboard.isDown("w") then
			game.things.ship1.body:applyForce(thrust * dt * math.cos(game.things.ship1.body:getAngle()), thrust * dt * math.sin(game.things.ship1.body:getAngle()))
		end
		if love.keyboard.isDown("s") then
			game.things.ship1.body:applyForce(-thrust * dt * math.cos(game.things.ship1.body:getAngle()), -thrust * dt * math.sin(game.things.ship1.body:getAngle()))
		end
		if love.keyboard.isDown("a") then
			game.things.ship1.body:applyTorque(-turnspeed*dt)
		end
		if love.keyboard.isDown("d") then
			game.things.ship1.body:applyTorque(turnspeed*dt)
		end
	end
end


