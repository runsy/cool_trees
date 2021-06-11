--
-- Mahogany
--

local modname = "mahogany"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

-- Mahogany

local function grow_new_mahogany_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-3, y = pos.y, z = pos.z-3}, modpath.."/schematics/mahogany.mts", "0", nil, false)
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		name = "mahogany:mahogany_tree",
		deco_type = "schematic",
		place_on = {"default:dirt_with_rainforest_litter"},
		sidelen = 16,
		noise_params = {
			offset = 0.005,
			scale = 0.005,
			spread = {x = 250, y = 250, z = 250},
			seed = 345,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"rainforest"},
		height = 2,
		y_min = 1,
		y_max = 62,
		schematic = modpath.."/schematics/mahogany.mts",
		flags = "place_center_x, place_center_z, force_placement",
		rotation = "random",
	})
end

--
-- Nodes
--

minetest.register_node("mahogany:sapling", {
	description = S("Mahogany Tree Sapling"),
	drawtype = "plantlike",
	tiles = {"mahogany_sapling.png"},
	inventory_image = "mahogany_sapling.png",
	wield_image = "mahogany_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_mahogany_tree,
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
			"mahogany:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_node("mahogany:trunk", {
	description = S("Mahogany Trunk"),
	tiles = {
		"mahogany_trunk_top.png",
		"mahogany_trunk_top.png",
		"mahogany_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
})

-- mahogany wood
minetest.register_node("mahogany:wood", {
	description = S("Mahogany Wood"),
	tiles = {"mahogany_wood.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- mahogany tree leaves
minetest.register_node("mahogany:leaves", {
	description = S("Mahogany Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"mahogany_leaves.png"},
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"mahogany:sapling"}, rarity = 20},
			{items = {"mahogany:leaves"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,
})

--
-- Creeper/Vines...
--

minetest.register_node("mahogany:creeper", {
	description = S("Mahogany Creeper"),
	drawtype = "nodebox",
	walkable = true,
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"mahogany_creeper.png"},
	use_texture_alpha = true,
	inventory_image = "mahogany_creeper.png",
	wield_image = "mahogany_creeper.png",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.49, 0.5, 0.5, 0.5}
	},
	groups = {
		snappy = 2, flammable = 3, oddly_breakable_by_hand = 3, choppy = 2, carpet = 1, leafdecay = 3, leaves = 1
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("mahogany:flower_creeper", {
	description = S("Mahogany Flower Creeper"),
	drawtype = "nodebox",
	walkable = true,
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"mahogany_flower_creeper.png"},
	use_texture_alpha = true,
	inventory_image = "mahogany_flower_creeper.png",
	wield_image = "mahogany_flower_creeper.png",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.49, 0.5, 0.5, 0.5}
	},
	groups = {
		snappy = 2, flammable = 3, oddly_breakable_by_hand = 3, choppy = 2, carpet = 1, leafdecay = 3, leaves = 1, falling_node = 1
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("mahogany:hanging_creeper", {
	description = S("Mahogany Hanging Creeper"),
	drawtype = "nodebox",
	walkable = true,
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"mahogany_hanging_creeper.png"},
	use_texture_alpha = true,
	inventory_image = "mahogany_hanging_creeper.png",
	wield_image = "mahogany_hanging_creeper.png",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.0, 0.5, 0.5, 0.0}
	},
	groups = {
		snappy = 2, flammable = 3, oddly_breakable_by_hand = 3, choppy = 2, carpet = 1, leafdecay = 3, leaves = 1, falling_node = 1
	},
	sounds = default.node_sound_leaves_defaults(),
})

--
-- Craftitems
--

--
-- Recipes
--

minetest.register_craft({
	output = "mahogany:wood 4",
	recipe = {{"mahogany:trunk"}}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mahogany:trunk",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mahogany:wood",
	burntime = 7,
})


minetest.register_lbm({
	name = "mahogany:convert_mahogany_saplings_to_node_timer",
	nodenames = {"mahogany:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

default.register_leafdecay({
	trunks = {"mahogany:trunk"},
	leaves = {"mahogany:leaves"},
	radius = 3,
})

-- Fence
if minetest.settings:get_bool("cool_fences", true) then
	local fence = {
		description = S("Mahogany Wood Fence"),
		texture =  "mahogany_wood.png",
		material = "mahogany:wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	}
	default.register_fence("mahogany:fence", table.copy(fence)) 
	fence.description = S("Mahogany Fence Rail")
	default.register_fence_rail("mahogany:fence_rail", table.copy(fence))
	
	if minetest.get_modpath("doors") ~= nil then
		fence.description = S("Mahogany Fence Gate")
		doors.register_fencegate("mahogany:gate", table.copy(fence))
	end
end

--Stairs

if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab(
		"mahogany_trunk",
		"mahogany:trunk",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"mahogany_wood.png"},
		S("Mahogany Stair"),
		S("Mahogany Slab"),
		default.node_sound_wood_defaults()
	)
end

-- stairsplus/moreblocks
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("mahogany", "wood", "mahogany:wood", {
		description = "Mahogany",
		tiles = {"mahogany_wood.png"},
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
		sounds = default.node_sound_wood_defaults(),
	})
end

--Support for bonemeal

if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"mahogany:sapling", grow_new_mahogany_tree, "soil"},
	})
end
