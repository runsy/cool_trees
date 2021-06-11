--
-- Willow
--

local modname = "willow"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

-- Willow

local function grow_new_willow_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-5, y = pos.y, z = pos.z-5}, modpath.."/schematics/willow.mts", "0", nil, false)
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		name = "willow:willow_tree",
		deco_type = "schematic",
		place_on = {"default:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.0002,
			spread = {x = 250, y = 250, z = 250},
			seed = 23,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"deciduous_forest_shore"},
		height = 2,
		y_min = -1,
		y_max = 62,
		schematic = modpath.."/schematics/willow.mts",
		flags = "place_center_x, place_center_z, force_placement",
		rotation = "random",
	})
end

--
-- Nodes
--

minetest.register_node("willow:sapling", {
	description = S("Willow Tree Sapling"),
	drawtype = "plantlike",
	tiles = {"willow_sapling.png"},
	inventory_image = "willow_sapling.png",
	wield_image = "willow_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_willow_tree,
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
			"willow:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_node("willow:trunk", {
	description = S("Willow Trunk"),
	tiles = {
		"willow_trunk_top.png",
		"willow_trunk_top.png",
		"willow_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
})

-- willow wood
minetest.register_node("willow:wood", {
	description = S("Willow Wood"),
	tiles = {"willow_wood.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- willow tree leaves
minetest.register_node("willow:leaves", {
	description = S("Willow Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"willow_leaves.png"},
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"willow:sapling"}, rarity = 20},
			{items = {"willow:leaves"}}
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
	output = "willow:wood 4",
	recipe = {{"willow:trunk"}}
})

minetest.register_craft({
	type = "fuel",
	recipe = "willow:trunk",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "willow:wood",
	burntime = 7,
})


minetest.register_lbm({
	name = "willow:convert_willow_saplings_to_node_timer",
	nodenames = {"willow:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

default.register_leafdecay({
	trunks = {"willow:trunk"},
	leaves = {"willow:leaves"},
	radius = 3,
})

-- Fence
if minetest.settings:get_bool("cool_fences", true) then
	local fence = {
		description = S("Willow Wood Fence"),
		texture =  "willow_wood.png",
		material = "willow:wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	}
	default.register_fence("willow:fence", table.copy(fence)) 
	fence.description = S("Willow Fence Rail")
	default.register_fence_rail("willow:fence_rail", table.copy(fence))
	
	if minetest.get_modpath("doors") ~= nil then
		fence.description = S("Willow Fence Gate")
		doors.register_fencegate("willow:gate", table.copy(fence))
	end
end

--Stairs

if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab(
		"willow_trunk",
		"willow:trunk",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"willow_wood.png"},
		S("Willow Stair"),
		S("Willow Slab"),
		default.node_sound_wood_defaults()
	)
end

-- stairsplus/moreblocks
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("willow", "wood", "willow:wood", {
		description = "Willow",
		tiles = {"willow_wood.png"},
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
		sounds = default.node_sound_wood_defaults(),
	})
end

if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"willow:sapling", grow_new_willow_tree, "soil"},
	})
end
