package
{
	import com.cyj.app.ToolsApp;
	import com.cyj.utils.Log;
	import com.cyj.utils.load.ResData;
	import com.cyj.utils.load.ResLoader;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class PakReader
	{
		private var _url:String;
		private var _data:Object;
		public function PakReader(url:String)
		{
			_url = url;
			ToolsApp.loader.loadSingleRes(_url, ResLoader.BYT, handleByteLoaded);
		}
		
		private function handleByteLoaded(res:ResData):void
		{
			var byte:ByteArray = res.data;
			decodePak(byte);
		}
		
		
		
		public function decodePak(byte:ByteArray, pass:int=0):void
		{
			byte.position = 0;
			var head:int= byte.readInt();
			var version:int = head&0xff;
			if((head & 0xffffff00)!= 0x72606d00)
			{
				return;
			}
			Log.log("版本验证通过 version:"+version+"数据大小:"+byte.length);
			if(pass == 0)
			{
				if(version>0)
				{
					var s:String = byte.readUTFBytes(version);
					Log.log("读取utf-8:"+s);
					var ba:ByteArray = new ByteArray();
					ba.writeBytes(byte, byte.position);
					decodePak(ba, 1);
					return;
				}
			}
			//读内容
			var en:int = byte.readByte()*16;
			var enc:int = en;
			var keyIndex:int = byte.readByte();
			var keystr:Object ={};
			keystr[1] = "agr)&)*MBD;";
			if(keyIndex<0 || keystr.hasOwnProperty(keyIndex)==false)
			{
				return;
			}
			Log.log("内容长度:"+ en);
			var key:ByteArray = new ByteArray();
			var temp:ByteArray = new ByteArray();
			key.writeUTF(keystr[keyIndex]);
			var len:int = key.length;
			
			temp.writeBytes(byte, byte.position);
			temp.position = 0;
			
			if(en>temp.length)
				en = temp.length;
			var j:int=0;
			for(var i:int=0; i<en; i++)
			{
				temp[i] = temp[i]-key[j++];
				if(j==len)
					j = 0;
			}
			
			temp.position = 0;
			if(pass==1 && version==0)
				temp.uncompress();
			
			_data = temp.readObject();
			if(_data is ByteArray)
			{
				var tby:ByteArray = _data as ByteArray;
				tby.uncompress();
				_data = tby.readObject();
			}
			
			var result:ByteArray = new ByteArray();
			result.writeBytes(temp, temp.position);
			Log.log("读取完毕开始解析图片");
			ToolsApp.file.saveByteFile(outPath()+".png", result);
			
			
			var filist:* = _data.fi;
			var outData:Array = [];
			for(i=0; i<filist.length; i++)
			{
				if(filist[i] == null)continue;
				var frames:Array = filist[i].frames;
				for(j=0; j<frames.length; j++)
				{
					if(frames[j] == null)continue;
					var arr:Array = frames[j];
					for(var m:int=0; m<arr.length; m++)
					{
						if(frames[j][m]==null)continue;
							outData.push(parserToMyData(frames[j][m]));
					}
				}
			}
			ToolsApp.file.saveFile(outPath()+".json", JSON.stringify(outData));
			ToolsApp.CURNUM++;
			Log.log("解析完毕"+_url+"  "+ToolsApp.CURNUM+"/"+ToolsApp.TOTNUM);
			
		}
		
		private function outPath():String
		{
			var outPath:String = _url.replace(/\\/gi, "/");
			outPath = outPath.replace(".pak", "");
			return outPath.replace("D:/junyou2015/hcz/res/u/", "D:/outpak/");
		}
		
		
		private function parserToMyData(data:Object):Object
		{
			var obj:Object = {};
			if(data==null)
				return obj;
			obj.ix = data.ix;
			obj.iy = data.iy;
			obj.ox = data.ox;
			obj.oy = data.oy;
			obj.width = data.width;
			obj.height = data.height;
			return obj;
		}
		
	}
}