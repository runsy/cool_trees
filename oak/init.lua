--
-- Oak
--

local modname = "oak"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

--Acorn

minetest.register_node("oak:acorn", {
	description = S("Acorn"),
	drawtype = "plantlike",
	tiles = {"oak_acorn.png"},
	inventory_image = "oak_acorn.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-3 / 16, -7 / 16, -3 / 16, 3 / 16, 4 / 16, 3 / 16}
	},
	groups = {fleshy = 3, dig_immediate = 3, flammable = 2,
		leafdecay = 3, leafdecay_drop = 1},
	on_use = minetest.item_eat(2),
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = function(pos, placer, itemstack)
		minetest.set_node(pos, {name = "oak:acorn", param2 = 1})
	end,
})

-- oak

local function grow_new_oak_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-5, y = pos.y, z = pos.z-5}, modpath.."/schematics/oak.mts", "0", nil, false)
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then

	if minetest.get_modpath("rainf") then
		place_on = "rainf:meadow"
		biomes = "rainf"
		offset = 0.0008
		scale = 0.00004
	else
		place_on = "default:dirt_with_grass"
		biomes = "grassland"
		offset = 0.0008
		scale = 0.00004
	end

	minetest.register_decoration({
		name = "oak:oak_tree",
		deco_type = "schematic",
		place_on = {place_on},
		sidelen = 16,
		noise_params = {
			offset = offset,
			scale = scale,
			spread = {x = 250, y = 250, z = 250},
			seed = 6431,
			octaves = 3,
			persist = 0.66
		},
		biomes = {biomes},
		y_min = 1,
		y_max = 80,
		schematic = modpath.."/schematics/oak.mts",
		flags = "place_center_x, place_center_z,  force_placement",
		rotation = "random",
		place_offset_y = 0,
	})
end

--
-- Nodes
--

minetest.register_node("oak:sapling", {
	description = S("Oak Sapling"),
	drawtype = "plantlike",
	tiles = {"oak_sapling.png"},
	inventory_image = "oak_sapling.png",
	wield_image = "oak_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_oak_tree,
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
			"oak:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_node("oak:trunk", {
	description = S("Oak Trunk"),
	tiles = {
		"oak_trunk_top.png",
		"oak_trunk_top.png",
		"oak_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
})

-- oak wood
minetest.register_node("oak:wood", {
	description = S("Oak Wood"),
	tiles = {"oak_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- oak tree leaves
minetest.register_node("oak:leaves", {
	description = S("Oak Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"oak_leaves.png"},
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"oak:sapling"}, rarity = 20},
			{items = {"oak:leaves"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,
})

--
-- Craftitems
--

--
-- Recipes
--

minetest.register_craft({
	output = "oak:wood 4",
	recipe = {{"oak:trunk"}}
})

minetest.register_craft({
	type = "fuel",
	recipe = "oak:trunk",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "oak:wood",
	burntime = 7,
})


minetest.register_lbm({
	name = "oak:convert_oak_saplings_to_node_timer",
	nodenames = {"oak:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

default.register_leafdecay({
	trunks = {"oak:trunk"},
	leaves = {"oak:leaves"},
	radius = 3,
})

-- Fence
if minetest.settings:get_bool("cool_fences", true) then
	local fence = {
		description = S("Oak Wood Fence"),
		texture =  "oak_wood.png",
		material = "oak:wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	}
	default.register_fence("oak:fence", table.copy(fence)) 
	fence.description = S("Oak Fence Rail")
	default.register_fence_rail("oak:fence_rail", table.copy(fence))
	
	if minetest.get_modpath("doors") ~= nil then
		fence.description = S("Oak Fence Gate")
		doors.register_fencegate("oak:gate", table.copy(fence))
	end
end

--Stairs

if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab(
		"oak_trunk",
		"oak:trunk",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"oak_wood.png"},
		S("Oak Stair"),
		S("Oak Slab"),
		default.node_sound_wood_defaults()
	)
end

-- stairsplus/moreblocks
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("oak", "wood", "oak:wood", {
		description = "Oak",
		tiles = {"oak_wood.png"},
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
		sounds = default.node_sound_wood_defaults(),
	})
end

if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"oak:sapling", grow_new_oak_tree, "soil"},
	})
end

if minetest.get_modpath("doors") ~= nil then
	doors.register("door_oak_wood", {
			tiles = {{ name = "oak_door_wood.png", backface_culling = true }},
			description = S("Oak Wood Door"),
			inventory_image = "oak_item_wood.png",
			groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
			recipe = {
				{"oak:wood", "oak:wood"},
				{"oak:wood", "oak:wood"},
				{"oak:wood", "oak:wood"},
			}
	})
end
