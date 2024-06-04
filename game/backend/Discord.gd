extends Node2D

# yes the daniel pref is very necessary 
# id n stuff will only reset once you restart the game fuck you
func _ready():
	var _id:int = 1227081103932657664 if Prefs.daniel else 1225971084998737952
	var _l_img:String = 'daniel' if Prefs.daniel else 'fembo'
	var _l_txt:String = 'I LOVE DANIEL' if Prefs.daniel else 'out here unholy-ing baby'
	DiscordRPC.app_id = _id
	DiscordRPC.large_image = _l_img
	DiscordRPC.large_image_text = _l_txt
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	change_presence('Workin on Unholy Engine woop', 'Yuhhh I love daniel')
	
	#DiscordRPC.refresh()

func _process(_delta):
	DiscordRPC.run_callbacks()

func change_presence(main:String = 'Nuttin', sub:String = 'Check it'):
	DiscordRPC.details = 'I LOVE DANIEL' if Prefs.daniel else main
	DiscordRPC.state = 'I LOVE DANIEL' if Prefs.daniel else sub
	DiscordRPC.refresh()
