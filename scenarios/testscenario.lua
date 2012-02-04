local ship = require"ship"
local ui = require"ui"
local panels = require"panels"
local panel_elements = require"panel_elements"
local turret = require"turret"

game.worldminx = -500
game.worldminy = -500
game.worldmaxx = 500
game.worldmaxy = 500

game.makeworld()

table.insert(game.things, ship.newship(50,50,1,16,"art/ship32.png", ui.blue, 1, "Blue 1"))
table.insert(game.things, ship.newship(0,-50,1,16,"art/ship32.png", ui.red, 2, "Red 1"))
game.manualship = game.things[1]
table.insert(game.things, turret.newturret(game.things[1], -8, -8))
table.insert(game.things, turret.newturret(game.things[1], -8, 8))
table.insert(game.things, turret.newturret(game.things[1], 8, -8))
table.insert(game.things, turret.newturret(game.things[1], 8, 8))
game.things[1].hp = 1000
game.things[1].hpmax = 1000
	
table.insert(ui.elements, game)
table.insert(ui.elements, panels.newpanel())
ui.elements[2]:addelement(panel_elements.newtextbox(ui.elements[2], 0, 0, "Spawn ship", _, "center", ui.largefont))
ui.elements[2]:addelement(panel_elements.newbutton(ui.elements[2], 0, 16, 50, 84, "", "art/ship32.png", _, false, _, ship.randomenemy))
ui.elements[2].elements[2].iconcol = ui.red
ui.elements[2]:addelement(panel_elements.newbutton(ui.elements[2],50, 16, 50, 84, "", "art/ship32.png", _, false, _, ship.randomfriend))
ui.elements[2].elements[3].iconcol = ui.blue

