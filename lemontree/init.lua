--
-- Lemontree
--

local modname = "lemontree"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

-- Lemon Fruit

minetest.register_node("lemontree:lemon", {
	description = S("Lemon"),
	drawtype = "plantlike",
	tiles = {"lemontree_lemon.png"},
	inventory_image = "lemontree_lemon.png",
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
		minetest.set_node(pos, {name = "lemontree:lemon", param2 = 1})
	end,
})

-- lemontree

local function grow_new_lemontree_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-2, y = pos.y, z = pos.z-2}, modpath.."/schematics/lemontree.mts", "0", nil, false)
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.00005,
			spread = {x = 250, y = 250, z = 250},
			seed = 5690,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"deciduous_forest"},
		y_min = 1,
		y_max = 5000,
		schematic = modpath.."/schematics/lemontree.mts",
		flags = "place_center_x, place_center_z, force_placement",
		rotation = "random",
	})
end
if mg_name == "v6" then
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.00005,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		y_min = 1,
		y_max = 5000,
		schematic = modpath.."/schematics/lemontree.mts",
		flags = "place_center_x, place_center_z, force_placement",
		rotation = "random",
	})
end

--
-- Nodes
--

minetest.register_node("lemontree:sapling", {
	description = S("Lemon Tree Sapling"),
	drawtype = "plantlike",
	tiles = {"lemontree_sapling.png"},
	inventory_image = "lemontree_sapling.png",
	wield_image = "lemontree_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_lemontree_tree,
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
			"lemontree:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)
		return itemstack
	end,
})

minetest.register_node("lemontree:trunk", {
	description = S("Lemon Tree Trunk"),
	tiles = {
		"lemontree_trunk_top.png",
		"lemontree_trunk_top.png",
		"lemontree_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
})

-- lemontree wood
minetest.register_node("lemontree:wood", {
	description = S("Lemon Tree Wood"),
	tiles = {"lemontree_wood.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- lemontree tree leaves
minetest.register_node("lemontree:leaves", {
	description = S("Lemon Tree Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"lemontree_leaves.png"},
	inventory_image = "lemontree_leaves.png",
	wield_image = "lemontree_leaves.png",
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"lemontree:sapling"}, rarity = 20},
			{items = {"lemontree:leaves"}}
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
	output = "lemontree:wood 4",
	recipe = {{"lemontree:trunk"}}
})

minetest.register_craft({
	type = "fuel",
	recipe = "lemontree:trunk",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "lemontree:wood",
	burntime = 7,
})

minetest.register_lbm({
	name = "lemontree:convert_lemontree_saplings_to_node_timer",
	nodenames = {"lemontree:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

default.register_leafdecay({
	trunks = {"lemontree:trunk"},
	leaves = {"lemontree:leaves"},
	radius = 3,
})

--Stairs

if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab(
		"lemontree_trunk",
		"lemontree:trunk",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"lemontree_wood.png"},
		S("Lemon Tree Stair"),
		S("Lemon Tree Slab"),
		default.node_sound_wood_defaults()
	)
end

if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"lemontree:sapling", grow_new_lemontree_tree, "soil"},
	})
end

if minetest.get_modpath("cork") ~= nil then
	minetest.register_node("lemontree:trunk_nobark", {
		description = S("Lemon Tree Trunk"),
		tiles = {
			"lemontree_trunk_top.png",
			"lemontree_trunk_top.png",
			"lemontree_trunk_nobark.png"
		},
		groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
		paramtype2 = "facedir",
		is_ground_content = false,
		on_place = minetest.rotate_node,
	})

	minetest.register_craft({
		output = "lemontree:wood 4",
		recipe = {{"lemontree:trunk_nobark"}}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "lemontree:trunk_nobark",
		burntime = 25,
	})
end
