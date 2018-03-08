/**Created by Morn,Do not modify.*/
package game.ui {
	import morn.core.components.*;
	public class mainUI extends View {
		public var btn_reset:Button;
		public var btn_right:Button;
		public var btn_left:Button;
		public var ztai:Label;
		protected var uiXML:XML =
			<View>
			  <Container x="364" y="368" right="10" bottom="10">
			    <Button label="重置" skin="png.comp.button" x="90" var="btn_reset" width="39" height="23"/>
			    <Button label="右边" skin="png.comp.button" x="45" var="btn_right" width="39" height="23"/>
			    <Button label="左边" skin="png.comp.button" var="btn_left" width="39" height="23"/>
			  </Container>
			  <Label x="6" y="5" width="128" height="18" var="ztai" color="0x9833"/>
			</View>;
		override protected function createChildren():void {
			createView(uiXML);
		}
	}
}