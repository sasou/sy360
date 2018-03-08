package game.view 
{
	import game.ui.mainUI;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class main extends mainUI  {
		
		public function main() 
		{			
			btn_left.addEventListener(MouseEvent.CLICK, onbtn_leftClick);
			btn_right.addEventListener(MouseEvent.CLICK, onbtn_rightClick);
			btn_reset.addEventListener(MouseEvent.CLICK, onbtn_resetClick);
		}	
		
		private function onbtn_leftClick(e:MouseEvent):void {
			trace("left");
			Main.mouseleftright = 1;
		}
		private function onbtn_rightClick(e:MouseEvent):void {
			trace("right");
			Main.mouseleftright = 2;
		}
		private function onbtn_resetClick(e:MouseEvent):void {
			trace("reset");
			Main.mouseleftright = 0;
		}
		public function setztai(text:String):void
		{
			ztai.text = text;
		}
		
	}
	

}