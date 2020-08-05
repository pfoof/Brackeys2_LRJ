package theactualgame;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Slime extends FlxSprite
{
	public static final SPEED = 15;

	private var parent:TheActualGameSubstate;

	public function new(X:Float, Y:Float, state:TheActualGameSubstate)
	{
		super(X, Y);

		loadGraphic("assets/images/mmo/sprites.png", true, 8, 8);
		animation.add("slime", [17, 18, 20, 19], 3);
		animation.play("slime");

		setSize(6, 5);
		offset.set(1, 3);

		parent = state;

		health = 10.0;
	}

	private var rollTimeout = 0.8;

	private function move()
	{
		if (parent.player.getMidpoint().distanceTo(this.getMidpoint()) < 20.0)
		{
			var _angle = FlxAngle.angleBetween(parent.player, this, true);
			velocity.set(-SPEED, 0);
			velocity.rotate(FlxPoint.weak(0, 0), _angle);
		}
		else
			switch (FlxG.random.int(0, 4))
			{
				case 0:
					velocity.set(-SPEED, 0);
				case 1:
					velocity.set(SPEED, 0);
				case 2:
					velocity.set(0, SPEED);
				case 3:
					velocity.set(0, -SPEED);
				case 4:
					velocity.set(0, 0);
			}
	}

	private var paralyzed = 0.0;
	private var paralyzedVelocity:FlxPoint;

	public function hitBy(attack:Float)
	{
		if (paralyzed > 0)
			return;
		health -= attack;
		if (health < 0)
		{
			kill();
			return;
		}
		paralyzedVelocity = new FlxPoint(velocity.x, velocity.y);
		paralyzed = 0.8;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (paralyzed > 0)
		{
			paralyzed -= elapsed;
			alpha = 0.7 + 0.1 * FlxMath.fastCos(paralyzed * 8.0);
			if (paralyzed <= 0)
			{
				alpha = 1;
				velocity.set(paralyzedVelocity.x, paralyzedVelocity.y);
			}
			return;
		}

		if (rollTimeout > 0)
		{
			rollTimeout -= elapsed;
			if (rollTimeout <= 0)
			{
				rollTimeout = FlxG.random.float(0.7, 0.9);
				move();
			}
		}
	}
}