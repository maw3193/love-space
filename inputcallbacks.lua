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
		local velx, vely = game.manualship.body:getLinearVelocity()
		table.insert(game.things, projectile.newprojectile(game.manualship.body:getX(), game.manualship.body:getY(),
	velx, vely, game.manualship.body:getAngle(), 
	0.01, 4, "art/shell16.png", ui.white, game.manualship.team))
	elseif key == "m" and table.maxn(game.selected) == 1 then
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
		print("SWEET!")
		a.isalive = false
		b.isalive = false
		a.body:setX(game.worldmaxx + game.wallthickness + game.worldemptyoutside/2) --move object outside the walls of the world
		a.body:applyForce(1000,0) --Push it out of the world
		b.body:setX(game.worldmaxx + game.wallthickness + game.worldemptyoutside/2) --move object outside the walls of the world
		b.body:applyForce(1000,0) --Push it out of the world
		
	end

end

function persist(a,b, coll)
	
end

function rem(a,b,coll)

end
