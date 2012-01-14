local waypoint = {}

function waypoint.newwaypoint(x,y)
	local temp = {} --temporary waypoint
	temp.x = x
	temp.y = y
	temp.iswaypoint = true
	temp.radius = 2
	temp.colour = {0,255,0,127}
	function temp:draw()
		local pos = game.cam:cameraCoords(self.x, self.y)
		love.graphics.setColor(temp.colour)
		love.graphics.line(pos.x - temp.radius*game.cam.zoom, pos.y, pos.x + temp.radius*game.cam.zoom, pos.y)--horizontal part of cross
		love.graphics.line(pos.x, pos.y - temp.radius*game.cam.zoom, pos.x, pos.y + temp.radius*game.cam.zoom)--vertical part of cross
	end
	--print("created waypoint")
return temp
end
return waypoint

