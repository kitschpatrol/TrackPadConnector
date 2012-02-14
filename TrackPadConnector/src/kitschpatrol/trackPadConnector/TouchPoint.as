package kitschpatrol.trackPadConnector
{
	import flash.geom.Point;

	public class TouchPoint	{
		
		public var id:int;
		public var x:int;
		public var y:int;
		public var vx:Number;
		public var vy:Number;
		
		public function TouchPoint(id:int, x:int, y:int) {
			this.id = id;
			this.x = x;
			this.y = y;
			vx = 0;
			vy = 0;
		}
		
		public function get position():Point {
			return new Point(x, y);
		}
		
		public function get velocity():Point {
			return new Point(vx, vy);
		}		
	}
}