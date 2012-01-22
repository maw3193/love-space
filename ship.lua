local ui = require("ui.lua")
local ai = require("ai.lua")
local projectile = require("projectile.lua")
--Builds the ship prototype
local ship = {}

local shiptemplate = {
	thrust = 100,
	torque = 100,
	hpmax = 100,
	sensorrange = 100,
	sensorson = false,
	firecharge = 0,
	fireinterval = 0.5,
	isship = true,
	isalive = true,
	visible = nil, --Table of all the ships it can see
	name = "Unnamed ship",
	projectile = nil,
	--Draws the ship to the display (assuming global access to game)
	draw = function(self) 
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		love.graphics.setColor(self.colour)
		love.graphics.draw(self.image, pos.x, pos.y, self.body:getAngle() + game.cam.rot, game.cam.zoom * self.imagescale, game.cam.zoom * self.imagescale, self.cx, self.cy)
	end,
	drawselected = function(self) --Draws the selection 
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		love.graphics.setColor(ui.selectedcolour)
		love.graphics.rectangle("line", pos.x - self.cx*game.cam.zoom, pos.y - self.cy*game.cam.zoom, self.radius*2*game.cam.zoom, self.radius*2*game.cam.zoom)
		self:draworder()
		self:drawhealthbar()
		self:drawname()
		if self.sensorson then self:drawsensors() end
	end,
	drawhealthbar = function(self)
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		love.graphics.setColor(ui.red)
		love.graphics.rectangle("fill", pos.x - self.cx*game.cam.zoom,
						pos.y + self.cy*game.cam.zoom,
						self.radius*2*game.cam.zoom,
						ui.healthbarheight)
		love.graphics.setColor(ui.green)
		love.graphics.rectangle("fill", pos.x - self.cx*game.cam.zoom,
						pos.y + self.cy*game.cam.zoom,
						self.radius*2*game.cam.zoom*self.hp/self.hpmax,
						ui.healthbarheight)		
	end,
	drawname = function(self)
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		love.graphics.setColor(ui.white)
		love.graphics.setFont(ui.font10)
		love.graphics.printf(self.name, pos.x - self.cx*game.cam.zoom, pos.y - self.cy*game.cam.zoom - 12, self.radius*2*game.cam.zoom, "center")
	end,
	drawsensors = function(self)
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		love.graphics.setColor(self.colour)
		love.graphics.circle("line", pos.x, pos.y, self.sensorrange*game.cam.zoom, 20)
	end,
	draworder = function(self)
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		local targpos = {}
		if self.order.data then
			if self.order.data.iswaypoint then
				targpos = game.cam:cameraCoords(self.order.data.x, self.order.data.y)
			elseif self.order.data.isship then
				targpos = game.cam:cameraCoords(self.order.data.body:getX(), self.order.data.body:getY())
			end
			love.graphics.line(pos.x, pos.y, targpos.x, targpos.y)
			self.order.data:draw()
		end
	end,

	enablesensors = function(self)
		self.sensorson = true
		self.sensors:setFilterData(game.collgroups.ships, game.collgroups.ships, self.team)
	end,
	disablesensors = function(self)
		self.sensorson = true
		self.sensors:setFilterData(0, 0, 0)
	end,

	update = function(self, dt)
		self.firecharge = self.firecharge + dt
		if self.ai then
			self.ai:update(self, dt)
		end
		if self.order.func then --Processing of orders
			self.order.func(dt, self, self.order.data)
		end
		if not self.sensorson then self:enablesensors() end
		if self.hp < 0 then
			--print("Ship should be dead!")
			self.isalive = false
			if game.manualship == self then
				game.manualship = nil
			end
			if self.order then
				self.order.func = nil
				self.order.data = nil
				for k,v in pairs(game.selected) do
					if v == self then table.remove(game.selected, k) end
				end
			end
			self.body:setX(game.worldmaxx + game.wallthickness + game.worldemptyoutside/2) --move object outside the walls of the world
			self.body:applyForce(1000,0) --Push it out of the world
		end
	end,

	canfire = function(self)
		return self.firecharge >= self.fireinterval
	end

	fire = function(self) --takes the constructor to create the required bullet
		if self:canfire() then
			local vx, vy = self.body:getLinearVelocity()
			table.insert(game.things, self.projectile(self.body:getX(), self.body:getY(), vx, vy, self.body:getAngle(), 0.01, 4, "art/shell16.png", self.colour, self.team))
			self.firecharge = 0
		end
	end
}
shiptemplate.__index = shiptemplate -- look up in shiptemplate

function ship.newship(x, y, mass, radius, image, colour, team, name) --Full constructor, assuming they're all circles.
	-- parameter default values
	x = x or 0; y = y or 0
	mass = mass or 1
	radius = radius or 16
	image = image or "art/ship32.png"
	colour = colour or ui.white
	team = team or 1
	local tempship = setmetatable({}, shiptemplate)
	local spaceangdamp = 1
	local spacelindamp = 1
	tempship.name = name
	tempship.hp = tempship.hpmax
	tempship.radius = radius
	--tempship.mass = mass
	tempship.cx = radius
	tempship.cy = radius
	tempship.team = team
	tempship.image = love.graphics.newImage(image)
	tempship.imagescale = 2*radius/tempship.image:getWidth()
	tempship.colour = colour
	tempship.body = love.physics.newBody(game.world, x, y, mass, mass)
	tempship.body:setLinearDamping(spacelindamp)
	tempship.body:setAngularDamping(spaceangdamp)
	tempship.shape = love.physics.newCircleShape(tempship.body,0,0,tempship.radius)
	tempship.shape:setData(tempship)
	tempship.shape:setFilterData(game.collgroups.ships, --Classifies as a ship
					game.collgroups.walls + game.collgroups.ships + game.collgroups.projectiles, --Ships collide with walls,ships,bullet
					-team) --collision group is the player number. -ve means no collision within that group.
	tempship.sensors = love.physics.newCircleShape(tempship.body,0,0,tempship.sensorrange)
	tempship.sensors:setSensor(true)
	tempship.sensors:setData({issensor = true, ship = tempship})
	tempship.sensors:setFilterData(0, 0, 0)
	tempship.visible = {__mode='kv'}
	tempship.ai = ai.standard
	tempship.projectile = projectile.newprojectile
	tempship.order = {}
	tempship.order.func = nil
	tempship.order.data = nil

	return tempship
end

function ship.randomenemy()
	local x = math.random(game.worldminx, game.worldmaxx)
	local y = math.random(game.worldminy, game.worldmaxy)
	table.insert(game.things, ship.newship(x, y, _, _, _, ui.red, 2))
end

return ship
