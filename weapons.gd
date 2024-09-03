class_name Weapons extends Resource

@export var name : StringName
@export_group("Weapon Location")
@export var position : Vector3
@export var rotation : Vector3
@export_group("Mesh Settings")
@export var mesh : Mesh
@export var shadow : bool

@export_group("Weapon Stats")
@export_enum("Light Melee", "Heavy Melee", "Gun") var weapon_Type : int 
@export var damage_Amount : int
@export var character_Move_Speed: float
@export var recovery_Speed: float
