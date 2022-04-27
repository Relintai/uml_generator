extends Control

var BaseClassControl = preload("res://BaseClassControl.tscn")
var ClassControl = preload("res://ClassControl.tscn")

export(NodePath) var content_container_path : NodePath

enum States {
	STATE_NEXT = 0,
	STATE_RESIZE_WINDOW,
	STATE_TAKE_SCREENSHOT
};

enum AccessModifierState {
	ACCESS_MODIFIER_PRIVATE = 0,
	ACCESS_MODIFIER_PROTECTED,
	ACCESS_MODIFIER_PUBLIC
};

var _content_container : Control
var _files : PoolStringArray
var _error_files : PoolStringArray
var _current_index : int = 0
var _current_state = 0

func _ready():
	var dir : Directory = Directory.new()
	
	if !dir.dir_exists("res://data/"):
		print("Error: Directory res://data/ Does not exists!")
		return
	
	if !dir.dir_exists("res://output/"):
		print("Error: Directory res://output/ exists!")
		return
		
	dir.make_dir("res://output/")
	
	if dir.open("res://data/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				_files.push_back(file_name)
			
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access res://data/.")
		
	_content_container = get_node(content_container_path)

func _process(delta):
	if _current_state == States.STATE_NEXT:
		_process_state_next(delta)
	elif _current_state == States.STATE_RESIZE_WINDOW:
		_process_state_resize_window(delta)
	elif _current_state == States.STATE_TAKE_SCREENSHOT:
		_process_state_take_screenshot(delta)

func _process_state_next(delta):
	if _current_index == _files.size():
		print("Done!")
		
		if _error_files.size() > 0:
			print("Errors happened in files:")
			print(_error_files)
		else:
			print("Generatin successful!")
		
		get_tree().quit()
		return
		
	var fn : String = "res://data/" + _files[_current_index]
	
	var file : File = File.new()
	file.open(fn, File.READ)
	var content : String = file.get_as_text()
	file.close()
	
	clear_content()
	
	content = content.replace("\r\n", "\n")
	var lines : Array = content.split("\n")
	
	var current_content_container : VBoxContainer = VBoxContainer.new()
	current_content_container.set("custom_constants/separation", 0)
	_content_container.add_child(current_content_container)
	var in_class : bool = false
	var current_class_access_modifier : int = AccessModifierState.ACCESS_MODIFIER_PRIVATE
	var class_control : Control = null
	
	for i in range(lines.size()):
		var l : String = lines[i]
		l = l.strip_edges()
		
		if l == "":
			continue
			
		if l[0] == "#":
			continue
			
		if l.begins_with("new_column"):
			current_content_container = VBoxContainer.new()
			current_content_container.set("custom_constants/separation", 0)
			_content_container.add_child(current_content_container)
			continue
			
		if l.begins_with("base_class "):
			var base_class : String = l.trim_prefix("base_class ")
			
			var bcc = BaseClassControl.instance()
			bcc.set_base_class_name(base_class)
			
			current_content_container.add_child(bcc)
			continue
			
		if l.begins_with("class "):
			in_class = true
			current_class_access_modifier = AccessModifierState.ACCESS_MODIFIER_PRIVATE
			class_control = ClassControl.instance()
			class_control.set_class_name(l.trim_prefix("class "))
			current_content_container.add_child(class_control)
			continue
			
		if l.begins_with("struct "):
			in_class = true
			current_class_access_modifier = AccessModifierState.ACCESS_MODIFIER_PUBLIC
			class_control = ClassControl.instance()
			class_control.set_class_name(l.trim_prefix("struct "))
			current_content_container.add_child(class_control)
			continue
			
		if l.begins_with("public:"):
			current_class_access_modifier = AccessModifierState.ACCESS_MODIFIER_PUBLIC
			continue
			
		if l.begins_with("protected:"):
			current_class_access_modifier = AccessModifierState.ACCESS_MODIFIER_PROTECTED
			continue
			
		if l.begins_with("private:"):
			current_class_access_modifier = AccessModifierState.ACCESS_MODIFIER_PRIVATE
			continue
		
		if l.begins_with("--"):
			class_control.add_h_separator()
			continue
		
		# At this point everything should'have been handled except methods and variables
		
		l = l.replace(";", "")
		
		if current_class_access_modifier == AccessModifierState.ACCESS_MODIFIER_PUBLIC:
			l = "+ " + l
		elif current_class_access_modifier == AccessModifierState.ACCESS_MODIFIER_PROTECTED:
			l = "# " + l
		elif current_class_access_modifier == AccessModifierState.ACCESS_MODIFIER_PRIVATE:
			l = "- " + l
		
		class_control.add_line(l)
	
	_current_state = States.STATE_RESIZE_WINDOW

func _process_state_resize_window(delta):
	pass
	#_current_state = States.STATE_TAKE_SCREENSHOT
	
	
func _process_state_take_screenshot(delta):
	
	_current_index += 1
	_current_state = States.STATE_NEXT

func clear_content():
	for c in _content_container.get_children():
		c.queue_free()
		_content_container.remove_child(c)
