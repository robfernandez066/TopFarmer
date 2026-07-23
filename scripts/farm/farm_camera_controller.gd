class_name FarmCameraController
extends Camera2D

signal plot_gesture_cancel_requested
signal plot_input_suppression_changed(suppressed: bool)
signal plot_pointer_event(event: InputEvent)

const FARM_RECT := Rect2(0.0, 0.0, 540.0, 960.0)
const DEFAULT_CAMERA_POSITION := Vector2(270.0, 480.0)
const MIN_ZOOM := 1.0
const MAX_ZOOM := 2.0
const PAN_THRESHOLD := 12.0
const MOUSE_ZOOM_STEP := 0.1
const CONFIRMED_TAP_META := &"farm_plot_confirmed_tap"
const NO_TOUCH := -1

var _touch_positions: Dictionary = {}
var _primary_touch_id := NO_TOUCH
var _primary_start_position := Vector2.ZERO
var _primary_last_position := Vector2.ZERO
var _pinch_touch_ids: Array[int] = []
var _pinch_start_distance := 0.0
var _pinch_start_zoom := MIN_ZOOM
var _pinch_anchor_world := DEFAULT_CAMERA_POSITION
var _camera_touch_gesture_active := false
var _middle_drag_active := false
var _middle_drag_crossed_threshold := false
var _middle_drag_start_position := Vector2.ZERO
var _middle_drag_last_position := Vector2.ZERO
var _left_mouse_active := false
var _left_mouse_start_position := Vector2.ZERO
var _left_mouse_disqualified := false


func _ready() -> void:
	position = DEFAULT_CAMERA_POSITION
	zoom = Vector2.ONE * MIN_ZOOM
	rotation = 0.0
	enabled = true
	visibility_changed.connect(_on_visibility_changed)
	_clamp_camera_position()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_touch_drag(event as InputEventScreenDrag)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event as InputEventMouseMotion)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		plot_gesture_cancel_requested.emit()
		_clear_input_state()


func _exit_tree() -> void:
	plot_gesture_cancel_requested.emit()
	_clear_input_state()


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.canceled:
		plot_gesture_cancel_requested.emit()
		_clear_touch_state()
		_mark_input_handled()
		return
	if event.pressed:
		_handle_touch_pressed(event.index, event.position)
	else:
		_handle_touch_released(event)


func _handle_touch_pressed(touch_id: int, screen_position: Vector2) -> void:
	if _primary_touch_id == NO_TOUCH:
		_primary_touch_id = touch_id
		_primary_start_position = screen_position
		_primary_last_position = screen_position
		_touch_positions[touch_id] = screen_position
		return
	if _pinch_touch_ids.is_empty():
		_touch_positions[touch_id] = screen_position
		_pinch_touch_ids = [_primary_touch_id, touch_id]
		_begin_camera_touch_gesture()
		_begin_pinch()
		_mark_input_handled()
		return

	# A later finger never replaces or alters the active pinch pair. It may have
	# reached a plot picker first, so request cancellation again for that press.
	_touch_positions[touch_id] = screen_position
	plot_gesture_cancel_requested.emit()
	_mark_input_handled()


func _handle_touch_released(event: InputEventScreenTouch) -> void:
	var touch_id := event.index
	if not _touch_positions.has(touch_id):
		if _camera_touch_gesture_active:
			_mark_input_handled()
		return
	if touch_id == _primary_touch_id and _pinch_touch_ids.is_empty() and not _camera_touch_gesture_active:
		if event.position.distance_to(_primary_start_position) > PAN_THRESHOLD:
			_begin_camera_touch_gesture()
	_touch_positions.erase(touch_id)
	if _pinch_touch_ids.has(touch_id):
		var remaining_touch_id := NO_TOUCH
		for pair_touch_id in _pinch_touch_ids:
			if pair_touch_id != touch_id and _touch_positions.has(pair_touch_id):
				remaining_touch_id = pair_touch_id
		_pinch_touch_ids.clear()
		if remaining_touch_id != NO_TOUCH:
			_primary_touch_id = remaining_touch_id
			_primary_start_position = _touch_positions[remaining_touch_id]
			_primary_last_position = _primary_start_position
		else:
			_clear_touch_state()
		_mark_input_handled()
		return
	if touch_id == _primary_touch_id:
		var was_camera_gesture := _camera_touch_gesture_active
		if was_camera_gesture and not _touch_positions.is_empty():
			_primary_touch_id = int(_touch_positions.keys()[0])
			_primary_start_position = _touch_positions[_primary_touch_id]
			_primary_last_position = _primary_start_position
			_mark_input_handled()
			return
		_clear_touch_state()
		if was_camera_gesture:
			_mark_input_handled()
		else:
			_route_confirmed_tap_to_plot(event, event.position)
	elif _camera_touch_gesture_active:
		_mark_input_handled()


func _handle_touch_drag(event: InputEventScreenDrag) -> void:
	if not _touch_positions.has(event.index):
		return
	_touch_positions[event.index] = event.position
	if not _pinch_touch_ids.is_empty():
		_update_pinch()
		_mark_input_handled()
		return
	if event.index != _primary_touch_id:
		if _camera_touch_gesture_active:
			_mark_input_handled()
		return

	var crossed_threshold := event.position.distance_to(_primary_start_position) > PAN_THRESHOLD
	if crossed_threshold:
		_begin_camera_touch_gesture()
		if zoom.x > MIN_ZOOM:
			var screen_delta := event.position - _primary_last_position
			position -= screen_delta / zoom.x
			_clamp_camera_position()
		_mark_input_handled()
	_primary_last_position = event.position


func _begin_camera_touch_gesture() -> void:
	if _camera_touch_gesture_active:
		return
	_camera_touch_gesture_active = true
	plot_input_suppression_changed.emit(true)
	plot_gesture_cancel_requested.emit()


func _begin_pinch() -> void:
	if _pinch_touch_ids.size() != 2:
		return
	var first_position: Vector2 = _touch_positions[_pinch_touch_ids[0]]
	var second_position: Vector2 = _touch_positions[_pinch_touch_ids[1]]
	_pinch_start_distance = first_position.distance_to(second_position)
	_pinch_start_zoom = zoom.x
	_pinch_anchor_world = _screen_to_world((first_position + second_position) * 0.5)


func _update_pinch() -> void:
	if _pinch_touch_ids.size() != 2:
		return
	var first_touch_id := _pinch_touch_ids[0]
	var second_touch_id := _pinch_touch_ids[1]
	if not _touch_positions.has(first_touch_id) or not _touch_positions.has(second_touch_id):
		return
	var first_position: Vector2 = _touch_positions[first_touch_id]
	var second_position: Vector2 = _touch_positions[second_touch_id]
	var midpoint := (first_position + second_position) * 0.5
	var separation := first_position.distance_to(second_position)
	var requested_zoom := _pinch_start_zoom
	if _pinch_start_distance > 0.0:
		requested_zoom *= separation / _pinch_start_distance
	_apply_zoom_with_anchor(requested_zoom, midpoint, _pinch_anchor_world)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _left_mouse_active:
				plot_gesture_cancel_requested.emit()
			_left_mouse_active = true
			_left_mouse_start_position = event.position
			_left_mouse_disqualified = false
		elif _left_mouse_active:
			var release_disqualified := _left_mouse_disqualified or event.position.distance_to(_left_mouse_start_position) > PAN_THRESHOLD
			_left_mouse_active = false
			_left_mouse_start_position = Vector2.ZERO
			_left_mouse_disqualified = false
			if release_disqualified:
				plot_gesture_cancel_requested.emit()
				_mark_input_handled()
			else:
				_route_confirmed_tap_to_plot(event, event.position)
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		plot_gesture_cancel_requested.emit()
		_apply_zoom_at_screen_point(zoom.x + MOUSE_ZOOM_STEP, event.position)
		_mark_input_handled()
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		plot_gesture_cancel_requested.emit()
		_apply_zoom_at_screen_point(zoom.x - MOUSE_ZOOM_STEP, event.position)
		_mark_input_handled()
	elif event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			plot_gesture_cancel_requested.emit()
			_middle_drag_active = true
			_middle_drag_crossed_threshold = false
			_middle_drag_start_position = event.position
			_middle_drag_last_position = event.position
		else:
			_middle_drag_active = false
			_middle_drag_crossed_threshold = false
		_mark_input_handled()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _left_mouse_active:
		if event.position.distance_to(_left_mouse_start_position) > PAN_THRESHOLD and not _left_mouse_disqualified:
			_left_mouse_disqualified = true
			plot_gesture_cancel_requested.emit()
		_mark_input_handled()
		return
	if not _middle_drag_active:
		return
	if event.position.distance_to(_middle_drag_start_position) > PAN_THRESHOLD:
		_middle_drag_crossed_threshold = true
	if _middle_drag_crossed_threshold and zoom.x > MIN_ZOOM:
		var screen_delta := event.position - _middle_drag_last_position
		position -= screen_delta / zoom.x
		_clamp_camera_position()
	_middle_drag_last_position = event.position
	_mark_input_handled()


func _apply_zoom_at_screen_point(requested_zoom: float, screen_point: Vector2) -> void:
	var anchor_world := _screen_to_world(screen_point)
	_apply_zoom_with_anchor(requested_zoom, screen_point, anchor_world)


func _apply_zoom_with_anchor(requested_zoom: float, screen_point: Vector2, anchor_world: Vector2) -> void:
	var clamped_zoom := clampf(requested_zoom, MIN_ZOOM, MAX_ZOOM)
	zoom = Vector2.ONE * clamped_zoom
	position = anchor_world - (screen_point - _get_camera_viewport_size() * 0.5) / clamped_zoom
	_clamp_camera_position()


func _screen_to_world(screen_point: Vector2) -> Vector2:
	return position + (screen_point - _get_camera_viewport_size() * 0.5) / zoom.x


func _clamp_camera_position() -> void:
	var half_visible_world := _get_camera_viewport_size() * 0.5 / zoom.x
	position.x = _clamped_axis(
		position.x,
		FARM_RECT.position.x + half_visible_world.x,
		FARM_RECT.end.x - half_visible_world.x,
		FARM_RECT.get_center().x
	)
	position.y = _clamped_axis(
		position.y,
		FARM_RECT.position.y + half_visible_world.y,
		FARM_RECT.end.y - half_visible_world.y,
		FARM_RECT.get_center().y
	)


func _clamped_axis(value: float, minimum: float, maximum: float, centered_value: float) -> float:
	if minimum > maximum:
		return centered_value
	return clampf(value, minimum, maximum)


func _get_camera_viewport_size() -> Vector2:
	return get_viewport_rect().size


func _clear_input_state() -> void:
	_clear_touch_state()
	_left_mouse_active = false
	_left_mouse_start_position = Vector2.ZERO
	_left_mouse_disqualified = false
	_middle_drag_active = false
	_middle_drag_crossed_threshold = false
	_middle_drag_start_position = Vector2.ZERO
	_middle_drag_last_position = Vector2.ZERO


func _clear_touch_state() -> void:
	var was_camera_touch_gesture_active := _camera_touch_gesture_active
	_touch_positions.clear()
	_primary_touch_id = NO_TOUCH
	_primary_start_position = Vector2.ZERO
	_primary_last_position = Vector2.ZERO
	_pinch_touch_ids.clear()
	_pinch_start_distance = 0.0
	_pinch_start_zoom = zoom.x
	_pinch_anchor_world = position
	_camera_touch_gesture_active = false
	if was_camera_touch_gesture_active:
		plot_input_suppression_changed.emit(false)


func _mark_input_handled() -> void:
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()


func _route_confirmed_tap_to_plot(event: InputEvent, screen_position: Vector2) -> void:
	var plot_event := event.duplicate() as InputEvent
	if plot_event is InputEventScreenTouch:
		(plot_event as InputEventScreenTouch).position = _screen_to_world(screen_position)
	elif plot_event is InputEventScreenDrag:
		(plot_event as InputEventScreenDrag).position = _screen_to_world(screen_position)
	elif plot_event is InputEventMouseButton:
		(plot_event as InputEventMouseButton).position = _screen_to_world(screen_position)
	elif plot_event is InputEventMouseMotion:
		(plot_event as InputEventMouseMotion).position = _screen_to_world(screen_position)
	plot_event.set_meta(CONFIRMED_TAP_META, true)
	plot_pointer_event.emit(plot_event)
	_mark_input_handled()


func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		plot_gesture_cancel_requested.emit()
		_clear_input_state()
