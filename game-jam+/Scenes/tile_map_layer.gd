extends TileMapLayer

func destroy(glob):
	Global.spawndestruction(self,glob)
	set_cell(local_to_map(to_local(glob)))
