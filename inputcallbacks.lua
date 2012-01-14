local waypoint = require "waypoint.lua"
local orders = require "orders.lua"
local projectile = require "projectile.lua"
function love.keypressed(key)

end

function love.keyreleased(key)
	if key == "p" then
		game.paused = not game.paused
	elseif key == " " then
		local velx, vely = game.things.ship1.body:getLinearVelocity()
		table.insert(game.things, projectile.newprojectile(game.things.ship1.body:getX(), game.things.ship1.body:getY(),
	velx, vely, game.things.ship1.body:getAngle(), 
	0.01, 4, "art/shell16.png", ui.white))
	end
end

function love.mousepressed(x, y, button)
	if button == "l" then
		game.mousepressed = true
		game.selstartx = x
		game.selstarty = y
	end
end

function love.mousereleased(x,y,button)
	if button == "l" then --Start left click behaviour
		game.selected = nil
		game.selected = {}
		game.mousepressed = false
		game.selendx = x
		game.selendy = y
		if selbox ~= nil then selbox:destroy() end
		--print("before creating box")
		game.selstart = game.cam:worldCoords(game.selstartx, game.selstarty)
		game.selend = game.cam:worldCoords(x,y)

		if game.selstart.x > game.worldmaxx then game.selstart.x = game.worldmaxx end
		if game.selstart.x < game.worldminx then game.selstart.x = game.worldminx end
		if game.selstart.y > game.worldmaxy then game.selstart.y = game.worldmaxy end
		if game.selstart.y < game.worldminy then game.selstart.y = game.worldminy end
		if game.selend.x > game.worldmaxx then game.selend.x = game.worldmaxx end
		if game.selend.x < game.worldminx then game.selend.x = game.worldminx end
		if game.selend.y > game.worldmaxy then game.selend.y = game.worldmaxy end
		if game.selend.y < game.worldminy then game.selend.y = game.worldminy end

		if (math.abs(game.selend.x - game.selstart.x) < 3) or (math.abs(game.selend.y - game.selstart.y) < 3) then --Selection small, so point.
			for k,v in pairs(game.things) do
				if v.shape:testPoint(game.selend.x,game.selend.y) then 
					--game.collisiontext = game.collisiontext .. "selected"
					--print("selected")
					if v.isship then table.insert(game.selected, v) end
				end
			end

		else --Selection large, so use box.
			for k,v in pairs(game.things) do
				local xmax
				local xmin
				local ymax
				local ymin
				if game.selend.x > game.selstart.x then
					xmax = game.selend.x
					xmin = game.selstart.x
				else
					xmax = game.selstart.x
					xmin = game.selend.x
				end
				if game.selend.y > game.selstart.y then
					ymax = game.selend.y
					ymin = game.selstart.y
				else
					ymax = game.selstart.y
					ymin = game.selend.y
				end
				if v.body:getX() <= xmax and v.body:getX() >= xmin and v.body:getY() <= ymax and v.body:getY() >= ymin then
					--game.collisiontext = game.collisiontext .. "selected"
					--print ("selected")
					if v.isship then table.insert(game.selected, v) end
				end
			end
		end
		--print("after creating box")
	end --End left click behaviour

	if button == "r" then --start right click behaviour. Ignoring lassoo select for right-clicking.
		local clickedthing = false
		game.selend = game.cam:worldCoords(x, y)
		if game.selend.x > game.worldmaxx then game.selend.x = game.worldmaxx end
		if game.selend.x < game.worldminx then game.selend.x = game.worldminx end
		if game.selend.y > game.worldmaxy then game.selend.y = game.worldmaxy end
		if game.selend.y < game.worldminy then game.selend.y = game.worldminy end
		for k,v in pairs(game.things) do
			if v.shape:testPoint(game.selend.x, game.selend.y) then 
				clickedthing = true
				for k2,v2 in pairs (game.selected) do
					if v2 ~= v then
						v2.order.func = orders.follow
						v2.order.data = v
					end
				end
			--RIGHT-CLICKED A THING
			end
		end
		if clickedthing == false then
			--Right-clicked empty space
			local empty = true --If empty, I have nothing selected.
			for k,v in pairs(game.selected) do
				empty = false
			end
			if empty == false then --I have some ships selected to give orders to.
				for k,v in pairs(game.selected) do
					v.order.func = orders.move
					v.order.data = waypoint.newwaypoint(game.selend.x, game.selend.y) --data1 is a waypoint when move order.
				end
			end
		end
	end
end

function add(a, b, coll)
	if a.isship and b.isship then
		local vx
		local vy
		vx, vy = coll:getVelocity()
		local vel = math.sqrt(vx*vx + vy*vy)
		local adamage = vel*b.body:getMass()
		local bdamage = vel*a.body:getMass()
		a.hp = a.hp - adamage --NOTE: Collision damage deals huge amounts of damage when ships rub against each other
		b.hp = b.hp - bdamage
		--print("Collision: collision damage = " .. adamage .. ", " .. bdamage)
	end
end

function persist(a,b, coll)
	
end

function rem(a,b,coll)

end
