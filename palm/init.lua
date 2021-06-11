-- Palm Tree
--

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

local modname = "palm"
local modpath = minetest.get_modpath(modname)

local function grow_new_palm_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-5, y = pos.y, z = pos.z-3}, modpath.."/schematics/palmtree.mts", "0", nil, false)
end

--
-- Decoration
--

minetest.register_decoration({
	name = "palm:palm_tree",
	deco_type = "schematic",
	place_on = {"default:sand"},
		sidelen = 16,
		noise_params = {
			offset = 0.001,
			scale = 0.002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2337,
			octaves = 3,
			persist = 0.66
		},
	biomes = {"sandstone_desert_ocean", "desert_ocean"},
	y_min = 1,
	y_max = 2,
	schematic = modpath.."/schematics/palmtree.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

--
-- Nodes
--

minetest.register_node("palm:sapling", {
	description = S("Palm Sapling"),
	drawtype = "plantlike",
	tiles = {"palm_sapling.png"},
	inventory_image = "palm_sapling.png",
	wield_image = "palm_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_palm_tree,
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
			"palm:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

-- palm trunk (thanks to VanessaE for palm textures)
minetest.register_node("palm:trunk", {
	description = S("Palm Trunk"),
	tiles = {
		"palm_trunk_top.png",
		"palm_trunk_top.png",
		"palm_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
})

-- palm wood
minetest.register_node("palm:wood", {
	description = S("Palm Wood"),
	tiles = {"palm_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- palm tree leaves
minetest.register_node("palm:leaves", {
	description = S("Palm Leaves"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				{-0.5, -0.4375, -0.5, 0.5, -0.5, 0.5},
			},
		},
	tiles = {
		"palm_leaves.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"palm:sapling"}, rarity = 10},
			{items = {"palm:leaves"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,
})

-- Coconut (Gives 4 coconut slices, each heal 1/2 heart)
minetest.register_node("palm:coconut", {
	description = S("Coconut"),
	drawtype = "normal",
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {"palm_coconut_top.png", "palm_coconut_side.png"},
	--inventory_image = "palm_coconut_side.png",
	--wield_image = "palm_coconut_side.png",
	selection_box = {
		type = "fixed",
		fixed = {-0.31, -0.43, -0.31, 0.31, 0.44, 0.31}
	},
	groups = {
		snappy = 1, oddly_breakable_by_hand = 1, cracky = 1,
		choppy = 1, flammable = 1, leafdecay = 3, leafdecay_drop = 1
	},
	drop = "palm:coconut_slice 4",
	sounds = default.node_sound_wood_defaults(),
})

-- Candle from Wax and String/Cotton
minetest.register_node("palm:candle", {
	description = S("Coconut Wax Candle"),
	drawtype = "plantlike",
	inventory_image = "palm_candle_static.png",
	wield_image = "palm_candle_static.png",
	tiles = {
		{
			name = "palm_candle.png",
			animation={
				type="vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.0
			}
		},
	},
	paramtype = "light",
	light_source = 11,
	sunlight_propagates = true,
	walkable = false,
	groups = {dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0, 0.15 }
	},
})

if minetest.get_modpath("doors") ~= nil then
	doors.register("door_palm", {
		tiles = {{ name = "palm_door_wood.png", backface_culling = true }},
		description = S("Palm Door"),
		inventory_image = "palm_door_wood_inv.png",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		recipe = {
			{"palm:wood", "palm:wood"},
			{"palm:leaves", "palm:leaves"},
			{"palm:wood", "palm:wood"},
		}
	})
end

--
-- Craftitems
--

-- Coconut Slice (Heals half heart when eaten)
minetest.register_craftitem("palm:coconut_slice", {
	description = S("Coconut Slice"),
	inventory_image = "palm_coconut_slice.png",
	wield_image = "palm_coconut_slice.png",
	on_use = minetest.item_eat(1),
})

-- Palm Wax
minetest.register_craftitem("palm:wax", {
	description = S("Palm Wax"),
	inventory_image = "palm_wax.png",
	wield_image = "palm_wax.png",
})

--
-- Recipes
--

minetest.register_craft({
	type = "cooking",
	cooktime = 10,
	output = "palm:wax",
	recipe = "palm:leaves"
})


minetest.register_craft({
	output = "palm:wood 4",
	recipe = {{"palm:trunk"}}
})

minetest.register_craft({
	output = "palm:candle 2",
	recipe = {
		{"farming:cotton"},
		{"palm:wax"},
		{"palm:wax"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "palm:sapling",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "palm:trunk",
	burntime = 34,
})

minetest.register_craft({
	type = "fuel",
	recipe = "palm:wood",
	burntime = 9,
})

minetest.register_craft({
	type = "fuel",
	recipe = "palm:leaves",
	burntime = 2,
})

minetest.register_lbm({
	name = "palm:convert_palmtree_saplings_to_node_timer",
	nodenames = {"palm:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(1200, 2400))
	end
})

default.register_leafdecay({
	trunks = {"palm:trunk"},
	leaves = {"palm:leaves", "palm:coconut"},
	radius = 3,
})

-- Fence
if minetest.settings:get_bool("cool_fences", true) then
	local fence = {
		description = S("Palm Tree Wood Fence"),
		texture =  "palm_wood.png",
		material = "palm:wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	}
	default.register_fence("palm:fence", table.copy(fence)) 
	fence.description = S("Palm Tree Fence Rail")
	default.register_fence_rail("palm:fence_rail", table.copy(fence))
	
	if minetest.get_modpath("doors") ~= nil then
		fence.description = S("Palm Tree Fence Gate")
		doors.register_fencegate("palm:gate", table.copy(fence))
	end
end

--Stairs

if minetest.get_modpath("stairs") ~= nil then
	stairs.register_stair_and_slab(
		"palm_trunk",
		"palm:trunk",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"palm_wood.png"},
		S("Palm Tree Stair"),
		S("Palm Tree Slab"),
		default.node_sound_wood_defaults()
	)
end

-- stairsplus/moreblocks
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("palm", "wood", "palm:wood", {
		description = "Palm",
		tiles = {"palm_wood.png"},
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
		sounds = default.node_sound_wood_defaults(),
	})
end

if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"palm:sapling", grow_new_palm_tree, "soil"},
		{"palm:sapling", grow_new_palm_tree, "sand"},
	})
end
