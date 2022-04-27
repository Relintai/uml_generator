extends PanelContainer

var _item_added : bool = false

func set_class_name(n):
	$VBoxContainer/HBoxContainer/ClassName.text = n


func add_h_separator():
	var hsep : HSeparator = HSeparator.new()
	$VBoxContainer.add_child(hsep)

func add_line(line : String):
	if !_item_added:
		_item_added = true
		add_h_separator()
		add_h_separator()
	
	var l : Label = Label.new()
	l.text = line
	$VBoxContainer.add_child(l)
