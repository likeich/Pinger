extends HBoxContainer
class_name IPItem

func _ready():
	$Label.text = str(get_position_in_parent() + 1) + ". IP:"

func get_ip() -> String:
	return $LineEdit.text

func get_count() -> int:
	return $SpinBox.value
