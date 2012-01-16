local ui = require"ui.lua"
local waypoint = {}

local waypoint_template = {
	iswaypoint = true,
	radius = 2,
	colour = {0,255,0,ui.transparency},
	draw = function(self)
		local pos = game.cam:cameraCoords(self.x, self.y)
		love.graphics.setColor(self.colour)
		love.graphics.line(pos.x - self.radius*game.cam.zoom, pos.y, pos.x + self.radius*game.cam.zoom, pos.y)--horizontal part of cross
		love.graphics.line(pos.x, pos.y - self.radius*game.cam.zoom, pos.x, pos.y + self.radius*game.cam.zoom)--vertical part of cross
	end
}
waypoint_template.__index = waypoint_template

function waypoint.newwaypoint(x,y)
	return setmetatable({x = x, y = y}, waypoint_template)
end
return waypoint

