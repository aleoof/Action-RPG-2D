extends KinematicBody2D

export var FRICTION = 500
export var ACELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var result = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/SwordHitbox

func _ready():
	animationTree.active = true
	sword_hitbox.knockback_vector =  roll_vector

func _physics_process(delta):
	match state: 
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		ROLL:
			roll_state(delta)
	
	

func move_state(delta):
	result.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	result.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	result = result.normalized()
	
	if result != Vector2.ZERO:
		roll_vector = result
		sword_hitbox.knockback_vector = result
		animationTree.set("parameters/Idle/blend_position", result)
		animationTree.set("parameters/Run/blend_position", result)
		animationTree.set("parameters/Attack/blend_position", result)
		animationTree.set("parameters/Roll/blend_position", result)
		animationState.travel("Run")
		velocity = velocity.move_toward(result * MAX_SPEED, ACELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("Roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
	
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finish():
	velocity = velocity * 0.8
	state = MOVE
	
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func move():
	velocity = move_and_slide(velocity)
