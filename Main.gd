extends Control

onready var ip_items := find_node("IPItems")
onready var ip_item := preload("res://IPItem.tscn")
onready var output := find_node("Output")
onready var progress: ProgressBar = find_node("ProgressBar")
onready var ping_button: Button = find_node("PingButton")

var threads := []
var finished_threads := 0
var mutex := Mutex.new()

func _process(_delta):
	if finished_threads == threads.size() and threads.size() != 0:
		for thread in threads:
			thread.wait_to_finish()
		
		finished_threads = 0
		threads = []
		progress.value = progress.max_value
		ping_button.disabled = false

func is_mobile() -> bool:
	return OS.get_name() == "Android"

func _on_PingButton_pressed():
	ping_button.disabled = true
	output.text = ""
	progress.value = 0
	for item in ip_items.get_children():
		var new_thread := Thread.new()
		threads.append(new_thread)
		var _error := new_thread.start(self, "ping", item)

func ping(item: IPItem) -> void:
	var returned := []
	if OS.get_name() == "X11":
		var _error := OS.execute("ping", [item.get_ip(), "-c", item.get_count()], true, returned)
	elif OS.get_name() == "Windows":
		var _error := OS.execute("ping", [item.get_ip(), "/n", item.get_count()], true, returned)
	elif OS.get_name() == "Android":
		var _error := OS.execute("/system/bin/ping", ["-c", item.get_count(), item.get_ip()], true, returned)
	else:
		output.text += OS.get_name() + " is unsupported. Try Linux, Android, or Windows"
	
	# Exit Work
	mutex.lock()
	var text : String = returned[0]
	output.text += text + "\n"
	finished_threads += 1
	progress.value = (float(finished_threads) / float(threads.size())) * 100
	mutex.unlock()

func _on_Add_pressed():
	var new_item := ip_item.instance()
	ip_items.add_child(new_item)

func _on_Subtract_pressed():
	if ip_items.get_child_count() <= 0:
		return
	
	ip_items.get_child(ip_items.get_child_count() - 1).queue_free()
