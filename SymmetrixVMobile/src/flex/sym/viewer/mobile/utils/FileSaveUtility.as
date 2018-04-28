package sym.viewer.mobile.utils
{
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.geom.Matrix;
    import flash.net.FileFilter;
    import flash.utils.ByteArray;
    
    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;
    import mx.graphics.codec.JPEGEncoder;
    import mx.graphics.codec.PNGEncoder;
    import mx.messaging.events.MessageEvent;
    
    import sym.controller.SymmController;
    import sym.controller.events.XmlImportErrorEvent;
    import sym.controller.events.XmlImportedEvent;
    import sym.objectmodel.common.ComponentBase;
    import sym.viewer.mobile.views.components.popups.MessagePopup;

    public class FileSaveUtility
    {
		public static const FILE_STATUS_SAVED:String = "file_status_saved";
		public static const FILE_STATUS_NAME_COLLIDE:String = "file_status_name_collide";
        public static const PNG:String = "png";
		private static const JPEG:String="jpg";
        private static const XML_EXT:String = "xml";

        private static const ROOT_FOLDER:String = "PowerMax Studio";
        private static const IMG_FOLDER:String = "img";
        private static const XML_FOLDER:String = "xml";
		
		public static var IMG_FILE_PATH:String;
		public static var XML_FILE_PATH:String;

        public static var isXml:Boolean = false;
		public static var justSaveConfig:Boolean = false;
		
        private static var _bitmapData:BitmapData;
        private static var _ba:ByteArray;
        private static var _file:File;
        private static var _pngEncoder:PNGEncoder = new PNGEncoder();
        private static var _jpegEncoder:JPEGEncoder = new JPEGEncoder();
		private static var _xmlToSave:XML;
		private static var _nameCollision:Boolean = false;
		private static var status:String;

		
        public static function exportPictureOnIOS(component:UIComponent, fileName:String, overwrite:Boolean):String
        {
            _bitmapData = new BitmapData(component.width, component.height);
            _bitmapData.draw(component, new Matrix());
            _ba = _pngEncoder.encode(_bitmapData);
			resolveSavingPathAndStore(fileName, IMG_FOLDER, overwrite);
			return status;
        }

        public static function storeXmlOnIOS(xml:XML, fileName:String, overwrite:Boolean):String
        {
			_xmlToSave = xml;
            resolveSavingPathAndStore(fileName, justSaveConfig ? resolveFolderPath() : XML_FOLDER, overwrite);
			return status;
        }
		
		public static function resolveFolderPath():String
		{
			if(is250F() || is950F())
				return "xml" + File.separator + "vmax";
			else
				return "xml" + File.separator + "powermax";
		}

		/**
		 * Gets store folder
		 * @param childFolder img/xml folder 
		 * @return 
		 * 
		 */		
		private static function createFolderPath(childFolder:String):File
		{
			var rootFolder:File = File.documentsDirectory.resolvePath(ROOT_FOLDER);
			if (!rootFolder.isDirectory)
			{
				rootFolder = File.documentsDirectory.resolvePath(ROOT_FOLDER);
				rootFolder.createDirectory();
			}
			var storeFolder:File = rootFolder.resolvePath(childFolder);
			if (!storeFolder.isDirectory)
			{
				storeFolder = rootFolder.resolvePath(childFolder);
				storeFolder.createDirectory();
			}
			
			return storeFolder;
		}
		
        private static function resolveSavingPathAndStore(fileName:String, childFolder:String, overwrite:Boolean):void
        {
			var storeFolder:File = createFolderPath(childFolder);
			
			var myFile:File = storeFolder.resolvePath(fileName);
			_file = new File(myFile.nativePath);
			_nameCollision = false;
			status = FILE_STATUS_SAVED;
			
			if(!overwrite){
				var checkFile:File = storeFolder.resolvePath(conformExtension(fileName));
				if(checkFile.exists){
					_nameCollision = true;
					status = FILE_STATUS_NAME_COLLIDE;
				}
			}
			
			if(!_nameCollision)
			{	
				var tmpArr:Array = _file.nativePath.split(File.separator);
				var fileName:String = tmpArr.pop();
				var conformedFileDef:String = conformExtension(fileName);
				tmpArr.push(conformedFileDef);
				var conformedFile:File = new File("file:///" + tmpArr.join(File.separator));
				var stream:FileStream = new FileStream();
				stream.open(conformedFile, FileMode.WRITE);
				if (isXml)
				{
					stream.writeUTFBytes(_xmlToSave.toString()); 
					XML_FILE_PATH = conformedFile.nativePath;
				}
				else
				{
					stream.writeBytes(_ba, 0, _ba.length);
					IMG_FILE_PATH = conformedFile.nativePath;
				}
				stream.close();
			}
        }

        private static function conformExtension(fileDef:String):String
        {
            var fileExtension:String = fileDef.split(".")[1];
            if (!isXml)
            {
                if (fileExtension == PNG || fileExtension == JPEG)
				{
                    return fileDef;
				}

                return fileDef.split(".")[0] + "." + PNG;
            }
            else
            {
                if (fileExtension == XML_EXT)
                    return fileDef;

                return fileDef.split(".")[0] + "." + XML_EXT;
            }
        }
		
		public static function importXml():void
		{
			var filter:FileFilter = new FileFilter("xmlFiles", "*.xml");
			_file = File.documentsDirectory;
			_file.addEventListener(Event.SELECT, onSelectImportXML);
			_file.browseForOpen("Open file", [filter]);
		}
		
		private static function onSelectImportXML(event:Event):void
		{
			var stream:FileStream = new FileStream();
			stream.open(_file, FileMode.READ);
			try{
				
				var myXml:XML = XML(stream.readUTFBytes(stream.bytesAvailable));
			
				if(myXml.children().length() == 2)
				{
					var myXML:String = myXml.toString();
					var xmlReg:RegExp;
					var newXmlWithoutNamespaces:String;
					var newXML:XML;
					var isValid:Boolean = false;
					
					xmlReg = new RegExp("xmlns[^\"]*\"[^\"]*\"| xsi[^\"]*\"[^\"]*\"", "gi");
					newXmlWithoutNamespaces = myXML.replace(xmlReg, "");
					newXML = new XML(newXmlWithoutNamespaces);
					
					isValid = ComponentBase.validateXml(newXML);
					
					if(!isValid)
					{
						//throw error if values from sizer xml not correct
						SymmController.instance.eventHandler.dispatchEvent(new XmlImportErrorEvent(XmlImportErrorEvent.XML_IMPORT_ERROR));
						return;
					}
					
					SymmController.instance.eventHandler.dispatchEvent(new XmlImportedEvent(XmlImportedEvent.XML_FILES_IMPORTED, newXML, null));
					
				}else
					SymmController.instance.eventHandler.dispatchEvent(new XmlImportedEvent(XmlImportedEvent.XML_IMPORTED, myXml, null));
			}
			catch(er:Error){
				SymmController.instance.eventHandler.dispatchEvent(new XmlImportErrorEvent(XmlImportErrorEvent.XML_IMPORT_ERROR));
			}
			
		}
		
		/**
		 * Import all previously saved xml configuration files
		 */		
		public static function importSavedXMLs():void
		{
			var xmlFiles:ArrayCollection = new ArrayCollection();
			
			var myFiles:Array = createFolderPath(resolveFolderPath()).getDirectoryListing();
			var stream:FileStream = new FileStream();
			
			for each (var file:File in myFiles)
			{
				stream.open(file, FileMode.READ);
				try
				{
					var xml:XML = XML(stream.readUTFBytes(stream.bytesAvailable));
					
					xmlFiles.addItem({xml: xml, fileName: file.name});
				}
				catch(er:Error)
				{
//					throw new Error(er.message + " Importing saved XML failed!");
					trace(er.message + " Importing saved XML failed!");
				}
			}
			
			SymmController.instance.eventHandler.dispatchEvent(new XmlImportedEvent(XmlImportedEvent.XML_FILES_IMPORTED, null, xmlFiles));
		}
		
		
		/**
		 * Delete XML file
		 * @param filename XML file name
		 */
		public static function deleteXml(filename:String):void
		{
			var folder:File = createFolderPath(resolveFolderPath());
			var file:File = folder.resolvePath(filename);
			
			try
			{
				file.deleteFile();
			}
			catch(er:Error)
			{
				trace("Deleting saved XML failed:");
				trace(er.message);
			}
		}
    }
}
