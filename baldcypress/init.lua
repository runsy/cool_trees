--
-- Bald Cypress
--
local modname = "baldcypress"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

-- Bald Cypress

local function grow_new_baldcypress_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-4, y = pos.y, z = pos.z-4}, modpath.."/schematics/baldcypress.mts", "0", nil, false)
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	name = "baldcypress:baldcypress_tree",
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:sand"},
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.0005,
			spread = {x = 250, y = 250, z = 250},
			seed = 678,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"coniferous_forest_ocean"},
		height = 2,
		y_min = 0,
		y_max = 0,
		schematic = modpath.."/schematics/baldcypress.mts",
		flags = "place_center_x, place_center_z, force_placement",
		rotation = "random",
	})
end

--
-- Nodes
--

minetest.register_node("baldcypress:sapling", {
	description = S("Bald Cypress Tree Sapling"),
	drawtype = "plantlike",
	tiles = {"baldcypress_sapling.png"},
	inventory_image = "baldcypress_sapling.png",
	wield_image = "baldcypress_sapling.png",
	paramtype = "light",
	--sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_baldcypress_tree,
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
			"baldcypress:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_node("baldcypress:trunk", {
	description = S("Bald Cypress Trunk"),
	tiles = {
		"baldcypress_trunk_top.png",
		"baldcypress_trunk_top.png",
		"baldcypress_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
})

-- baldcypress wood
minetest.register_node("baldcypress:wood", {
	description = S("Bald Cypress Wood"),
	tiles = {"baldcypress_wood.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- baldcypress tree leaves
minetest.register_node("baldcypress:leaves", {
	description = S("Bald Cypress Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"baldcypress_leaves.png"},
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"baldcypress:sapling"}, rarity = 20},
			{items = {"baldcypress:leaves"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,
})

minetest.register_node("baldcypress:dry_branches", {
	description = S("Bald Cypress Dry Branches"),
	drawtype = "nodebox",
	walkable = true,
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"baldcypress_dry_branches.png"},
	use_texture_alpha = true,
	inventory_image = "baldcypress_dry_branches.png",
	wield_image = "baldcypress_dry_branches.png",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.49, 0.5, 0.5, 0.5}
	},
	groups = {
		snappy = 2, flammable = 3, oddly_breakable_by_hand = 3, choppy = 2, carpet = 1, leafdecay = 3, leaves = 1
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("baldcypress:liana", {
	description = S("Bald Cypress Liana"),
	drawtype = "nodebox",
	walkable = false,
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"baldcypress_liana.png"},
	use_texture_alpha = true,
	inventory_image = "baldcypress_liana.png",
	wield_image = "baldcypress_liana.png",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, 0.0, 0.25, 0.5, 0.0}
	},
	groups = {
		snappy = 2, flammable = 3, oddly_breakable_by_hand = 3, choppy = 2, carpet = 1, leafdecay = 3, leaves = 1,
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
	output = "baldcypress:wood 4",
	recipe = {{"baldcypress:trunk"}}
})


minetest.register_craft({
	type = "fuel",
	recipe = "baldcypress:trunk",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "baldcypress:wood",
	burntime = 7,
})


minetest.register_lbm({
	name = "baldcypress:convert_baldcypress_saplings_to_node_timer",
	nodenames = {"baldcypress:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

default.register_leafdecay({
	trunks = {"baldcypress:trunk"},
	leaves = {"baldcypress:leaves"},
	radius = 3,
})

-- Fence
if minetest.settings:get_bool("cool_fences", true) then
	local fence = {
		description = S("Bald Cypress Wood Fence"),
		texture =  "baldcypress_wood.png",
		material = "baldcypress:wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	}
	default.register_fence("baldcypress:fence", table.copy(fence)) 
	fence.description = S("Bald Cypress Fence Rail")
	default.register_fence_rail("baldcypress:fence_rail", table.copy(fence))
	
	if minetest.get_modpath("doors") ~= nil then
		fence.description = S("Bald Cypress Fence Gate")
		doors.register_fencegate("baldcypress:gate", table.copy(fence))
	end
end

--Stairs

if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab(
		"baldcypress_trunk",
		"baldcypress:trunk",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"baldcypress_wood.png"},
		S("Bald Cypress Stair"),
		S("Bald Cypress Slab"),
		default.node_sound_wood_defaults()
	)
end

-- stairsplus/moreblocks
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("baldcypress", "wood", "baldcypress:wood", {
		description = "Bald Cypress",
		tiles = {"baldcypress_wood.png"},
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
		sounds = default.node_sound_wood_defaults(),
	})
end

--Support for bonemeal

if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"baldcypress:sapling", grow_new_baldcypress_tree, "soil"},
	})
end
