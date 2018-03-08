package 
{
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.entities.*;
	import away3d.library.assets.BitmapDataAsset;
	import away3d.materials.*;
	import away3d.materials.methods.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	import away3d.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.geom.Vector3D;
	import flash.external.ExternalInterface;
	import flash.ui.Mouse;
	
	import game.view.main;
	import morn.core.handlers.Handler;
	import com.loading.ImageLoader;
	
	/**
	 * 主程序
	 */
	[SWF(backgroundColor="#ffffff", frameRate="60", quality="LOW")]
	public class Main extends Sprite {
		//engine variables
		private static var _view:View3D;
		private var _skyBox:SkyBox; 
		private var _torus:Mesh;
		
		public var camera_lens:int = 90;
		public var lastKey:uint;
		public var keyIsDown:Boolean = false;
		public static var mouseIsDown:Boolean = false;
		public static var mouseleftright:int = 2;
		public var mouse_x:int = 0;
		public var mouse_y:int = 0;
		public var view_main:main;
		public var js_str:String = '';
		public var sy_params:Object;
		public var is_edit:Boolean = false;

		private var pic_str:Array; //图片路径数组   
        private var bmpDataArr:Array; //存放图片bitmapData的数组  
        private var imageLoader:ImageLoader; //图片加载类  
		
			
		public function Main():void {	
			//初始化组件
			App.init(this);
			//加载语言包，语言包可以做压缩或加密，这里为了简单直接用xml格式
			//App.loader.loadTXT("en.xml", new Handler(loadLang));
			//加载资源			
			App.loader.loadAssets(["assets/comp.swf"], new Handler(callJavaScriptFunction), new Handler(loadProgress));
		}
		
		/**测试多语言*/
		private function loadLang(content:*):void {
			var obj:Object = {};
			var xml:XML = new XML(content);
			for each (var item:XML in xml.item) {
				obj[item.@key] = String(item.@value);
			}
			//设置语言包
			App.lang.data = obj;
		}
		
        private function initLoadImage():void  
        {  
            if(sy_params==null){
				pic_str = [ { src:"360/right.jpg" },{ src:"360/left.jpg" },{ src:"360/top.jpg" },{ src:"360/bottom.jpg" },{ src:"360/near.jpg" },{ src:"360/far.jpg" } ];// 
			}else {
				pic_str = [ { src:sy_params.right },{ src:sy_params.left },{ src:sy_params.top },{ src:sy_params.bottom },{ src:sy_params.near },{ src:sy_params.far } ]; 
			}
            imageLoader = new ImageLoader(pic_str);  
            imageLoader.addEventListener("ALLCOMPLETE", allCompleteHandler);  
        } 
		        
        private function allCompleteHandler(e:Event):void   
        {  
            bmpDataArr = [];  
            for (var i:int = 0; i < imageLoader.loaderArr.length; i++ ) {  
                var bitmap:Bitmap = imageLoader.loaderArr[i] as Bitmap;  
                bmpDataArr.push(bitmap.bitmapData);  
            }
			if(bmpDataArr.length>0){
				if(!is_edit){
					loadComplete();
				}else {
					loadSecond();
				}
			}
        } 
		
		private function loadProgress(value:Number):void {
			//加载进度
			trace("loaded", value);
		}
		
		public function loadSecond():void
		{
			if (check_qx()) {

			}
		}
		
		private function loadComplete():void {
			// create a "hovering" camera
			if(check_qx()){
				//setup the view
				_view = new View3D();
				addChild(_view);

				//setup the camera
				_view.camera.z = -600;
				_view.camera.y = 0;
				_view.camera.lens = new PerspectiveLens(camera_lens);
				_view.camera.lookAt(new Vector3D());

				//setup the cube texture
				var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(Cast.bitmapData(bmpDataArr[0]), Cast.bitmapData(bmpDataArr[1]), Cast.bitmapData(bmpDataArr[2]), Cast.bitmapData(bmpDataArr[3]), Cast.bitmapData(bmpDataArr[4]), Cast.bitmapData(bmpDataArr[5]));

				//setup the environment map material
				var material:ColorMaterial = new ColorMaterial();
				material.addMethod(new EnvMapMethod(cubeTexture, 1));

				//setup the scene
				_torus = new Mesh(new TorusGeometry(50, 20, 1, 1), material);
				_view.scene.addChild(_torus);

				_skyBox = new SkyBox(cubeTexture);
				_view.scene.addChild(_skyBox);
				
				this.stage.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
				this.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
				this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				this.stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, doMouseWheel);
				
				//实例化场景
				view_main = new main();
				view_main.setztai((js_str=='')?'全景播放器':js_str);
				addChild(view_main);
				stage.addEventListener(Event.RESIZE, onStageResize);
				onStageResize(null);
			}
		}
		private function _onEnterFrame(e:Event):void
		{
			//_torus.rotationX += 1;
			//_torus.rotationY += 1;
			//_view.camera.position = new Vector3D();
			//_view.camera.rotationY += 0.5 * (stage.mouseX - stage.stageWidth / 2) / 800;

			if(keyIsDown){
				// if the key is still pressed, just keep on moving
				switch(lastKey){
					case Keyboard.UP	: _view.camera.rotationX -= 0.5; break;
					case Keyboard.DOWN	: _view.camera.rotationX += 0.5; break;
					case 87				: _view.camera.z += 0.3; break;
					case 83				: if(_view.camera.z > 1.4){_view.camera.z -= 0.3} break;
					case Keyboard.LEFT	: _view.camera.rotationY -= 0.5; break;
					case Keyboard.RIGHT	: _view.camera.rotationY += 0.5; break;
				}
			}
			if (mouseIsDown) {
					_view.camera.rotationY += 0.5 * (stage.mouseX - stage.stageWidth / 2) / 800;
			}
			
			if (mouseleftright)
			{
				switch(mouseleftright) {
					case 1:
						_view.camera.rotationY -= 0.1;
						break;
					case 2:
						_view.camera.rotationY += 0.1;
						break;
				}
			}
			_view.camera.moveBackward(600);
			_view.render();
		}
		private function onKeyDown(e:KeyboardEvent):void
		{
			lastKey = e.keyCode;
			keyIsDown = true;
		}
		private function onKeyUp(e:KeyboardEvent):void
		{
			keyIsDown = false;
		}
		private function onMouseDown(e:MouseEvent):void
		{
			mouseIsDown = true;
		}
		private function onMouseUp(e:MouseEvent):void
		{
			mouseIsDown = false;
		}
		private function doMouseWheel(e:MouseEvent):void
		{
			trace(e.delta)
			if (e.delta > 0) { 
				_view.camera.lens = new PerspectiveLens(++camera_lens);
			} else {
				_view.camera.lens = new PerspectiveLens(--camera_lens);
			}
			_view.render();
		}
		private function onStageResize(e:Event):void {
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			view_main.width = stage.stageWidth;
			view_main.height = stage.stageHeight;
		}
		public function check_qx():Boolean
		{
			var urlPath:String;
			if(ExternalInterface.available){ 
				urlPath = ExternalInterface.call('eval', 'window.location.href');
			}else {
				urlPath ='syapi';
			}
			if (urlPath.search("sy") == -1) {
				return false;
			}
			return true;
		}
		private function callJavaScriptFunction():void { 
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("sy_go", sy_go_call);
				ExternalInterface.addCallback("sy_params", sy_params_call);
				ExternalInterface.addCallback("sy_edit", sy_edit_call);
				ExternalInterface.call("sy_Complete", "Complete"); 
			}else {
				trace('Complete');
				initLoadImage();
			}
		} 
		public function sy_go_call(text:String):Boolean { 
			is_edit = false;
			js_str = text;
			initLoadImage();
			return true;
		} 
		public function sy_params_call(obj:Object):Boolean { 
			is_edit = false;
			sy_params = obj;
			trace(sy_params);
			initLoadImage();
			return true;
		} 
		public function sy_edit_call(obj:Object):Boolean { 
			is_edit = true;
			sy_params = obj;
			initLoadImage();
			return true;
		} 
	}
	
}