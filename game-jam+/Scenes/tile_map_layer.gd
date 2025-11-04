extends TileMapLayer

const TILEMAP_COLLISION = preload("uid://dqok14p4olqdi")

enum materials {
	earth,
	sand,
	stone,
	brick,
	cobblestone,
	wood,
	planks,
	leaves,
	glass
}

const atlasmaterials = {
	materials.earth: [Vector2(0,0),Vector2(1,0),Vector2(2,0),Vector2(3,0),Vector2(4,0),Vector2(5,0),
	Vector2(0,1),Vector2(1,1),Vector2(2,1),Vector2(3,1),Vector2(4,1),Vector2(5,1)],
	materials.sand: [Vector2(0,2),Vector2(1,2),Vector2(2,2),Vector2(3,2),Vector2(4,2),Vector2(5,2),
	Vector2(0,3),Vector2(1,3),Vector2(2,3),Vector2(3,3),Vector2(4,3),Vector2(5,3)],
	materials.stone: [Vector2(0,4),Vector2(1,4),Vector2(2,4),Vector2(3,4),Vector2(4,4),Vector2(5,4),
	Vector2(0,5),Vector2(1,5),Vector2(2,5),Vector2(3,5),Vector2(4,5)],
	materials.brick: [Vector2(0,6),Vector2(1,6),Vector2(2,6),Vector2(3,6),Vector2(4,6),
	Vector2(0,7),Vector2(1,7),Vector2(2,7),Vector2(3,7),Vector2(4,7),Vector2(5,7)],
	materials.cobblestone:[Vector2(0,8),Vector2(1,8),Vector2(2,8),Vector2(3,8),Vector2(4,8),Vector2(5,8),
	Vector2(2,9),Vector2(3,9),Vector2(4,9),Vector2(5,9)],
	materials.wood: [Vector2(0,9)],
	materials.leaves: [Vector2(1,9)],
	materials.planks: [Vector2(6,1),Vector2(7,1),Vector2(8,1),Vector2(9,1),
	Vector2(6,2),Vector2(7,2),Vector2(8,2),Vector2(9,2),Vector2(6,3),Vector2(7,3),Vector2(6,4)],
	materials.glass: [Vector2(5,5), Vector2(5,6)]
}

const materialcolor = {
	materials.earth: Color.SADDLE_BROWN,
	materials.sand: Color.BURLYWOOD,
	materials.stone: Color.GRAY,
	materials.brick: Color.BROWN,
	materials.cobblestone: Color.DARK_GRAY,
	materials.wood: Color.SADDLE_BROWN,
	materials.leaves: Color.WEB_GREEN,
	materials.planks: Color.SANDY_BROWN,
	materials.glass: Color.WHITE
}

const materialhps = {
	materials.earth: 3,
	materials.sand: 2,
	materials.stone: 4,
	materials.brick: 6,
	materials.cobblestone: 4,
	materials.wood: 3,
	materials.leaves: 0,
	materials.planks: 3,
	materials.glass: 0
}

var mapdamage = {}
var tiletomapcoll = {}

func damage(glob,dmgvalue = 1):
	Global.spawndestruction(self,glob, globaltocolor(glob))
	var remainingdmg = dmgvalue
	var coord = globtomap(glob)
	if not mapdamage.has(coord): setcoordhp(coord)
	remainingdmg -= mapdamage[coord]
	mapdamage[coord] -= dmgvalue
	tiletomapcoll[coord].setdamage(1-(mapdamage[coord]/float(materialhps[coordtomaterial(coord)])))
	var ignore = null
	if mapdamage[coord] <= 0:
		set_cell(coord)
		ignore = tiletomapcoll[coord]
		tiletomapcoll[coord].queue_free()
		tiletomapcoll.erase(coord)
		mapdamage.erase(coord)
	return [max(0,remainingdmg),ignore]

func setcoordhp(coord):
	if mapdamage.has(coord):
		return
	mapdamage.set(coord,materialhps[coordtomaterial(coord)])

func coordtomaterial(mapcoord):
	var atlascoord = Vector2(get_cell_atlas_coords(mapcoord))
	for i in atlasmaterials.keys():
		if atlasmaterials[i].has(atlascoord):
			return i
	print("atlascoord undefined!: "+str(atlascoord))
	return null

func globtomap(glob):
	return local_to_map(to_local(glob))

func globaltocolor(glob):
	return materialcolor[coordtomaterial(globtomap(glob))]

func _ready() -> void:
	for tile in get_used_cells():
		var a = TILEMAP_COLLISION.instantiate()
		add_child(a)
		a.position = map_to_local(tile)
		tiletomapcoll.set(tile,a)
