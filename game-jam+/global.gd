extends Node
const RICOCHETE = preload("res://ricochete.tscn")
var mundo = null

func spawnricochete(impactpos, weaponpos):
	var a = RICOCHETE.instantiate()
	mundo.add_child(a)
	var dir = -sign(weaponpos.x-impactpos.x)
	a.global_position = impactpos
	a.direcao = dir
	a.scale.x = dir
	a.trace(impactpos.x-weaponpos.x)
