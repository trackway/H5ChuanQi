/**Created by the Morn,do not modify.*/
package com.cyj.app.view.ui.mapreversal {
	import morn.core.components.*;
	public class AppMainUI extends View {
		public var txtLog:Label = null;
		protected static var uiXML:XML =
			<View width="650" height="620">
			  <Image skin="png.comp.blank" x="0" y="0" width="650" height="620"/>
			  <Label text="日志" x="2" y="565" width="645" height="49" color="0x33ff00" var="txtLog" wordWrap="true"/>
			  <Label text="made by cyj 2017.11.26" x="512" y="595" color="0x666666"/>
			</View>;
		public function AppMainUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}