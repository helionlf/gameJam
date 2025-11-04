extends Node
const RICOCHETE = preload("res://ricochete.tscn")
var mundo = null
const STARTSTUCK = preload("res://startstuck.tscn")
const DESTRUCTION_PARTICLE = preload("uid://2tyhp4qw48x5")

var quemganhou = 0

func spawnricochete(impactpos, weaponpos):
	var a = RICOCHETE.instantiate()
	mundo.add_child(a)
	var dir = -sign(weaponpos.x-impactpos.x)
	a.global_position = impactpos
	a.direcao = dir
	a.scale.x = dir
	a.trace(impactpos-weaponpos)

func spawnestrelas(cato):
	var a = STARTSTUCK.instantiate()
	cato.add_child(a)
	a.position = Vector2(0,-40)

func spawndestruction(tile,glob):
	var a = DESTRUCTION_PARTICLE.instantiate()
	tile.add_child(a)
	a.global_position = glob
