package 
{

    import flash.geom.Point;
	
    
    public class Vector
    {
    	public var p1:Point;
    	public var p0:Point;
    	public function Vector(p0:Point,p1:Point):void
    	{
    		this.p0 = p0.clone();
    		this.p1 = p1.clone();
    	}
    	
    	public function get length():Number
    	{
    		return Math.sqrt((p1.x-p0.x)*(p1.x-p0.x) + (p1.y-p0.y)*(p1.y-p0.y));
    	}
    	public function get length2():Number
    	{
    		return (p1.x-p0.x)*(p1.x-p0.x) + (p1.y-p0.y)*(p1.y-p0.y);
    	}
    	public function set length(value:Number):void
    	{
    		var oldLen:Number = length;
    		p1.x = p0.x + (p1.x - p0.x) * value / oldLen;
    		p1.y = p0.y + (p1.y - p0.y) * value / oldLen;
    	}
    	public function moveTo(value:Point):void
    	{
    		p1.x = value.x + x;
    		p1.y = value.y + y;
    		p0.x = value.x;
    		p0.y = value.y;
    	}
    	
    	public function perp():void
    	{
    		var oldX:Number = x;
    		var oldY:Number = y;
    		x = oldY;
    		y = -oldX;
    	}
    	
    	public function invert():void
    	{
    		var tmp:Point = p0;
    		p0 = p1;
    		p1 = tmp;
    	}
    	
    	public function clone():Vector
    	{
    		return new Vector(p0,p1);
    	}
    	public function get x():Number
    	{
    		return p1.x - p0.x;
    	}
    	public function set x(value:Number):void
    	{
    		p1.x = p0.x + value;
    	}
    	public function set y(value:Number):void
    	{
    		p1.y = p0.y + value;
    	}
    	
    	public function get y():Number
    	{
    		return p1.y - p0.y;
    	}
    	
    	public function xForY(value:Number):Number
    	{
    		var t:Number = (value-p0.y)/y;
    		return p0.x + t*x;
    	}
    
    	public function yForX(value:Number):Number
    	{
    		var t:Number = (value-p0.x)/x;
    		return p0.y + t*y;
    	}
    	public function add(v:Vector):void
    	{
    		p1.x += v.x;
    		p1.y += v.y;		
    	}
    	public function dot(v:Vector):Number
    	{
    		return x * v.x + y * v.y;
    	}
    	public function mult(v:Number):void
    	{
    		x *= v;
    		y *= v;
    	}
    	public function reflect(n:Vector):void
    	{
    		n = n.clone();
    		n.mult(2 * dot(n));
    		p1.x -= n.x;
    		p1.y -= n.y;
    		
    		p1.x = p0.x - (p1.x - p0.x);
    		p1.y = p0.y - (p1.y - p0.y);
    	}
    	
    	public function normalize():void
    	{
    		length /= length;
    	}	
    	public function get angle():Number
    	{
    		return Math.atan2(x,-y);
    	}
    	
    }
}