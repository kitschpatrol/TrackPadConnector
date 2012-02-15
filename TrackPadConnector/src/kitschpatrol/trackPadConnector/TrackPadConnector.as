package kitschpatrol.trackPadConnector {
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TouchEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	
	public class TrackPadConnector extends EventDispatcher {
		
		private static const log:ILogger = getLogger(TrackPadConnector);		
		private static var instance:TrackPadConnector;
		private var tongsengProcess:NativeProcess;
		public var touchPoints:Array;	
		protected var flashStage:Stage;
		private var mapEntireTouchpad:Boolean;
			
		
		public function TrackPadConnector(stage:Stage, mapEntireTouchpad:Boolean = true, deviceIndex:int = 0, target:IEventDispatcher=null) {
			super(target);
			
			// TODO implement this (only show touch when in window...)
			this.mapEntireTouchpad = mapEntireTouchpad;
			
			if (instance != null) throw new Error("TrackPadConnector is a singleton class and can only have one instance." );

			if (NativeProcess.isSupported) {
				var host:String = "localhost";
				var port:int = 3333;
				
				startTongsengTUIODispatcher(host, port, deviceIndex);
			}
			else {
				throw Error('Native Process is not supported.  Please check that your Air descriptor file has ' +
					'<supportedProfiles>extendedDesktop desktop</supportedProfiles>' +
					'Your Air Descriptor file is typically located in your application root with the name of YOUR_APP-app.xml' +
					'Your application also has to be packaged as a native application.')
			}
			
			this.flashStage = stage;
			this.flashStage.nativeWindow.addEventListener(Event.CLOSING, onWindowClose)
			instance = this; // Singleton enforcement
			touchPoints = [];
		}
		
		
		private function startTongsengTUIODispatcher(host:String, port:int, deviceIndex:int):void	{
			// Listen over STDIN, don't actually care about TUIO network
			var tongsengFile:File = File.applicationDirectory.resolvePath("tongsengmod");
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.arguments.push("-v", host, port, deviceIndex);
			nativeProcessStartupInfo.executable = tongsengFile;
			
			tongsengProcess = new NativeProcess();
			tongsengProcess.start(nativeProcessStartupInfo);
			tongsengProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStdout);
			tongsengProcess.addEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit)
			
			if (tongsengProcess.running) log.info("TrackPadConnector process started on device " + deviceIndex);
		}
		
		
		private function onStdout(event:ProgressEvent):void {
			var output:String = tongsengProcess.standardOutput.readUTFBytes(tongsengProcess.standardOutput.bytesAvailable);
			var lines:Array = output.split("\n");
			
			// Split the lines, make sure there's something there, then parse it
			for each (var line:String in lines) {
				if (line.length > 0) {
					parseLine(line);			
				}
			}
		}
		
		
		private function parseLine(line:String):void {
			var values:Array = line.split(" ");

			var sessionID:int;				
			var x:Number;
			var y:Number;
			var t:Point;			
			var p:Point;
			var currentTargets:Array;
			var currentTarget:DisplayObject;
			var index:int;
			
			if (values[0] == "set") {
				// Packet format for "update":				
				// set obj [symbol ID] ([session ID]) [x] [y] [angle] [vx] [vy] [rotation speed] [motion accel?] [rotation accel]
				
				// Value extraction
				sessionID = parentheticalToInt(values[3]);
				x = values[4] * flashStage.stageWidth;
				y = values[5] * flashStage.stageHeight;	
				t = new Point(x, y);
				var vx:Number = values[7];
				var vy:Number = values[8];
				
				// Update touch list
				for (index = 0; index < touchPoints.length; index++) {
					if (sessionID == touchPoints[index].id) break;
				}
				
				touchPoints[index].x = x;
				touchPoints[index].y = y;
				touchPoints[index].vx = vx;
				touchPoints[index].vy = vy;
				
				// Dispatch touch event
				currentTargets = getTargets(t, TouchEvent.TOUCH_MOVE);
				
				for each (currentTarget in currentTargets) {
					p = currentTarget.globalToLocal(t);
					currentTarget.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_MOVE, true, false, sessionID, false, p.x, p.y, 0, 0, 0, null, false, false, false, false,false));
				}
			}
			else if (values[0] == "add") {
				// Packet format for new touch point:
				// add obj [symbol ID] ([session ID]) [x] [y] [angle]
				
				// Value extraction
				sessionID = parentheticalToInt(values[3]);				
				x = values[4] * flashStage.stageWidth;
				y = values[5] * flashStage.stageHeight;	
				t = new Point(x, y);
				
				// Add to touch list
				touchPoints.push(new TouchPoint(sessionID, x, y));
				
				// Dispatch touch event
				currentTargets = getTargets(t, TouchEvent.TOUCH_BEGIN);
				
				for each (currentTarget in currentTargets) {
					p = currentTarget.globalToLocal(t);
					currentTarget.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_BEGIN, true, false, sessionID, false, p.x, p.y));
				}					
			}
			else if (values[0] == "del") {
				// Packet format for removing touch point:
				// del obj [symbol ID] ([session ID])		
				
				// Value Extraction
				sessionID = parentheticalToInt(values[3]);
				
				// Remove from touch list
				for (index = 0; index < touchPoints.length; index++) {
					if (sessionID == touchPoints[index].id) break;
				}
				
				// Grab last x and Y
				x = touchPoints[index].x;
				y = touchPoints[index].y;
				t = new Point(x, y);
				
				// Remove from the touch list
				touchPoints.splice(index, 1);				

				//  Dispatch touch event
				currentTargets = getTargets(t, TouchEvent.TOUCH_END);
				
				for each (currentTarget in currentTargets) {
					p = currentTarget.globalToLocal(t);
					currentTarget.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_END, true, false, sessionID, false, p.x, p.y));
				}
			}
		}
		
		
		// Event Handlers		
		private function onWindowClose(event:Event):void {
			if (tongsengProcess.running) tongsengProcess.exit(true);
		}
		
		
		private function onNativeProcessExit(event:NativeProcessExitEvent):void	{
			log.info("TrackPadConnector process exited");
		}			
		
		// Utilities
		private function parentheticalToInt(s:String):int {
			// Regex faster?
			s = s.replace("(", "");
			s = s.replace(")", "");
			return int(s);
		}			
		
		private function getTargets(p:Point, eventType:String):Array {
			var a:Array = [];
			for each(var ed:EventDispatcher in flashStage.getObjectsUnderPoint(p)) {
				a.push(ed);
			}
			return a;
		}
		
	}
}