package sym.controller.utils
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;

	public class ImageUtility
	{
		public static const PNG:String=".png";
		public static const JPEG:String=".jpeg";

		public static function saveImage(component:UIComponent, title:String, type:String):void
		{
			var bitmapData:BitmapData=new BitmapData(component.width, component.height);
			bitmapData.draw(component, new Matrix());
			var fileReference:FileReference=new FileReference();
			
			var ba:ByteArray;
			if (type == ImageUtility.PNG)
			{
				var pngEncoder:PNGEncoder=new PNGEncoder();
				ba=pngEncoder.encode(bitmapData);
				fileReference.save(ba, title+type);
			}
			else if (type == ImageUtility.JPEG)
			{
				var jpegEncoder:JPEGEncoder=new JPEGEncoder();
				ba=jpegEncoder.encode(bitmapData);
				fileReference.save(ba, title+type);
			}
		}
	}
}
