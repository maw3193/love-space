local panel_elements = {}

local ui = require"ui.lua"
local panels = require"panels.lua"

local textboxtemplate = {
	panel = nil, --the panel it belongs to, can't set in constructor.
	x = 0, --x, y coordinates within the panel
	y = 0,
	text = "Default text",
	width = nil, --can set a maximum width of the 
	alignmode = "left",
	size = ui.font12,

	draw = function(self)
		local limit
		if width then
			limit = width
		else
			limit = self.panel.width - self.x
		end
		love.graphics.setColor(ui.textcolour)
		love.graphics.setFont(self.size)
		love.graphics.printf(self.text, self.x + self.panel.x, self.y + self.panel.y, limit, self.alignmode)
	end,

	getcollide = function(self, x, y) --getcollide for elements are local coordinates
		return false --text boxes are unclickable
	end,

	clickdown = function(self, x, y, button)
		--clicking text does nothing
	end,
	clickup = function(self, x, y, button)
		--do nothing
	end,
	update = function(self, dt)
		--do nothing for a text box
	end,
}
textboxtemplate.__index = textboxtemplate

function panel_elements.newtextbox(panel, x, y, text, width, align, size)
	local temp = setmetatable({}, textboxtemplate)
	temp.panel = panel
	temp.x = x
	temp.y = y
	temp.text = text
	temp.width = width
	temp.colour = colour
	temp.alignmode = align
	temp.size = size

	return temp
end

local buttontemplate = {
	--Button is bounded by a box, draws an icon left/middle/right, draws text left/middle/right.
	--Has three background colours: untouched, hover and clicked.
	--Has a flag for toggle or push button.
	--Has a callback for pressed and released.
	panel = nil,
	x = 0,
	y = 0,
	width = 50, 
	height = 50,
	text = "",
	textalign = "center",
	font = ui.font12,
	icon = nil,
	iconalign = "center",
	iconscale = 1,
	iconcol = ui.white,
	clickcol = ui.buttonclickcol,
	hovercol = ui.buttonhovercol,
	basecol = ui.buttonbasecol,
	textcol = ui.textcolour,
	hovered = false,
	clicked = false,
	toggle = false,
	onhover = nil,
	ondown = nil, --Multi-purpose: mouse down for non-toggle, toggled on for toggle
	onup = nil,	--Multi-purpose: mouse up for non-toggle, toggled off for toggle

	draw = function(self)
		--DRAW BACKGROUND
		if self.clicked then
			love.graphics.setColor(self.clickcol)
		elseif self.hovered then
			love.graphics.setColor(self.hovercol)
		else
			love.graphics.setColor(self.basecol)
		end
		love.graphics.rectangle("fill", self.x + self.panel.x, self.y + self.panel.y, self.width, self.height)
		--DRAW ICON
		if self.icon then
			local xoff, yoff
			local ox = self.icon:getWidth()/2
			local oy = self.icon:getHeight()/2
			if self.iconalign == "left" then
				xoff = self.icon:getWidth()*self.iconscale/2
			elseif self.iconalign == "center" then
				xoff = self.width/2
			elseif self.iconalign == "right" then
				xoff = self.width - self.icon:getWidth()*self.iconscale/2
			end
			yoff = self.height/2
			love.graphics.setColor(self.iconcol)
			love.graphics.draw(self.icon, xoff + self.panel.x + self.x, yoff + self.panel.y + self.y, 0, self.iconscale, self.iconscale, ox, oy)
		end
		--DRAW TEXT
		if self.text then
		love.graphics.setFont(font)
		love.graphics.setColor(self.textcol)
		love.graphics.printf(self.text, self.x + self.panel.x, self.y + self.panel.y, self.width, self.textalign)
		end
	end,
	getcollide = function(self, x, y)
		if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
			return true
		else
			return false
		end
	end,
	clickdown = function(self, x, y, button)
		if not self.toggle then
			self.clicked = true
			if self.ondown then self:ondown() end
			--print("button clicked down")
		end

	end,
	clickup = function(self, x, y, button)
		if self.toggle then
			if self.clicked then
				self.clicked = false
				if self.onup then self:onup() end
				--print("button toggled up")
			else
				self.clicked = true
				if self.ondown then self:ondown() end
				--print("button toggled down")
			end
		else
			self.clicked = false
			if self.onup then self:onup() end
			--print("button clicked up")
		end
	end,
	update = function(self, dt)
		local xmin = self.x + self.panel.x
		local xmax = xmin + self.width
		local ymin = self.y + self.panel.y
		local ymax = ymin + self.height
		local mx = love.mouse.getX()
		local my = love.mouse.getY()
		if mx >= xmin and mx <= xmax and my >= ymin and my <= ymax then
			self.hovered = true
		else
			self.hovered = false
		end
		--do nothing for a text box
	end,
	
}
buttontemplate.__index = buttontemplate

function panel_elements.newbutton(panel,x, y, w, h, text, icon, scale, toggle, ondown, onup)
	local temp = setmetatable({}, buttontemplate)
	temp.panel = panel
	temp.x = x
	temp.y = y
	temp.width = w
	temp.height = h
	temp.text = text
	if icon then temp.icon = love.graphics.newImage(icon) end
	temp.iconscale = scale
	temp.toggle = toggle
	temp.ondown = ondown
	temp.onup = onup
	return temp
end

return panel_elements
