extends Control

signal obs_connected()
signal obs_updated(data)
signal obs_scene_list_returned(data)

class ObsObject:
	var obs_name: String = "changeme"
	
	func _to_string() -> String:
		return obs_name

class ObsGetSceneListResponse:
	var current_scene: String
	var scenes: Array = [] # ObsScene
	
	func _to_string() -> String:
		return str({
			"current_scene": current_scene,
			"scenes": scenes
		})

class ObsScene extends ObsObject:
	var sources: Array = [] # ObsSceneItem
	
	func _to_string() -> String:
		return str({
			"obs_name": obs_name,
			"sources": sources
		})

class ObsSceneItem extends ObsObject:
	var cy: float
	var cx: float
	var alignment: float
	var id: int
	var render: bool
	var muted: bool
	var locked: bool
	var source_cx: float
	var source_cy: float
	var obs_type: String
	var volume: float
	var x: float
	var y: float
	# NOT YET IMPLMENTED
	# var parent_group_name: String # Optional
	# var group_children: Array # ObsSceneItem Optional
	
	func _init(
		p_cy: float,
		p_cx: float,
		p_alignment: float,
		p_name: String,
		p_id: int,
		p_render: bool,
		p_muted: bool,
		p_locked: bool,
		p_source_cx: float,
		p_source_cy: float,
		p_obs_type: String,
		p_volume: float,
		p_x: float,
		p_y: float,
		p_parent_group_name: String = "",
		p_group_children: Array = []
	) -> void:
		cy = p_cy
		cx = p_cx
		alignment = p_alignment
		obs_name = p_name
		id = p_id
		render = p_render
		muted = p_muted
		locked = p_locked
		source_cx = p_source_cx
		source_cy = p_source_cy
		obs_type = p_obs_type
		volume = p_volume
		x = p_x
		y = p_y
		# parent_group_name = p_parent_group_name
		# group_children = p_group_children
	
	func _to_string() -> String:
		return str({
			"cy": cy,
			"cx": cx,
			"alignment": alignment,
			"obs_name": obs_name,
			"id": id,
			"render": render,
			"muted": muted,
			"locked": locked,
			"source_cx": source_cx,
			"source_cy": source_cy,
			"obs_type": obs_type,
			"volume": volume,
			"x": x,
			"y": y
		})

const URL_PATH: String = "ws://%s:%s"

const POLL_TIME: float = 1.0
var poll_counter: float = 0.0

var obs_client := WebSocketClient.new()

var request_counter: int = -1

export var host: String = "127.0.0.1"
export var port: String = "4444"
export var password: String = "" # It's plaintext lmao, you should be changing this programmatically

const PreconfiguredCommands = {
	"GET_SCENE_LIST": "GetSceneList"
}
var last_command: String = "n/a"
var waiting_for_response := false

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	obs_client.connect("connection_closed", self, "_on_connection_closed")
	obs_client.connect("connection_error", self, "_on_connection_error")
	obs_client.connect("connection_established", self, "_on_connection_established")
	obs_client.connect("data_received", self, "_on_data_received")
	obs_client.connect("server_close_request", self, "_on_server_close_request")
	
	obs_client.verify_ssl = false

func _process(delta: float) -> void:
	poll_counter += delta
	if poll_counter >= POLL_TIME:
		poll_counter = 0.0
		if obs_client.get_connection_status() != WebSocketClient.CONNECTION_DISCONNECTED:
			obs_client.poll()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_connection_closed(_was_clean_close: bool) -> void:
	print("OBS connection closed")

func _on_connection_error() -> void:
	print("OBS connection error.")
	# Have to create our own JSON here since this error doesn't return anyway.
	# This is a copy of the Authentication error, just with Connection in its place.
	var json_response : Dictionary = {"error":"Connection Error.", "message-id":"1", "status":"error"}
	emit_signal("obs_updated", json_response)

func _on_connection_established(_protocol: String) -> void:
	print("OBS connection established")
	
	obs_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	_get_auth_required()

func _on_data_received() -> void:
	var message: String = obs_client.get_peer(1).get_packet().get_string_from_utf8().strip_edges().strip_escapes()
	
	var json_response = parse_json(message)
	if typeof(json_response) != TYPE_DICTIONARY:
		print("Invalid json_response: %s" % json_response)
		return
		
	if json_response.has("error"):
		print(json_response)
		print("Error: %s" % json_response["error"])
	
	if json_response.has("authRequired"):
		var secret_combined: String = "%s%s" % [password, json_response["salt"]]
		var secret_base64 = Marshalls.raw_to_base64(secret_combined.sha256_buffer())
		var auth_combined: String = "%s%s" % [secret_base64, json_response["challenge"]]
		var auth_base64: String = Marshalls.raw_to_base64(auth_combined.sha256_buffer())
		_authenticate(auth_base64)
		return
	elif (json_response.has("message-id") and json_response["message-id"] == "1"):
		if json_response["status"] == "ok":
			emit_signal("obs_connected")
			return
	elif json_response.has("update-type") and json_response["update-type"] == "StreamStatus":
		return

	else:
		if waiting_for_response:
			match last_command:
				PreconfiguredCommands.GET_SCENE_LIST:
					# Courtesy null check
					if (not json_response.has("current-scene") or not json_response.has("scenes")):
						printerr("Invalid response from obs")
						return

					last_command = "N/A"
					var data := ObsGetSceneListResponse.new()
					data.current_scene = json_response["current-scene"]
					
					for i in json_response["scenes"]:
						var obs_scene := ObsScene.new()
						obs_scene.obs_name = i["name"]
						for j in i["sources"]:
							var obs_scene_item := ObsSceneItem.new(
								j["cy"],
								j["cx"],
								j["alignment"],
								j["name"],
								j["id"],
								j["render"],
								j["muted"],
								j["locked"],
								j["source_cx"],
								j["source_cy"],
								j["type"],
								j["volume"],
								j["x"],
								j["y"]
							)
							obs_scene.sources.append(obs_scene_item)
						data.scenes.append(obs_scene)
					emit_signal("obs_scene_list_returned", data)
					waiting_for_response = false
					return

	emit_signal("obs_updated", json_response)

func _on_server_close_request(_code: int, _reason: String) -> void:
	print("OBS close request received")
	obs_client.disconnect_from_host()

###############################################################################
# Private functions                                                           #
###############################################################################

func _get_auth_required() -> void:
	print("Sending GetAuthRequired message")
	var text := JSON.print({"message-id": _generate_message_id(), "request-type": "GetAuthRequired"})
	
	obs_client.get_peer(1).put_packet(text.to_utf8())

func _authenticate(auth: String) -> void:
	print("Sending auth response")
	var text := JSON.print({"message-id": _generate_message_id(), "request-type": "Authenticate", "auth": auth})
	
	obs_client.get_peer(1).put_packet(text.to_utf8())

func _generate_message_id() -> String:
	request_counter += 1
	return str(request_counter)

###############################################################################
# Public functions                                                            #
###############################################################################

func establish_connection() -> void:
	if obs_client.connect_to_url(URL_PATH % [host, port]) != OK:
		print("Could not connect to OBS websocket")

func break_connection() -> void:
	obs_client.disconnect_from_host()

func send_command(command: String, data: Dictionary = {}) -> void:
	#print("command is %s." % command)
	#print("data is %s" % data)
	if waiting_for_response:
		print("Still waiting for response for last command")
		return
	
	data["request-type"] = command
	data["message-id"] = _generate_message_id()
	#print(data)
	obs_client.get_peer(1).put_packet(JSON.print(data).to_utf8())

# Preconfigured commands

func get_scene_list() -> void:
	last_command = PreconfiguredCommands.GET_SCENE_LIST
	send_command(PreconfiguredCommands.GET_SCENE_LIST)
	waiting_for_response = true
