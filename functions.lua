--
-- Sounds
--

function node_sound_zeca_bricks_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "bricks_place_node", gain = 0.25}
	table.dig = table.dig or
			{name = "bricks_place_node", gain = 0.35}
	table.dug = table.dug or
			{name = "bricks_dug", gain = 1.0}
	table.place = table.place or
			{name = "bricks_place_node", gain = 1.0}

	return table
end
