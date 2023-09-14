local S = minetest.get_translator("zeca_bricks")

zeca_bricks = {}
zeca_bricks.modname = core.get_current_modname()
zeca_bricks.modpath = core.get_modpath(zeca_bricks.modname)

--loading sounds
dofile(zeca_bricks.modpath .. "/functions.lua")

local files = minetest.get_dir_list(zeca_bricks.modpath .. "/textures")

--boxes
local two_x_four_cbox = {
    type = "fixed",
    fixed = {-0.5, -0.5, 1.5, 0.5, 0.5, -0.5}	
}
local two_x_two_slab_cbox = {
    type = "fixed",
    fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}		
}
local two_x_four_slab_cbox = {
    type = "fixed",
    fixed = { -0.5, -0.5, 1.5, 0.5, 0, -0.5	}
}  
local one_x_four_slab_cbox = {
    type = "fixed",
    fixed = { -0.5, -0.5, 1.5, 0, 0, -0.5	}
}           
local one_x_two_slab_cbox = {
    type = "fixed",
    fixed = {-0.5, -0.5, 0, 0.5, 0, 0.5}		
}

local one_x_two_cbox = {
    type = "fixed",
    fixed = {-0.5, -0.5, 0, 0.5, 0.5, 0.5}		
}


minetest.register_node("zeca_bricks:second_node", {
    description = "second node ghost",
    drawtype = "airlike",
    
	use_texture_alpha = true,
	--paramtype = "light",
	--sunlight_propagates = true,

    walkable     = false, -- Would make the player collide with the air node
    pointable    = false, -- You can't select the node
    diggable     = false, -- You can't dig the node
    buildable_to = false,  -- Nodes can be replace this node.
                          -- (you can place a node and remove the air node
                          -- that used to be there)

    air_equivalent = true,
    drop = "",
    groups = {not_in_creative_inventory=1}
})

fdir_table = {
   { 0, 1 }, --		[0] X,Z delta +Z
   { 1, 0 }, --		[1] X,Z delta +X
   { 0, -1 }, --	[2] X,Z delta -Z
   { -1, 0 } --		[3] X,Z delta -X
}

function space_to_side(pos, placed_node)
   local node = minetest.get_node(pos)
   local fdir = node.param2 % 32
   local pos2 = {x = pos.x + fdir_table[fdir+1][1], y=pos.y, z = pos.z + fdir_table[fdir+1][2]}
   local node2 = minetest.get_node(pos2)
   local node2def = minetest.registered_nodes[node2.name] or nil
   if not node2def.buildable_to then
      return false
   else
      local placed_node = placed_node or 'zeca_bricks:second_node'
      minetest.set_node(pos2,{name = placed_node, param2=fdir})
      return true
   end
end

function remove_side_node(pos, oldnode)
   local fdir = oldnode.param2 % 32
   local pos2 = {x = pos.x + fdir_table[fdir+1][1], y=pos.y, z = pos.z + fdir_table[fdir+1][2]}
   --local node2 = minetest.get_node(pos2).name 
   --if minetest.get_item_group(node2, 'zeca_bricks:second_node') > 0 then
   minetest.remove_node(pos2)
   --end
   --minetest.swap_node(pos2,"air")
   
end

function make_node_def(name, model, tiles, selbox, colbox, not_in_creative_inventory)
	not_in_creative_inventory = not_in_creative_inventory or 1
	
	return {
		description = name,
		tiles = {
			tiles
		},
		
		drawtype = "mesh",
		
		--use_texture_alpha = true,
		--sunlight_propagates = sunlight,
		--light_source = light_source,
		paramtype = "light", 
		--sunlight_propagates = true,
		--sunlight_propagates = false,		
		paramtype2 = "facedir",
		mesh = model,
		visual_scale = 0.5,
		wield_scale = {x = 0.5, y = 0.5, z = 0.5},
		groups = { snappy = 3 },
		selection_box = selbox,
		collision_box = colbox,
		sounds = node_sound_zeca_bricks_defaults(),
		
		after_place_node = function(pos, placer, itemstack)
			local wield_item = itemstack:get_name()
			if wield_item:find("^zeca_bricks:2x4_") or wield_item:find("^zeca_bricks:1x4_") then
			
				if not space_to_side(pos) then
					minetest.remove_node(pos)
					return itemstack
				end
				
			end
		end,
		
		after_dig_node = function(pos, oldnode, oldmetadata)
			if oldnode.name:find("^zeca_bricks:2x4_") or oldnode.name:find("^zeca_bricks:1x4_") then
			remove_side_node(pos, oldnode)
			end
		end,

	}
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

--register a brick-node for each texture on texture directory
for _, file_name in ipairs(files) do
	
	color_name = string.gsub(file_name, ".png", "")
	color_name_first_cap = firstToUpper(color_name)
	
	minetest.register_node("zeca_bricks:2x2_".. color_name .. "_brick", make_node_def( color_name_first_cap .." Brick 2x2","2x2_brick.obj", file_name, box, box))
	minetest.register_node("zeca_bricks:2x4_".. color_name .. "_brick", make_node_def( color_name_first_cap .." Brick 2x4","2x4_brick.obj", file_name, two_x_four_cbox, two_x_four_cbox))
	minetest.register_node("zeca_bricks:1x2_".. color_name .. "_brick", make_node_def( color_name_first_cap .." Brick 1x2","1x2_brick.obj", file_name, one_x_two_cbox, one_x_two_cbox))
	minetest.register_node("zeca_bricks:2x4_".. color_name .."_slab_brick", make_node_def( color_name_first_cap .." Brick Slab 2x4","2x4_slab_brick.obj", file_name, two_x_four_slab_cbox, two_x_four_slab_cbox))
	minetest.register_node("zeca_bricks:2x2_".. color_name .."_slab_brick", make_node_def( color_name_first_cap .." Brick Slab 2x2","2x2_slab_brick.obj", file_name, two_x_two_slab_cbox, two_x_two_slab_cbox))
	minetest.register_node("zeca_bricks:1x2_".. color_name .."_slab_brick", make_node_def( color_name_first_cap .." Brick Slab 1x2","1x2_slab_brick.obj", file_name, one_x_two_slab_cbox, one_x_two_slab_cbox))
	minetest.register_node("zeca_bricks:1x4_".. color_name .."_slab_brick", make_node_def( color_name_first_cap .." Brick Slab 1x4","1x4_slab_brick.obj", file_name, one_x_four_slab_cbox, one_x_four_slab_cbox))

end
