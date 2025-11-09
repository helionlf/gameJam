extends Node
const RICOCHETE = preload("res://ricochete.tscn")
var mundo = null
const STARTSTUCK = preload("res://startstuck.tscn")
const DESTRUCTION_PARTICLE = preload("uid://2tyhp4qw48x5")
const SHAPE_CAST_2D = preload("uid://b0m56bueosisd")

var camera

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

func spawndestruction(parent,glob, color = Color.WHITE):
	var a = DESTRUCTION_PARTICLE.instantiate()
	parent.add_child(a)
	a.modulate = color
	a.global_position = glob

func firenull(parent,damage,girth,length,globpos,globrot,player = null):
	var a = SHAPE_CAST_2D.instantiate()
	parent.add_child(a)
	return a.fire(damage,girth,length,globpos,globrot, player)

func fire(parent,damage,girth,length,globpos,globrot,player = null):
	var a = firenull(parent,damage,girth,length,globpos,globrot,player)
	if a: return a
	return globpos+Vector2(length*cos(globrot)/10,length*sin(globrot)/10)

const BOOMCLOUD = preload("uid://du0g1ps8bxm16")

func kaboom(parent, globpos):
	for i in 5:
		var a = BOOMCLOUD.instantiate()
		parent.add_child(a)
		a.global_position = globpos
		a.global_position += Vector2(randf_range(-30,30),randf_range(-30,30))
		spawndestruction(parent,a.global_position,Color.ORANGE)

func impact(n):
	if camera: camera.zoom -= Vector2(n/10.0,n/10.0)
