
private function main_selectCamera():void
{
	var newSelection:String = cameraslist.selectedIndex.toString();
	if(curImageCameraSelection == newSelection)
		return;
	var camera:Camera = Camera.getCamera(newSelection);
	imgVid.attachCamera(camera);
}

private function main_imgWebcamSnapMode():void
{
	if(iwacbutton.label == "Snap!")
	{
		iwacbutton.label = "Preview";
		cameraslist.enabled = false;
		camerabox.removeAllChildren();
		camerabox.addChild(imgSnapPanel);
		send_status.enabled = true;
	}
	else
	{
		iwacbutton.label = "Snap!";
		cameraslist.enabled = true;
		main_imgWebcamPreviewMode();
	}
}
			
private function main_createSnapshot():void
{
	imgSnapshot.draw(imgVid, new Matrix());
	imgSnapImage = new Bitmap(imgSnapshot);
	var myShape:Sprite = new Sprite();
	myShape.addChild(imgSnapImage);
	var myWrapper:UIComponent = new UIComponent();
	myWrapper.addChild(myShape);
	imgSnapPanel.removeAllChildren();
	imgSnapPanel.addChild(myWrapper);
	main_imgWebcamSnapMode();	
}
