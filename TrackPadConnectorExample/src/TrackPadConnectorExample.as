package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.TouchEvent;
	
	import kitschpatrol.trackPadConnector.TouchPoint;
	import kitschpatrol.trackPadConnector.TrackPadConnector;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.LOGGER_FACTORY;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.logging.setup.SimpleTargetSetup;
	import org.as3commons.logging.setup.target.TraceTarget;
	
	public class TrackPadConnectorExample extends Sprite {
		
		// Touch
		private var trackPadConnector:TrackPadConnector;
		
		// Settings
		private var drawWithVelocity:Boolean = true;
		private var mapEntireTouchpad:Boolean = true;
		
		// Logging
		private static const log:ILogger = getLogger(TrackPadConnectorExample);		
		
		
		public function TrackPadConnectorExample() {
			stage.align = StageAlign.TOP_LEFT;
			
			// Route log messages to trace
			LOGGER_FACTORY.setup = new SimpleTargetSetup(new TraceTarget());
			
			// Fill in background
			this.graphics.beginFill(0xcccccc);
			this.graphics.drawRect(0, 0, 1024, 768);
			this.graphics.endFill();
			
			// Set up multitouch
			trackPadConnector = new TrackPadConnector(this.stage, mapEntireTouchpad, 1);
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin, true);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove, true);
			stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd, true);
		}
		
		
		private function onTouchBegin(event:TouchEvent):void {
			log.info("Touch Down Point " + event.touchPointID);
			drawTouchPoints();
		}
		
		
		private function onTouchMove(event:TouchEvent):void {
			log.info("Touch Move Point " + event.touchPointID);	
			drawTouchPoints();
		}
		
		
		private function onTouchEnd(event:TouchEvent):void {
			log.info("Touch End Point " + event.touchPointID);			
			drawTouchPoints();
		}
		
		
		private function drawTouchPoints():void {
			removeChildren();
			
			for each(var touchPoint:TouchPoint in trackPadConnector.touchPoints) {				
				var dot:Shape = new Shape();
				dot.graphics.beginFill(0x000000, 0.75);
				dot.graphics.drawCircle(0, 0, 10);
				dot.graphics.endFill();

				dot.x = touchPoint.x;
				dot.y = touchPoint.y;
				
				if (drawWithVelocity) {
					var magnitude:Number = touchPoint.velocity.length;
					var direction:Number = Math.atan2(touchPoint.velocity.y, touchPoint.velocity.x) * (180 / Math.PI);
				
					dot.width = dot.width * (1 + Math.abs(magnitude));
					dot.rotation = direction;
				}
				
				addChild(dot);
			}
		}
	
	}
}