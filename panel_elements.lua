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
	size = 12,
	colour = ui.white,

	draw = function(self)
		local limit
		if width then
			limit = width
		else
			limit = self.panel.width - self.x
		end
		love.graphics.setColor(self.colour)
		love.graphics.printf(self.text, self.x + self.panel.x, self.y + self.panel.y, limit, self.alignmode)
	end,
	getcollide = function(self, x, y)
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

function panel_elements.newtextbox(panel, x, y, text, width, colour, align, size)
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

return panel_elements
