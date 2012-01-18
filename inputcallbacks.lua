local ui = require "ui.lua"
local waypoint = require "waypoint.lua"
local orders = require "orders.lua"
local projectile = require "projectile.lua"
function love.keypressed(key)

end

function love.keyreleased(key)
	if key == "p" then
		game.paused = not game.paused
	elseif key == " " and game.manualship then
		game.manualship:fire()
	elseif key == "m" and table.maxn(game.selected) == 1 and game.selected[1].team == ui.team then
		game.manualship = game.selected[1]
	end
end

function love.mousepressed(x, y, button)
	ui:clickdown(x,y,button)
end

function love.mousereleased(x,y,button)
	ui:clickup(x, y, button)
end

function add(a, b, coll)
	local vx
	local vy
	vx, vy = coll:getVelocity()
	local vel = math.sqrt(vx*vx + vy*vy)
	if a.isship and b.isship then
		local adamage = vel*b.body:getMass()
		local bdamage = vel*a.body:getMass()
		a.hp = a.hp - adamage --NOTE: Collision damage deals huge amounts of damage when ships rub against each other
		b.hp = b.hp - bdamage
		--print("Collision: collision damage = " .. adamage .. ", " .. bdamage)
	elseif a.isprojectile and b.isship then
		local damage = vel*a.body:getMass()*a.damagemult
		b.hp = b.hp - damage
		a.isalive = false
		a.body:setX(game.worldmaxx + game.wallthickness + game.worldemptyoutside/2) --move object outside the walls of the world
		a.body:applyForce(1000,0) --Push it out of the world
	elseif b.isprojectile and a.isship then
		local damage = vel*b.body:getMass()*b.damagemult
		a.hp = a.hp - damage
		b.isalive = false
		b.body:setX(game.worldmaxx + game.wallthickness + game.worldemptyoutside/2) --move object outside the walls of the world
		b.body:applyForce(1000,0) --Push it out of the world
	elseif a.isprojectile and b.isprojectile then
		--print("SWEET!")
		a.isalive = false
		b.isalive = false
		a.body:setX(game.worldmaxx + game.wallthickness + game.worldemptyoutside/2) --move object outside the walls of the world
		a.body:applyForce(1000,0) --Push it out of the world
		b.body:setX(game.worldmaxx + game.wallthickness + game.worldemptyoutside/2) --move object outside the walls of the world
		b.body:applyForce(1000,0) --Push it out of the world
	elseif a.issensor and b.isship then
		--print(a.ship.name .. " detected " .. b.name)
		a.ship.visible[b] = true --Adds the detected ship to a list of things visible.
	elseif b.issensor and a.isship then
		--print(b.ship.name .. " detected " .. a.name)
		b.ship.visible[a] = true --Adds the detected ship to a list of things visible.
	end

end

function persist(a,b, coll)
	
end

function rem(a,b,coll)
	if a.issensor and b.isship then
		--print(a.ship.name .. " lost track of " .. b.name)
		a.ship.visible[b] = nil --Removes the lost ship from the list of things visible.
	elseif b.issensor and a.isship then
		--print(b.ship.name .. " lost track of " .. a.name)
		b.ship.visible[a] = nil --Removes the lost ship from the list of things visible.
	end
end
