local orders = {}
local vector = require"lib/vector"

function orders.move(dt, ship, data)
	orders.dumbmove(dt, ship, data)
	orders.smarterturn(dt, ship, data)
	if ship.shape:testPoint(data.x, data.y) then
		ship.order.func = nil
		ship.order.data = nil
	end
end

function orders.follow(dt, ship, data)
	if ship ~= game.manualship then
		local temp = {}
		temp.x = data.body:getX()
		temp.y = data.body:getY()
		orders.movedist(dt, ship, temp) --Lazy workaround
		orders.smarterturn(dt, ship, temp) --Next time: make it move away if too close
	end
	if data.isalive == false then
		ship.order.func = nil
		ship.order.data = nil
	end
end

function orders.attack(dt, ship, data)
	if ship ~= game.manualship then
	local temp = {}
		temp.x = data.body:getX()
		temp.y = data.body:getY()
		orders.movedist(dt, ship, temp) --Lazy workaround
		orders.smarterturn(dt, ship, temp) --Next time: make it move away if too close
		orders.fireon(dt, ship, temp)
	end
	if data.isalive == false then
		ship.order.func = nil
		ship.order.data = nil
	end
end

function orders.fireon(dt, ship, data)
	local angletolerance = math.pi/8
	local current = vector(ship.body:getX(), ship.body:getY())
	local dest = vector(data.x, data.y)
	local diff = dest - current
	local tang = math.atan2(diff.y, diff.x)
	local dang = tang - ship.body:getAngle()
	if dang <= angletolerance and dang >= -angletolerance then
		ship:fire()
	end	
end

function orders.smarterturn(dt, ship, data)
	local current = vector(ship.body:getX(), ship.body:getY())
	local dest = vector(data.x, data.y)
	local diff = dest - current
	local tang = math.atan2(diff.y, diff.x)
	local dang = tang - ship.body:getAngle()
	if dang > math.pi then dang = dang - 2*math.pi end
	if dang < -math.pi then dang = dang + 2*math.pi end
	if dang > 0 then
		ship.body:applyTorque(ship.torque*dt*math.abs(dang))
	elseif dang < 0 then
		ship.body:applyTorque(-ship.torque*dt*math.abs(dang))
	end
end


function orders.dumbmove(dt, ship,data)
	local angletolerance = math.pi/4

	local current = vector(ship.body:getX(), ship.body:getY())
	local dest = vector(data.x, data.y)
	local diff = dest - current
	local tang = math.atan2(diff.y, diff.x)
	local dang = tang - ship.body:getAngle()
	if dang > math.pi then dang = dang - 2*math.pi end
	if dang < -math.pi then dang = dang + 2*math.pi end
	local facex = math.cos(ship.body:getAngle())
	local facey = math.sin(ship.body:getAngle())

	if  dang < angletolerance and dang > -angletolerance then --target is within tolerance.
		ship.body:applyForce(facex*ship.thrust*dt, facey*ship.thrust*dt)
	end
end

function orders.movedist(dt, ship, data)
	local angletolerance = math.pi/4
	local movedist = 100

	local current = vector(ship.body:getX(), ship.body:getY())
	local dest = vector(data.x, data.y)
	local diff = dest - current
	local tang = math.atan2(diff.y, diff.x)
	local dang = tang - ship.body:getAngle()
	if dang > math.pi then dang = dang - 2*math.pi end
	if dang < -math.pi then dang = dang + 2*math.pi end
	local facex = math.cos(ship.body:getAngle())
	local facey = math.sin(ship.body:getAngle())

	if  dang < angletolerance and dang > -angletolerance then --target is within tolerance.
		local ddist = diff:len() - movedist
		local fracddist = math.abs(ddist/movedist)
		if fracddist > 1 then fracddist = 1 end

		if diff:len() > movedist then
			ship.body:applyForce(facex*ship.thrust*fracddist*dt, facey*ship.thrust*fracddist*dt)
		else
			--ship.body:applyForce(-facex*ship.thrust*fracddist*dt, -facey*ship.thrust*fracddist*dt)
			ship.body:applyForce(-facex*ship.thrust*dt, -facey*ship.thrust*dt) 
		end
	end
end

--[[
function orders.teleport(dt, ship, data)
	ship.body:setX(data.x)
	ship.body:setY(data.y)
end

function orders.magicmove(dt, ship, data)
	local speed = 50
	local current = vector(ship.body:getX(), ship.body:getY())
	local dest = vector(data.x, data.y)
	local diff = dest - current

	diff:normalize_inplace()
	ship.body:setX(ship.body:getX() + diff.x*speed*dt)
	ship.body:setY(ship.body:getY() + diff.y*speed*dt)
end

function orders.face(dt, ship, data)
	local current = vector(ship.body:getX(), ship.body:getY())
	local dest = vector(data.x, data.y)
	local diff = dest - current
	local tang = math.atan2(diff.y, diff.x)
	ship.body:setAngle(tang)
end

function orders.magicturn(dt, ship, data)
	local turnspeed = 1
	local current = vector(ship.body:getX(), ship.body:getY())

	local dest = vector(data.x, data.y)
	local diff = dest - current
	local tang = math.atan2(diff.y, diff.x)
	local dang = tang - ship.body:getAngle()
	if dang > math.pi then dang = dang - 2*math.pi end
	if dang < -math.pi then dang = dang + 2*math.pi end
	if math.abs(dang) <= turnspeed*dt then
		ship.body:setAngle(tang)
	elseif dang > 0 then
		ship.body:setAngle(ship.body:getAngle() + turnspeed*dt)
	elseif dang < 0 then
		ship.body:setAngle(ship.body:getAngle() - turnspeed*dt)
	end
end

function orders.dumbturn(dt, ship, data)
	local current = vector(ship.body:getX(), ship.body:getY())
	local dest = vector(data.x, data.y)
	local diff = dest - current
	local tang = math.atan2(diff.y, diff.x)
	local dang = tang - ship.body:getAngle()
	if dang > math.pi then dang = dang - 2*math.pi end
	if dang < -math.pi then dang = dang + 2*math.pi end
	if dang > 0 then
		ship.body:applyTorque(ship.torque*dt)
	elseif dang < 0 then
		ship.body:applyTorque(-ship.torque*dt)
	end
end
--]]

return orders
