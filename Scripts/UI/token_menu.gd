extends CenterContainer

func open():
	if visible:
		hide()
		return
	show()

func close():
	hide()
