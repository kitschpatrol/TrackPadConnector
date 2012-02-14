package {
	import kitschpatrol.trackPadConnector.TouchPoint;
	import kitschpatrol.trackPadConnector.TrackPadConnector;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.display.StageAlign;
	
	public class TrackPadConnectorExample extends Sprite {
				
		private var trackPadConnector:TrackPadConnector;
		private var touchTestCanvas:Sprite;
		
		// Settings
		private var drawWithVelocity:Boolean = true;
		private var mapEntireTouchpad:Boolean = true;
		
		
		public function TrackPadConnectorExample() {
			stage.align = StageAlign.TOP_LEFT;
			
			// Fill in background
			this.graphics.beginFill(0xcccccc);
			this.graphics.drawRect(0, 0, 1024, 768);
			this.graphics.endFill();			
			
			// Set up multitouch
			trackPadConnector = new TrackPadConnector(this.stage, mapEntireTouchpad, 1);
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

			this.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			this.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			this.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		}
		
		
		private function onTouchBegin(event:TouchEvent):void {
			drawTouchPoints();
		}
		
		
		private function onTouchMove(event:TouchEvent):void {
			drawTouchPoints();
		}
		
		
		private function onTouchEnd(event:TouchEvent):void {
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