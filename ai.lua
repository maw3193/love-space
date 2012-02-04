local ai = {}
orders = require"orders"

ai.standard = {
	update = function(self, ship, dt)
		if ship.order.func == nil then --The ship is idle
			--Check if it senses anything hostile.
			for k,_ in pairs(ship.visible) do
				if k.body and k.team ~= ship.team then
					--print(k.name)
					ship.order.func = orders.attack
					ship.order.data = k
					break --Primitive AI, does not consider which target is nearest
				end
			end
		end
	end,
}

return ai
