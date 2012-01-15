local ui = {
	red = {255,0,0,255},
	green = {0,255,0,255},
	blue = {0,0,255,255},
	white = {255,255,255,255},
	black = {0,0,0,255},
	transparency = 127,
	panelcol = {127,127,127,nil},--currently nil because I can't set it to "transparency" yet
	healthbarheight = 2,
	clickedpanel = false,
	activeelement = nil,
	elements = {},
	clickdown = function(self, x, y, button)
		local endpoint = table.maxn(self.elements)
		local current = endpoint
		local start = 1
		while (current >= start) do
			if self.elements[current]:getcollide(x,y) then
				self.elements[current]:clickdown(x,y,button)
				break
			else
				current = current - 1
			end
		end
	end,
	clickup = function(self, x, y, button)

	end,
	update = function(self, dt)
		for k,v in pairs(self.elements) do
			if v.update then v:update(dt) end
		end
	end,
	draw = function(self)
		for k,v in pairs(self.elements) do
			v:draw()
		end
	end,
}
ui.panelcol[4] = ui.transparency --can't set it in the constructor
--table.insert(ui.elements, things) COMMENTED OUT BECAUSE IT IS MADE IN love.load



return ui
