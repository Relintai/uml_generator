extends PanelContainer

func set_class_name(n):
	$VBoxContainer/HBoxContainer/ClassName.text = n


func add_h_separator():
	var hsep : HSeparator = HSeparator.new()
	$VBoxContainer.add_child(hsep)

func add_line(line : String):
	var l : Label = Label.new()
	l.text = line
	$VBoxContainer.add_child(l)
