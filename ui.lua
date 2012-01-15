local ui = {}

	ui = {
	red = {255,0,0,255},
	green = {0,255,0,255},
	blue = {0,0,255,255},
	white = {255,255,255,255},
	black = {0,0,0,255},
	panelcol = {127,127,127,127},
	healthbarheight = 2,
	clickedpanel = false,
	elements = {},
	ui.clickdown = function(self, x, y, button)

	end,
	ui.clickup = function(self, x, y, button)

	end,
	ui.update(self, dt)

	end,
}

return ui
