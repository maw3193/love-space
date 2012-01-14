--Builds the ship prototype
local ship = {}

function ship.newship(x, y, mass, radius, image, colour) --Full constructor, assuming they're all circles.
	local tempship = {}
	local spaceangdamp = 1
	local spacelindamp = 1
	tempship.thrust = 100
	tempship.torque = 100
	tempship.hpmax = 100
	tempship.hp = tempship.hpmax
	tempship.isship = true
	tempship.isalive = true
	tempship.radius = radius
	--tempship.mass = mass
	tempship.cx = radius
	tempship.cy = radius
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
					-1) --collision group is the player number. -ve means no collision within that group.
	tempship.order = {}
	tempship.order.func = nil
	tempship.order.data = nil
	function tempship:draw() --Draws the ship to the display (assuming global access to game.
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		love.graphics.setColor(tempship.colour)
		love.graphics.draw(self.image, pos.x, pos.y, self.body:getAngle(), game.cam.zoom * self.imagescale, game.cam.zoom * self.imagescale, self.image:getWidth()/2, self.image:getHeight()/2)
	end
	function tempship:drawselected() --Draws the selection 
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		love.graphics.setColor(game.selectedcolour)
		love.graphics.rectangle("line", pos.x - tempship.cx*game.cam.zoom, pos.y - tempship.cy*game.cam.zoom, tempship.radius*2*game.cam.zoom, tempship.radius*2*game.cam.zoom)
		self:draworder()
		love.graphics.setColor(ui.red)
		love.graphics.rectangle("fill", pos.x - tempship.cx*game.cam.zoom,
						pos.y + tempship.cy*game.cam.zoom,
						tempship.radius*2*game.cam.zoom,
						ui.healthbarheight)
		love.graphics.setColor(ui.green)
		love.graphics.rectangle("fill", pos.x - tempship.cx*game.cam.zoom,
						pos.y + tempship.cy*game.cam.zoom,
						tempship.radius*2*game.cam.zoom*self.hp/self.hpmax,
						ui.healthbarheight)

		
	end
	function tempship:draworder()
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
	end

	function tempship:update(dt)
		if self.order.func then --Processing of orders
			self.order.func(dt, self, self.order.data)
		end

		if self.hp < 0 then
			--print("Ship should be dead!")
			self.isalive = false
			if self.order then
				self.order.func = nil
				self.order.data = nil
				for k,v in pairs(game.selected) do
					if v == self then table.remove(game.selected, k) end
				end
			end
			self.body:setX(game.worldmaxx + game.wallthickness + game.worldemptyoutside/2)
			self.body:applyForce(1000,0)
		end
	end

	return tempship
end



function ship.defaultship() --default
	return ship.newship(0,0,1, 16, "art/ship32.png", {255,255,255,255})
end

return ship
