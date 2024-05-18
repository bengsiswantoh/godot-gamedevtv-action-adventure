extends CharacterBody3D
class_name Character

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_range(0, 20, 0.1) var _speed := 5.0

@export var stats: Array[StatResource]

@export_group("Required Node")
@export var animation_player: AnimationPlayer
@export var state_machine: StateMachine
@export var model: Node3D
@export var hurtbox: Area3D

@export_group("AI Node")
@export var path: Path3D
@export var agent: NavigationAgent3D
@export var chase_area: Area3D
@export var attack_area: Area3D

var facing_angle: float
var rotation_speed: float = 8

func _ready() -> void:
	hurtbox.area_entered.connect(_handle_hurtbox_entered)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	move_and_slide()
	rotate_model(delta)
	
func _handle_hurtbox_entered(area: Area3D) -> void:
	var health: StatResource = get_stat_resource(StatResource.Stat.Health)
	
	var character: Character = area.owner as Character;
	health.stat_value -= character.get_stat_resource(StatResource.Stat.Strength).stat_value
	
	print(health.stat_value)

func rotate_model(delta: float) -> void:
	var is_moving = velocity.x != 0 or velocity.z != 0
		
	if is_moving:
		facing_angle = Vector2(velocity.z, velocity.x).angle()
		model.rotation.y = lerp_angle(model.rotation.y, facing_angle, rotation_speed * delta)
		
func stop_moving(speed: float = _speed) -> void:
	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)
	
func get_stat_resource(stat: int) -> StatResource:
	var result: StatResource
	
	for element in stats:
		if element.stat_type == stat:
			result = element
			break
	
	return result
	
