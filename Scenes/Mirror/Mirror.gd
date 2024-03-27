extends Node3D

const whitegreen : Color = Color(0.9, 0.97, 0.94)

@export var size : Vector2 = Vector2(2, 2)
@export var resolution_per_unit := 100
@export var cullMask : Array[int] = []
@export_color_no_alpha var MirrorColor : Color = whitegreen

@onready var cam := $SubViewport/Camera3D
@onready var viewport := $SubViewport
@onready var mirror := $MeshInstance3D

var main_cam : Camera3D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	main_cam = get_tree().get_first_node_in_group("MainCam")
	
	cam.cull_mask = 0xFF
	for i in cullMask:
		cam.set_cull_mask_value(i, false)
		
	mirror.mesh.size = size
	viewport.size = size * resolution_per_unit
	mirror.get_active_material(0).set_shader_parameter("tint", MirrorColor)
	mirror.get_active_material(0).set_shader_parameter("mirror_tex", viewport.get_texture())
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var mirror_normal = mirror.global_transform.basis.z	
	var mirror_transform =  get_mirror_transfrom(mirror_normal, mirror.global_transform.origin)
	cam.global_transform = mirror_transform * main_cam.global_transform
	
	# Look perpendicular into the mirror plane for frustum camera
	var cam_projection = (cam.global_transform.origin + main_cam.global_transform.origin) / 2
	cam.global_transform = cam.global_transform.looking_at(cam_projection, mirror.global_transform.basis.y)
	var cam2mirror_offset = mirror.global_transform.origin - cam.global_transform.origin
	var near = abs((cam2mirror_offset).dot(mirror_normal)) # near plane distance
	near += 0.05 # avoid rendering own surface

	# transform offset to camera's local coordinate system (frustum offset uses local space)
	var cam2mirror_camlocal = cam.global_transform.basis.inverse() * cam2mirror_offset
	var frustum_offset =  Vector2(cam2mirror_camlocal.x, cam2mirror_camlocal.y)
	cam.set_frustum(mirror.mesh.size.x, frustum_offset, near, 10000)


func get_mirror_transfrom(plane_normal : Vector3, plane_origin : Vector3) -> Transform3D:
	var basisX : Vector3 = Vector3(1.0, 0, 0) - 2 * Vector3(plane_normal.x * plane_normal.x, plane_normal.x * plane_normal.y, plane_normal.x * plane_normal.z)
	var basisY : Vector3 = Vector3(0, 1.0, 0) - 2 * Vector3(plane_normal.y * plane_normal.x, plane_normal.y * plane_normal.y, plane_normal.y * plane_normal.z)
	var basisZ : Vector3 = Vector3(0, 0, 1.0) - 2 * Vector3(plane_normal.z * plane_normal.x, plane_normal.z * plane_normal.y, plane_normal.z * plane_normal.z)
	
	var offset = Vector3.ZERO
	offset = 2 * plane_normal.dot(plane_origin)*plane_normal
	
	return Transform3D(Basis(basisX, basisY, basisZ), offset)
