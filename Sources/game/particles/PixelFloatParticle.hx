package game.particles;

import kha.Color;
import utils.Utils.lerp;
import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

@:structInit
@:build(game.Macros.buildOptionsClass(PixelFloatParticle))
class PixelFloatParticleOptions {}

class PixelFloatParticle implements IParticle {
	public static function create(opts: PixelFloatParticleOptions) {
		final p = new PixelFloatParticle(opts);

		p.lastX = opts.x;
		p.lastY = opts.y;
		p.lastT = 0;

		p.x = opts.x;
		p.y = opts.y;
		p.t = 0;

		p.isAnimationFinished = false;

		return p;
	}

	@inject final dx: Float;
	@inject final dy: Float;
	@inject final maxT: Int;
	@inject final color: Color;
	@inject final size: Float;

	@inject var x: Float;
	@inject var y: Float;

	var lastX: Float;
	var lastY: Float;
	var lastT: Int;
	var t: Int;

	public var isAnimationFinished(default, null): Bool;

	function new(opts: PixelFloatParticleOptions) {
		game.Macros.initFromOpts();
	}

	public function update() {
		if (t == maxT) {
			isAnimationFinished = true;
			return;
		}

		lastX = x;
		lastY = y;
		lastT = t;

		x += dx;
		y += dy;

		t++;
	}

	public function render(g: Graphics, alpha: Float) {
		final lerpedX = lerp(lastX, x, alpha);
		final lerpedY = lerp(lastY, y, alpha);
		final lerpedT = lerp(lastT, t, alpha);

		final opacity = lerp(1, 0, lerpedT / maxT);

		g.color = color;
		g.pushOpacity(opacity);
		g.fillCircle(lerpedX, lerpedY, size, 16);
		g.popOpacity();
		g.color = White;
	}
}
