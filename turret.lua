local turret = {}
local ui = require"ui.lua"

local turrettemplate = {
	parent = nil, --Thing the turret is attached to
	body = nil, --Turrets have a physical existence
	shape = nil, --Turrets can collide
	image = nil, --Turret is visible
	joint = nil, --Thing that attachs turret to parent
	cx = nil, --Value depends on dimensions of image
	cy = nil, --^
	imagescale = 1,
	isalive = true,
	torque = 10,
	angdamp = 5,
	draw = function(self)
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		local colour = self.parent.colour or ui.white
		love.graphics.setColor(colour)
		love.graphics.draw(self.image, pos.x, pos.y, self.body:getAngle() + game.cam.rot,
		game.cam.zoom * self.imagescale, game.cam.zoom * self.imagescale, self.cx, self.cy)
	end,
	update = function(self, dt)

	end,
}
turrettemplate.__index = turrettemplate -- look up in shiptemplate

function turret.newturret(parent, x, y, mass, radius, image)
	x = x or 0
	y = y or 0
	mass = mass or 0.05
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
