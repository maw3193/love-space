local panels = {}

	local ui = require"ui.lua"

local paneltemplate = {
	x = 0,
	y = 0,
	width = 100,
	height = 100,
	isgrabbed = false,
	grabbedx = 0,
	grabbedy = 0,
	colour = ui.panelcol,
	draw = function(self)
		love.graphics.setColor(self.colour)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	end,
	getcollide = function(self, x, y)
		if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
			return true

		else
			return false
		end
	end,
	startgrabbed = function(self, x, y)
		self.isgrabbed = true
		self.grabbedx = x - self.x
		self.grabbedy = y - self.y
	end,
	movegrabbed = function(self)
		self.x = love.mouse.getX() - self.grabbedx
		self.y = love.mouse.getY() - self.grabbedy
		if self.x < 0 then self.x = 0 end
		if self.x + self.width > love.graphics.getWidth() then self.x = love.graphics.getWidth() - self.width end
		if self.y < 0 then self.y = 0 end
		if self.y + self.height > love.graphics.getHeight() then self.y = love.graphics.getHeight() - self.height end

	end,
	endgrabbed = function(self)
		self.isgrabbed = false
		self.grabbedx = 0
		self.grabbedy = 0
	end,
	update = function(self, dt)
		if self.isgrabbed then self:movegrabbed() end
	end,

}
paneltemplate.__index = paneltemplate -- look up in template

function panels.newpanel(x, y, w, h, col)
	local temp = setmetatable({}, paneltemplate)
	if x then temp.x = x end
	if y then temp.y = y end
	if w then temp.width = w end
	if h then temp.height = h end
	if col then temp.colour = col end

	return temp
end


return panels
