package com.loading
{

	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.system.System;

	/**
	 * ...
	 * @author .....sasou
	 */

	public class ImageLoader extends Sprite {

		private var imagesData:Array=[];
		private var _loaderArr:Array=[];
		private var urlLoader:URLLoader=new URLLoader();
		private var imgUrl:URLRequest=new URLRequest();
		private var imgLoader:Loader;
		private var bitmap:Bitmap;
		private var index:int=0;
        
		public function get loaderArr():Array {
			return this._loaderArr;
		}
		public function set loaderArr(_value:Array):void {
			this._loaderArr=_value;
		}
		
		public function ImageLoader(datas:Array):void {
			imagesData=datas;

			loadImgData();
		}

		private function loadImgData():void {
			if (imagesData.length>0) {
				var obj:Object=imagesData.shift();
				loadImage(obj.src);
			}
		}

		private function loadImage(urls:String):void {
			configureListeners(urlLoader);
			urlLoader.dataFormat=URLLoaderDataFormat.BINARY;
			loadUrl(urls);
		}

		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}

		public function loadUrl(src:String):void {
			try {
				imgUrl.url=src;
				urlLoader.load(imgUrl);
			} catch (error:Error) {
				trace("loadError:"+error);
			}
		}

		private function completeHandler(e:Event):void {
			e.currentTarget.removeEventListener(Event.COMPLETE,completeHandler);
			imgLoader=new Loader();
			imgLoader.loadBytes(e.currentTarget.data);
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderCompleteHandler);
			imgLoader.contentLoaderInfo.addEventListener(Event.UNLOAD,loaderUnloadHandler);
			imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loaderErrorHandler);
		}

		private function progressHandler(e:ProgressEvent):void {
			trace("img_progressHandler loaded:" + e.bytesLoaded + " total: " + e.bytesTotal);
		}

		private function ioErrorHandler(event:Event):void {
			trace("ioErrorHandler: " + event);
			if (imagesData.length>0) {
				loadImgData();
				index++;
			} else {
				this.dispatchEvent(new Event("ALLCOMPLETE"));//发送图片全部加载完成事件 
			}
		}

		private function loaderCompleteHandler(e:Event):void {
			imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loaderCompleteHandler);
			bitmap=e.currentTarget.content as Bitmap;
			_loaderArr.push(bitmap);
			imgLoader.unload();
			imgLoader=null;
			System.gc();

			if (imagesData.length<1) {
				this.dispatchEvent(new Event("ALLCOMPLETE"));//发送图片全部加载完成事件 
			} else {
				loadImgData();
				index++;
			}
		}

		private function loaderUnloadHandler(e:Event):void {
			trace("img_loaderUnloadHandler:"+e);
		}

		private function loaderErrorHandler(e:IOErrorEvent):void {
			trace("img_loaderErrorHandler:"+e);
		}
	}
}