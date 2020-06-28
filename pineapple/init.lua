--
-- Pineapple
--

local modname = "pineapple"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

-- Pineapple

local function grow_new_pineapple_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x, y = pos.y, z = pos.z}, modpath.."/schematics/pineapple.mts", "0", nil, false)
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:dirt_with_rainforest_litter"},
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.00004,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"rainforest"},
		y_min = 1,
		y_max = 5000,
		schematic = modpath.."/schematics/pineapple.mts",
		flags = "place_center_x, place_center_z,  force_placement",
		rotation = "random",
		place_offset_y = 1,
	})
end
if mg_name == "v6" then
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.00004,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		y_min = 1,
		y_max = 5000,
		schematic = modpath.."/schematics/pineapple.mts",
		flags = "place_center_x, place_center_z,  force_placement",
		rotation = "random",
		place_offset_y = 1,
	})
end
--
-- Nodes
--

-- pineapple
minetest.register_node("pineapple:pineapple", {
	description = S("Pineapple"),
	drawtype = "plantlike_rooted",
	visual_scale = 1.0,
	tiles = {"pineapple_pineapple.png"},
	special_tiles = {
	nil,
	nil,
	"pineapple_pineapple_leaves.png",
	"pineapple_pineapple_leaves.png",
	"pineapple_pineapple_leaves.png",
	"pineapple_pineapple_leaves.png"
	},	
	inventory_image = "pineapple_pineapple_inv.png",
	wield_image = "pineapple_pineapple_inv.png",
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,
	on_use = minetest.item_eat(3, "pineapple:sapling"),
})


minetest.register_node("pineapple:sapling", {
	description = S("Pineapple Sapling"),
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"pineapple_pineapple_leaves.png"},
	inventory_image = "pineapple_pineapple_leaves.png",
	wield_image = "pineapple_pineapple_leaves.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_pineapple_tree,
	selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
	},
	groups = {snappy = 2, dig_immediate = 3, flammable = 2,
		attached_node = 1, sapling = 1},
	sounds = default.node_sound_leaves_defaults(),

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(2400,4800))
	end,

	on_place = function(itemstack, placer, pointed_thing)
		itemstack = default.sapling_on_place(itemstack, placer, pointed_thing,
			"pineapple:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

--
-- Craftitems
--

minetest.register_lbm({
	name = "pineapple:convert_pineapple_saplings_to_node_timer",
	nodenames = {"pineapple:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

if minetest.get_modpath("bonemeal") ~= nil then	
	bonemeal:add_sapling({
		{"pineapple:sapling", grow_new_pineapple_tree, "soil"},
	})
end
