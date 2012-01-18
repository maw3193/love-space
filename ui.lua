local ui = {
	red = {255,0,0,255},
	green = {0,255,0,255},
	blue = {0,0,255,255},
	white = {255,255,255,255},
	black = {0,0,0,255},
	grey = {127,127,127,255},
	transgrey = {127,127,127,nil},
	transgreen = {0,255,0,nil},
	transparency = 127,
	wallcolour = nil, --changed to red
	selboxcolour = nil, --changed to green
	selectedcolour = nil, --changed to transgreen
	panelcol = nil,--currently nil because I can't set it to "transparency" yet
	textcolour = nil,
	linecolour = nil,
	buttonbasecol = nil,
	buttonhovercol = nil,
	buttonclickcol = nil,
	healthbarheight = 1,
	clickedpanel = false,
	activeelement = nil,
	font10 = nil,
	font12 = nil,
	font14 = nil,
	elements = {},
	team = 1,
	clickdown = function(self, x, y, button)
		local endpoint = table.maxn(self.elements)
		local current = endpoint
		local start = 1
		while (current >= start) do
			if self.elements[current]:getcollide(x,y) then
				self.elements[current]:clickdown(x,y,button)
				activeelement = self.elements[current]
				break
			else
				current = current - 1
			end
		end
	end,
	clickup = function(self, x, y, button)
		activeelement:clickup(x,y,button)
		activeelement = nil
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
ui.transgrey[4] = ui.transparency
ui.transgreen[4] = ui.transparency

ui.panelcol = ui.transgrey
ui.wallcolour = ui.red
ui.selboxcolour = ui.green
ui.selectedcolour = ui.transgreen
ui.textcolour = ui.white
ui.linecolour = ui.white
ui.buttonbasecol = ui.transgrey
ui.buttonhovercol = ui.grey
ui.buttonclickcol = ui.white

ui.font10 = love.graphics.newFont(10)
ui.font12 = love.graphics.newFont(12)
ui.font14 = love.graphics.newFont(14)
--table.insert(ui.elements, things) COMMENTED OUT BECAUSE IT IS MADE IN love.load



return ui
