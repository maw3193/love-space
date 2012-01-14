local projectile = {}

local projectile_template = {
	isprojectile = true,
	isalive = true,
	thrust = 0.1,
	damagemult = 10,
	function temp:draw()
		local pos = game.cam:cameraCoords(self.body:getX(), self.body:getY())
		love.graphics.setColor(temp.colour)
		love.graphics.draw(self.image, pos.x, pos.y, self.body:getAngle(), game.cam.zoom*self.imagescale, game.cam.zoom*self.imagescale, self.image:getWidth()/2, self.image:getHeight()/2)
	end,
	function temp:update(dt)
		if self.body:isFrozen() then
			self.isalive = false
		end
	end,
}
projectile_template.__index = projectile_template

function projectile.newprojectile(x, y, vx, vy, angle, mass, radius, image, colour, team)
	local temp = setmetatable({}, projectile_template)

	temp.cx = radius
	temp.cy = radius
	temp.image = love.graphics.newImage(image)
	temp.imagescale = 2*radius/temp.image:getWidth()
	temp.colour = colour
	temp.body = love.physics.newBody(game.world, x, y, mass, mass)
	temp.body:setBullet(true)
	temp.shape = love.physics.newCircleShape(temp.body, 0, 0, radius)
	temp.shape:setData(temp)
	temp.shape:setFilterData(game.collgroups.projectiles, game.collgroups.ships + game.collgroups.projectiles, -team)

	temp.body:setAngle(angle)
	temp.body:setLinearVelocity(vx, vy)
	temp.body:applyImpulse(math.cos(angle)*temp.thrust, math.sin(angle)*temp.thrust)

	return temp
end

return projectile
