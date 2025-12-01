extends ColorRect

var startTime:int

func ready()->void:
	startTime=Time.get_ticks_msec()

func trigger(player:Node2D)->void:
	$Control/Time.text="Time: "+formatTime(Time.get_ticks_msec()-startTime)
	$Control/Deaths.text="Deaths: "+str(player.deathCount)
	
static func formatTime(timeMS:int) -> String:
	@warning_ignore("integer_division")
	return str(timeMS/60000).pad_zeros(1)+":"+str((timeMS/1000)%60).pad_zeros(2)+"."+str(timeMS%1000).pad_zeros(2)
