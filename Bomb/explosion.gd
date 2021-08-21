extends Spatial

##TODO NEED TO DELAY ENABLING HITRAYS FOR A FEW FRAMES SO RADIUS CAN CALCULATE
#OR DYING THROUGH WALLS IF STANDING THERE ON EXPLOSION TIME
var exploded = false

var bomb_size = 0.5
var unit_size = 3

var bomb_time = 2
var explosion_time = 1

onready var raycastXPlus = $"explosionRays/RayCastXPlus"
onready var raycastXNeg = $"explosionRays/RayCastXNeg"
onready var raycastZPlus = $"explosionRays/RayCastZPlus"
onready var raycastZNeg = $"explosionRays/RayCastZNeg"
onready var LineXPlus = $"LineXPlus"
onready var LineXNeg = $"LineXNeg"
onready var LineZPlus = $"LineZPlus"
onready var LineZNeg = $"LineZNeg"
onready var LineZPlusEnd = $"LineZPlusEnd"
onready var LineZNegEnd = $"LineZNegEnd"
onready var LineXPlusEnd = $"LineXPlusEnd"
onready var LineXNegEnd = $"LineXNegEnd"

var team_color = Color(0.847059,0.313726,0.313726,1)
var emission_color = team_color
var scaled = false
var player = null

var areaScaled = {
	"xPlus": false,
	"xNeg": false,
	"zPlus": false,
	"zNeg": false,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	bomb_size = player.bomb_size
	set_materials()
	$"bombTimer".wait_time = bomb_time
	$"bombTimer".start()

func set_materials():
	LineXPlus.material_override.set_albedo(team_color)
	LineXNeg.material_override.set_albedo(team_color)
	LineZPlus.material_override.set_albedo(team_color)
	LineZNeg.material_override.set_albedo(team_color)
	
	LineXPlus.material_override.set_emission(emission_color)
	LineXNeg.material_override.set_emission(emission_color)
	LineZPlus.material_override.set_emission(emission_color)
	LineZNeg.material_override.set_emission(emission_color)
	
	var material = LineXPlus.get_material_override()
	
	LineXPlus.material_override.set_feature(material.FEATURE_EMISSION, true)
	LineXNeg.material_override.set_feature(material.FEATURE_EMISSION, true)
	LineZPlus.material_override.set_feature(material.FEATURE_EMISSION, true)
	LineZNeg.material_override.set_feature(material.FEATURE_EMISSION, true)
	
	LineXPlus.material_override.set_emission_energy(1.2)
	LineXNeg.material_override.set_emission_energy(1.2)
	LineZPlus.material_override.set_emission_energy(1.2)
	LineZNeg.material_override.set_emission_energy(1.2)

func explode():
	if exploded == true:
		return
	exploded = true
	player.bombRespawn()
	#print(LineXPlus.material_override.albedo_color)
	$"bombTimer".stop()
	$"Bomb".remove_child($"Bomb/bomb")
	$"explosionTimer".wait_time = explosion_time
	$"explosionTimer".start()
	LineXPlus.visible = true
	LineXNeg.visible = true
	LineZPlus.visible = true
	LineZNeg.visible = true
	#LineXPlusEnd.global_transform.origin = player.global_transform.origin
	LineXPlusEnd.global_transform.origin.x = LineXPlusEnd.global_transform.origin.x + (bomb_size * unit_size)
	var line_dist = LineXPlusEnd.global_transform.origin.x - global_transform.origin.x
	
	#$"Hitboxes/XPlus".global_transform.origin.x = global_transform.origin.x + (line_dist / 4)
	#line_dist = line_dist * 5
	raycastXPlus.set_cast_to(Vector3(line_dist, -1, 0))
	raycastXPlus.enabled = true
	#raycastXPlus.set_collision_mask_bit(3, true)
	#raycastXPlus.set_collision_mask_bit(4, true)
	raycastXPlus.set_collision_mask_bit(0, true)
	$"hitRays/RayCastXP".set_cast_to(raycastXPlus.get_cast_to())
	$"hitRays/RayCastXP".enabled = true
	$"hitRays/RayCastXP".set_collision_mask_bit(3, true)
	$"hitRays/RayCastXP".set_collision_mask_bit(4, true)
	
	LineXNegEnd.global_transform.origin.x = LineXNegEnd.global_transform.origin.x - (bomb_size * unit_size)
	line_dist = LineXNegEnd.global_transform.origin.x - global_transform.origin.x
	raycastXNeg.set_cast_to(Vector3(line_dist, -1, 0))
	raycastXNeg.enabled = true
	$"hitRays/RayCastXN".set_cast_to(raycastXNeg.get_cast_to())
	$"hitRays/RayCastXN".enabled = true
	$"hitRays/RayCastXN".set_collision_mask_bit(3, true)
	$"hitRays/RayCastXN".set_collision_mask_bit(4, true)
	
	LineZPlusEnd.global_transform.origin.z = LineZPlusEnd.global_transform.origin.z + (bomb_size * unit_size)
	line_dist = LineZPlusEnd.global_transform.origin.z - global_transform.origin.z
	raycastZPlus.set_cast_to(Vector3(0, -1, line_dist))
	raycastZPlus.enabled = true
	$"hitRays/RayCastZP".set_cast_to(raycastZPlus.get_cast_to())
	$"hitRays/RayCastZP".enabled = true
	$"hitRays/RayCastZP".set_collision_mask_bit(3, true)
	$"hitRays/RayCastZP".set_collision_mask_bit(4, true)
	
	LineZNegEnd.global_transform.origin.z = LineZNegEnd.global_transform.origin.z - (bomb_size * unit_size)
	line_dist = LineZNegEnd.global_transform.origin.z - global_transform.origin.z
	raycastZNeg.set_cast_to(Vector3(0, -1, line_dist))
	raycastZNeg.enabled = true
	$"hitRays/RayCastZN".set_cast_to(Vector3(0, -1, line_dist))
	$"hitRays/RayCastZN".enabled = true
	$"hitRays/RayCastZN".set_collision_mask_bit(3, true)
	$"hitRays/RayCastZN".set_collision_mask_bit(4, true)

func check_hitting_players():
	var hitRays = $"hitRays".get_children()
	for hitRay in hitRays:
		if hitRay.is_colliding():
			var body = hitRay.get_collider()
			print(body.get_name())
			if body != null && body.is_in_group("Player") && body.dead != true:
				body.killed(player.player_id)
			if body != null && body.is_in_group("Bomb"):
				var parent = body.get_parent()
				if parent != null:
					parent.get_parent().explode()
			if body != null && body.is_in_group("Crate"):
				var parent = body.get_parent()
				if parent != null:
					parent.get_parent().explode()
	
func _physics_process(delta):
	#ON RAY HIT CHANGE HITRAY TO SAME SIZE AS END POINT!!
	check_hitting_players()
	if exploded:
		var bodies = $"Area".get_overlapping_bodies()
		for body in bodies:
			if body != null && body.is_in_group("Player") && body.dead != true:
				body.killed(player.player_id)
		#$"Area"
	if raycastXPlus.is_colliding() && scaled == false:
		print(raycastXPlus.get_collider().name)
		print("collided")
		LineXPlusEnd.global_transform.origin = raycastXPlus.get_collision_point()
		var line_dist = LineXPlusEnd.global_transform.origin.x - global_transform.origin.x
		raycastXPlus.set_cast_to(Vector3(line_dist, -1, 0))
		$"hitRays/RayCastXP".set_cast_to(raycastXPlus.get_cast_to())
	else:
		pass
	if raycastXNeg.is_colliding() && scaled == false:
		LineXNegEnd.global_transform.origin = raycastXNeg.get_collision_point()
		var line_dist = LineXNegEnd.global_transform.origin.x - global_transform.origin.x
		raycastXNeg.set_cast_to(Vector3(line_dist, -1, 0))
		$"hitRays/RayCastXN".set_cast_to(raycastXNeg.get_cast_to())
		scaled = false
	else:
		pass
	if raycastZPlus.is_colliding() && scaled == false:
		LineZPlusEnd.global_transform.origin = raycastZPlus.get_collision_point()
		var line_dist = LineZPlusEnd.global_transform.origin.z - global_transform.origin.z
		raycastZPlus.set_cast_to(Vector3(0, -1, line_dist))
		$"hitRays/RayCastZP".set_cast_to(raycastZPlus.get_cast_to())
		scaled = false
	else:
		pass
	if raycastZNeg.is_colliding() && scaled == false:
		#print(raycastXPlus.get_collider().name)
		LineZNegEnd.global_transform.origin = raycastZNeg.get_collision_point()
		var line_dist = LineZNegEnd.global_transform.origin.z - global_transform.origin.z
		raycastZNeg.set_cast_to(Vector3(0, -1, line_dist))
		$"hitRays/RayCastZN".set_cast_to(raycastZNeg.get_cast_to())
		scaled = false
	else:
		pass


func _on_explosionTimer_timeout():
	queue_free()


func _on_bombTimer_timeout():
	explode()
