extends Node

# warning-ignore:unused_signal
signal main_ready(obs_websocket_scene)
# warning-ignore:unused_signal
signal reset_player_lines
# warning-ignore:unused_signal
signal game_changed(game_name)
# warning-ignore:unused_signal
signal player_name_changed(obs_source, new_name)
# warning-ignore:unused_signal
signal player_social_changed(obs_source, new_social)
# warning-ignore:unused_signal
signal player_pronoun_changed(obs_source, new_pronoun)
# warning-ignore:unused_signal
signal player_character_changed(obs_source, new_character)
# warning-ignore:unused_signal
signal player_character_override_changed(obs_source, new_character_override)
# warning-ignore:unused_signal
signal best_of_changed(new_max)
# warning-ignore:unused_signal
signal score_changed(obs_source, new_score)
# warning-ignore:unused_signal
signal settings_changed(source, dict)
# warning-ignore:unused_signal
signal filename_array_changed(array)
