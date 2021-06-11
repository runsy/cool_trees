--
-- Cherrytree
--
local modname = "cherrytree"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")
local fruit_grow_time = 1200

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

-- Cherry Fruit

minetest.register_node("cherrytree:cherries", {
	description = S("Cherries"),
	drawtype = "plantlike",
	tiles = {"cherrytree_cherries.png"},
	inventory_image = "cherrytree_cherries.png",
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
		minetest.set_node(pos, {name = "cherrytree:cherries", param2 = 1})
	end,

	on_dig = function(pos, node, digger)
		if digger:is_player() then
			local inv = digger:get_inventory()
			if inv:room_for_item("main", "cherrytree:cherries") then
				inv:add_item("main", "cherrytree:cherries")
			end
		end
		minetest.remove_node(pos)
		pos.y = pos.y + 1
		local node_above = minetest.get_node_or_nil(pos)
		if node_above and node_above.param2 == 0 and node_above.name == "cherrytree:blossom_leaves" then
			--20% of variation on time
			local twenty_percent = fruit_grow_time * 0.2
			local grow_time = math.random(fruit_grow_time - twenty_percent, fruit_grow_time + twenty_percent)
			minetest.get_node_timer(pos):start(grow_time)
		end
	end,
})

-- Cherrytree

local function grow_new_cherrytree_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-2, y = pos.y, z = pos.z-2}, modpath.."/schematics/cherrytree.mts", "0", nil, false)
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		name = "cherrytree:cherry_tree",
		deco_type = "schematic",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.00005,
			spread = {x = 250, y = 250, z = 250},
			seed = 1242,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"deciduous_forest"},
		y_min = 1,
		y_max = 32,
		schematic = modpath.."/schematics/cherrytree.mts",
		flags = "place_center_x, place_center_z, force_placement",
		rotation = "random",
	})
end

--
-- Nodes
--

minetest.register_node("cherrytree:sapling", {
	description = S("Cherrytree Tree Sapling"),
	drawtype = "plantlike",
	tiles = {"cherrytree_sapling.png"},
	inventory_image = "cherrytree_sapling.png",
	wield_image = "cherrytree_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_cherrytree_tree,
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
			"cherrytree:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_node("cherrytree:trunk", {
	description = S("Cherrytree Trunk"),
	tiles = {
		"cherrytree_trunk_top.png",
		"cherrytree_trunk_top.png",
		"cherrytree_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
})

-- cherrytree wood
minetest.register_node("cherrytree:wood", {
	description = S("Cherrytree Wood"),
	tiles = {"cherrytree_wood.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- cherrytree tree leaves
minetest.register_node("cherrytree:blossom_leaves", {
	description = S("Cherrytree Blossom Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"cherrytree_blossom_leaves.png"},
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"cherrytree:sapling"}, rarity = 20},
			{items = {"cherrytree:blossom_leaves"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,

	on_timer = function(pos)
		pos.y = pos.y - 1
		local node = minetest.get_node_or_nil(pos)
		if node and node.name == "air" then
			minetest.set_node(pos, {name = "cherrytree:cherries"})
			return false
		else
			return true
		end
    end
})

-- cherrytree tree leaves
minetest.register_node("cherrytree:leaves", {
	description = S("Cherrytree Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"cherrytree_leaves.png"},
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"cherrytree:sapling"}, rarity = 20},
			{items = {"cherrytree:leaves"}}
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
	output = "cherrytree:wood 4",
	recipe = {{"cherrytree:trunk"}}
})


minetest.register_craft({
	type = "fuel",
	recipe = "cherrytree:trunk",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "cherrytree:wood",
	burntime = 7,
})


minetest.register_lbm({
	name = "cherrytree:convert_cherrytree_saplings_to_node_timer",
	nodenames = {"cherrytree:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

default.register_leafdecay({
	trunks = {"cherrytree:trunk"},
	leaves = {"cherrytree:leaves"},
	radius = 3,
})

-- Fence
if minetest.settings:get_bool("cool_fences", true) then
	local fence = {
		description = S("Cherry Tree Wood Fence"),
		texture =  "cherrytree_wood.png",
		material = "cherrytree:wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	}
	default.register_fence("cherrytree:fence", table.copy(fence)) 
	fence.description = S("Cherry Tree Fence Rail")
	default.register_fence_rail("cherrytree:fence_rail", table.copy(fence))
	
	if minetest.get_modpath("doors") ~= nil then
		fence.description = S("Cherry Tree Fence Gate")
		doors.register_fencegate("cherrytree:gate", table.copy(fence))
	end
end

--Stairs

if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab(
		"cherrytree_trunk",
		"cherrytree:trunk",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"cherrytree_wood.png"},
		S("Cherry Tree Stair"),
		S("Cherry Tree Slab"),
		default.node_sound_wood_defaults()
	)
end

-- stairsplus/moreblocks
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("cherrytree", "wood", "cherrytree:wood", {
		description = "Cherry Tree",
		tiles = {"cherrytree_wood.png"},
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
		sounds = default.node_sound_wood_defaults(),
	})
end

--Support for bonemeal

if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"cherrytree:sapling", grow_new_cherrytree_tree, "soil"},
	})
end
