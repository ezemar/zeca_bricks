local S = minetest.get_translator("zeca_bricks")

zeca_bricks = {}
zeca_bricks.modname = core.get_current_modname()
zeca_bricks.modpath = core.get_modpath(zeca_bricks.modname)

dofile(zeca_bricks.modpath .. "/functions.lua")

local files = minetest.get_dir_list(zeca_bricks.modpath .. "/textures")

local two_x_one_cbox = {
    type = "fixed",
    fixed = {-0.5, -0.5, 1.5, 0.5, 0.5, -0.5}		
}

local one_x_one_slab_cbox = {
    type = "fixed",
    fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}		
}

local two_x_one_slab_cbox = {
    type = "fixed",
    fixed = {
	{-0.5, -0.5, 0.5, 0.5, 0, -0.5},
	{-0.5, -0.5, 1.5, 0.5, 0, 0.5}
	}
}           
	--  A     B   C    D   E   F 
        
local function rotate_and_place(itemstack, placer, pointed_thing)
	local p0 = pointed_thing.under
	local p1 = pointed_thing.above
	local param2 = 0

	if placer then
		local placer_pos = placer:get_pos()
		if placer_pos then
			local diff = vector.subtract(p1, placer_pos)
			param2 = minetest.dir_to_facedir(diff)
			-- The player places a node on the side face of the node he is standing on
			if p0.y == p1.y and math.abs(diff.x) <= 0.5 and math.abs(diff.z) <= 0.5 and diff.y < 0 then
				-- reverse node direction
				param2 = (param2 + 2) % 4
			end
		end

		local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
		local fpos = finepos.y % 1

		if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
				or (fpos < -0.5 and fpos > -0.999999999) then
			param2 = param2 + 20
			if param2 == 21 then
				param2 = 23
			elseif param2 == 23 then
				param2 = 21
			end
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end

local function warn_if_exists(nodename)
	if minetest.registered_nodes[nodename] then
		minetest.log("warning", "Overwriting slab brick node: " .. nodename)
	end
end

function make_node_def(name, model, tiles, selbox, colbox, not_in_creative_inventory)
	not_in_creative_inventory = not_in_creative_inventory or 1
	
	return {
		description = name,
		tiles = {
			tiles
		},
		drawtype = "mesh",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		mesh = model,
		visual_scale = 0.5,
		wield_scale = {x = 0.5, y = 0.5, z = 0.5},
		groups = {cracky=0, oddly_breakable_by_hand = 3},
		selection_box = selbox,
		collision_box = colbox,
		is_ground_content = false,
		sounds = node_sound_zeca_bricks_defaults(),
	
		--rotation
		on_place = function(itemstack, placer, pointed_thing)
			local under = minetest.get_node(pointed_thing.under)
			local wield_item = itemstack:get_name()
			local player_name = placer and placer:get_player_name() or ""

			if under and under.name:find("^zeca_bricks:2x1_slab_") then
				-- place slab using under node orientation
				local dir = minetest.dir_to_facedir(vector.subtract(
					pointed_thing.above, pointed_thing.under), true)

				local p2 = under.param2

				-- Placing a slab on an upside down slab should make it right-side up.
				if p2 >= 20 and dir == 8 then
					p2 = p2 - 20
				-- same for the opposite case: slab below normal slab
				elseif p2 <= 3 and dir == 4 then
					p2 = p2 + 20
				end

				-- else attempt to place node with proper param2

				--for _, file_name in ipairs(files) do
				--minetest.chat_send_player("singleplayer", string.gsub(file_name,".png",""))
				--end
				
				minetest.item_place_node(ItemStack(wield_item), placer, pointed_thing, p2)
				if not minetest.is_creative_enabled(player_name) then
					itemstack:take_item()
				end
				return itemstack
			else
				
			return rotate_and_place(itemstack, placer, pointed_thing)
							
			end
					
		end,
		--rotation	

	}
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

--register a brick-node for each texture on texture directory
for _, file_name in ipairs(files) do
	
	color_name = string.gsub(file_name, ".png", "")
	color_name_first_cap = firstToUpper(color_name)
	
	minetest.register_node("zeca_bricks:1x1_".. color_name .. "_brick", make_node_def( color_name_first_cap .." Brick 2x1","1x1_brick.obj", file_name, box, box))
	minetest.register_node("zeca_bricks:2x1_".. color_name .. "_brick", make_node_def( color_name_first_cap .." Brick 2x1","2x1_brick.obj", file_name, two_x_one_cbox, two_x_one_cbox))
	minetest.register_node("zeca_bricks:2x1_".. color_name .."_slab_brick", make_node_def( color_name_first_cap .." Brick Slab 2x1","2x1_slab_brick.obj", file_name, two_x_one_slab_cbox, two_x_one_slab_cbox))
	minetest.register_node("zeca_bricks:1x1_".. color_name .."_slab_brick", make_node_def( color_name_first_cap .." Brick Slab 1x1","1x1_slab_brick.obj", file_name, one_x_one_slab_cbox, one_x_one_slab_cbox))

end