--
-- Maple
--

local modname = "maple"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

-- Maple

local function grow_new_maple_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-3, y = pos.y-1, z = pos.z-3}, modpath.."/schematics/maple.mts", "0", nil, false)
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then

	if minetest.get_modpath("rainf") then
		place_on = "rainf:meadow"
		biomes = "rainf"
		offset = 0.0005
		scale = 0.0002
	else
		place_on = "default:dirt_with_grass"
		biomes = "grassland"
		offset = 0.0002
		scale = 0.0002
	end

	minetest.register_decoration({
		name = "maple:maple_tree",
		deco_type = "schematic",
		place_on = {place_on},
		sidelen = 16,
		noise_params = {
			offset = offset,
			scale = scale,
			spread = {x = 250, y = 250, z = 250},
			seed = 3462,
			octaves = 3,
			persist = 0.66
		},
		biomes = {biomes},
		y_min = 1,
		y_max = 62,
		schematic = modpath.."/schematics/maple.mts",
		flags = "place_center_x, place_center_z, force_placement",
		rotation = "random",
	})
end

--
-- Nodes
--

minetest.register_node("maple:sapling", {
	description = S("Maple Tree Sapling"),
	drawtype = "plantlike",
	tiles = {"maple_sapling.png"},
	inventory_image = "maple_sapling.png",
	wield_image = "maple_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_maple_tree,
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
			"maple:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_node("maple:trunk", {
	description = S("Maple Trunk"),
	tiles = {
		"maple_trunk_top.png",
		"maple_trunk_top.png",
		"maple_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
})

-- maple wood
minetest.register_node("maple:wood", {
	description = S("Maple Wood"),
	tiles = {"maple_wood.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- maple tree leaves
minetest.register_node("maple:leaves", {
	description = S("Maple Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"maple_leaves.png"},
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"maple:sapling"}, rarity = 20},
			{items = {"maple:leaves"}}
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
	output = "maple:wood 4",
	recipe = {{"maple:trunk"}}
})

minetest.register_craft({
	type = "fuel",
	recipe = "maple:trunk",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "maple:wood",
	burntime = 7,
})


minetest.register_lbm({
	name = "maple:convert_maple_saplings_to_node_timer",
	nodenames = {"maple:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

default.register_leafdecay({
	trunks = {"maple:trunk"},
	leaves = {"maple:leaves"},
	radius = 3,
})

-- Fence
if minetest.settings:get_bool("cool_fences", true) then
	local fence = {
		description = S("Maple Wood Fence"),
		texture =  "maple_wood.png",
		material = "maple:wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	}
	default.register_fence("maple:fence", table.copy(fence)) 
	fence.description = S("Maple Fence Rail")
	default.register_fence_rail("maple:fence_rail", table.copy(fence))
	
	if minetest.get_modpath("doors") ~= nil then
		fence.description = S("Maple Fence Gate")
		doors.register_fencegate("maple:gate", table.copy(fence))
	end
end

--Stairs

if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab(
		"maple_trunk",
		"maple:trunk",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"maple_wood.png"},
		S("Maple Stair"),
		S("Maple Slab"),
		default.node_sound_wood_defaults()
	)
end

-- stairsplus/moreblocks
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("maple", "wood", "maple:wood", {
		description = "Maple",
		tiles = {"maple_wood.png"},
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
		sounds = default.node_sound_wood_defaults(),
	})
end

if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"maple:sapling", grow_new_maple_tree, "soil"},
	})
end

--Door

if minetest.get_modpath("doors") ~= nil then
	doors.register("door_maple_wood", {
			tiles = {{ name = "maple_door_wood.png", backface_culling = true }},
			description = S("Maple Wood Door"),
			inventory_image = "maple_item_wood.png",
			groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
			recipe = {
				{"maple:wood", "maple:wood"},
				{"maple:wood", "maple:wood"},
				{"maple:wood", "maple:wood"},
			}
	})
end


