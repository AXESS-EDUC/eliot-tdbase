function mykeyhandler() {
	if (window.event && window.event.keyCode == 8 && window.event.srcElement.type != "text" &&
                                event.srcElement.type != "textarea" &&
                                event.srcElement.type != "password")
    { // try to cancel the backspace 
		window.event.cancelBubble = true;
		window.event.returnValue = false;
		return false;
	}
}
document.onkeydown = mykeyhandler;

