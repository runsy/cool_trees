--
-- Jacaranda
--
local modname = "jacaranda"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

-- Jacaranda

local function grow_new_jacaranda_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-3, y = pos.y, z = pos.z-3}, modpath.."/schematics/jacaranda.mts", "0", nil, false)
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		name = "jacaranda:jacaranda_tree",
		deco_type = "schematic",
		place_on = {"default:dirt_with_rainforest_litter"},
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.00005,
			spread = {x = 250, y = 250, z = 250},
			seed = 663,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"rainforest"},
		y_min = 1,
		y_max = 32,
		schematic = modpath.."/schematics/jacaranda.mts",
		flags = "place_center_x, place_center_z, force_placement",
		rotation = "random",
	})
end

--
-- Nodes
--

minetest.register_node("jacaranda:sapling", {
	description = S("Jacaranda Tree Sapling"),
	drawtype = "plantlike",
	tiles = {"jacaranda_sapling.png"},
	inventory_image = "jacaranda_sapling.png",
	wield_image = "jacaranda_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_jacaranda_tree,
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
			"jacaranda:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_node("jacaranda:trunk", {
	description = S("Jacaranda Trunk"),
	tiles = {
		"jacaranda_trunk_top.png",
		"jacaranda_trunk_top.png",
		"jacaranda_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
})

-- jacaranda wood
minetest.register_node("jacaranda:wood", {
	description = S("Jacaranda Wood"),
	tiles = {"jacaranda_wood.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- jacaranda tree leaves
minetest.register_node("jacaranda:blossom_leaves", {
	description = S("Jacaranda Blossom Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"jacaranda_blossom_leaves.png"},
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"jacaranda:sapling"}, rarity = 20},
			{items = {"jacaranda:blossom_leaves"}}
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
	output = "jacaranda:wood 4",
	recipe = {{"jacaranda:trunk"}}
})


minetest.register_craft({
	type = "fuel",
	recipe = "jacaranda:trunk",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "jacaranda:wood",
	burntime = 7,
})


minetest.register_lbm({
	name = "jacaranda:convert_jacaranda_saplings_to_node_timer",
	nodenames = {"jacaranda:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

default.register_leafdecay({
	trunks = {"jacaranda:trunk"},
	leaves = {"jacaranda:blossom_leaves"},
	radius = 3,
})

-- Fence
if minetest.settings:get_bool("cool_fences", true) then
	local fence = {
		description = S("Jaceranda Tree Wood Fence"),
		texture =  "jacaranda_wood.png",
		material = "jacaranda:wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	}
	default.register_fence("jacaranda:fence", table.copy(fence)) 
	fence.description = S("Jaceranda Tree Fence Rail")
	default.register_fence_rail("jacaranda:fence_rail", table.copy(fence))
	
	if minetest.get_modpath("doors") ~= nil then
		fence.description = S("Jaceranda Tree Fence Gate")
		doors.register_fencegate("jacaranda:gate", table.copy(fence))
	end
end

--Stairs

if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab(
		"jacaranda_trunk",
		"jacaranda:trunk",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"jacaranda_wood.png"},
		S("Jacaranda Tree Stair"),
		S("Jacaranda Tree Slab"),
		default.node_sound_wood_defaults()
	)
end

-- stairsplus/moreblocks
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("jacaranda", "wood", "jacaranda:wood", {
		description = "Jacaranda Tree",
		tiles = {"jacaranda_wood.png"},
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
		sounds = default.node_sound_wood_defaults(),
	})
end

if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"jacaranda:sapling", grow_new_jacaranda_tree, "soil"},
	})
end


