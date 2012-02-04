local turret = {}
local ui = require"ui"
local projectile = require"projectile"
local turrettemplate = {
	parent = nil, --Thing the turret is attached to
	body = nil, --Turrets have a physical existence
	shape = nil, --Turrets can collide
	image = nil, --Turret is visible
	joint = nil, --Thing that attachs turret to parent
	cx = nil, --Value depends on dimensions of image
	cy = nil, --^
	projectile = projectile.newprojectile,
	imagescale = 1,
	isalive = true,
	isturret = true,
	target = nil,
	torque = 10,
	angdamp = 2,
	-- fire rate limiter code
	fireinterval = 1,
	firecharge = 0,
	draw = function(self)
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		local colour = self.parent.colour or ui.white
		love.graphics.setColor(colour)
		love.graphics.draw(self.image, pos.x, pos.y, self.body:getAngle() + game.cam.rot,
		game.cam.zoom * self.imagescale, game.cam.zoom * self.imagescale, self.cx, self.cy)
	end,
	update = function(self, dt)
		self.firecharge = self.firecharge + dt
		if not self.parent.isalive then
			self.isalive = false
		end
		if not self.target then --Needs to find a new target. 
			for k,v in pairs (self.parent.visible) do --Go through all the parent's visible ships.
				if k.team ~= self.parent.team then --the turret knows the ship has detected an enemy ship.
					self.target = k
					break
				end
			end
		end
		if self.target then
			if self.target.isalive then
				--find the angle between self and target
				local dx = self.target.body:getX() - self.body:getX()
				local dy = self.target.body:getY() - self.body:getY()
				local tang = math.atan2(dy, dx)
				local ang = self.body:getAngle()
				local dang = tang - ang
				if dang > math.pi then dang = dang - 2*math.pi end
				if dang < -math.pi then dang = dang + 2*math.pi end
				self.body:applyTorque(dang*self.torque*dt)
				self:fire()
			else
				self.target = nil
			end
		end
	end,

	canfire = function(self)
		return self.firecharge >= self.fireinterval
	end,

	fire = function(self) --takes the constructor to create the required bullet
		if self:canfire() then
			local vx, vy = self.body:getLinearVelocity()
			table.insert(game.things, self.projectile(self.body:getX(), self.body:getY(), vx, vy, self.body:getAngle(), 0.01, 4, "art/shell16.png", self.parent.colour, self.parent.team))
			self.firecharge = 0
		end
	end,

}
turrettemplate.__index = turrettemplate -- look up in shiptemplate

function turret.newturret(parent, x, y, mass, radius, image)
	x = x or 0
	y = y or 0
	mass = mass or 0.1
	image = image or "art/cannon16.png"
	radius = radius or 8
	local temp = setmetatable({}, turrettemplate)
	local angle = parent.body:getAngle()
	local worldx, worldy = parent.body:getWorldPoint(x, y)
	--local worldx = parent.body:getX() + x*math.cos(angle) - y*math.sin(angle) --translate x,y arguments for local coordinates into
	--local worldy = parent.body:getY() + x*math.sin(angle) + y*math.cos(angle) -- world coordinates
	temp.parent = parent
	temp.body = love.physics.newBody(game.world, worldx, worldy, mass, mass)
	temp.body:setAngularDamping(temp.angdamp)
	temp.image = love.graphics.newImage(image)
	temp.cx = temp.image:getWidth()/2
	temp.cy = temp.image:getHeight()/2
	temp.shape = love.physics.newCircleShape(temp.body, 0, 0, radius)
	temp.shape:setData(temp)
	temp.shape:setFilterData(game.collgroups.ships, --Classifies as a ship
					game.collgroups.walls + game.collgroups.ships + game.collgroups.projectiles, --Ships collide with walls,ships,bullet
					-parent.team) --collision group is the player number. -ve means no collision within that group.

	temp.imagescale = radius*2/temp.image:getWidth()
	temp.joint = love.physics.newRevoluteJoint(temp.parent.body, temp.body, worldx, worldy)
	return temp
end
return turret
