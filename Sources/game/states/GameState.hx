package game.states;

import game.mediators.FrameCounter;
import game.rules.MarginTimeManager;
import kha.graphics4.ConstantLocation;
import game.particles.ParticleManager;
import game.boardmanagers.IBoardManager;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

@:structInit
@:build(game.Macros.buildOptionsClass(GameState))
class GameStateOptions {}

class GameState {
	@inject final particleManager: ParticleManager;
	@inject final boardManager: IBoardManager;
	@inject final marginManager: MarginTimeManager;
	@inject final frameCounter: FrameCounter;

	final FADE_TO_WHITELocation: ConstantLocation;

	public function new(opts: GameStateOptions) {
		game.Macros.initFromOpts();

		FADE_TO_WHITELocation = Pipelines.FADE_TO_WHITE.getConstantLocation("comp");
	}

	public function update() {
		boardManager.update();
		particleManager.update();
		marginManager.update();

		frameCounter.update();
	}

	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		g.pipeline = Pipelines.FADE_TO_WHITE;
		g4.setPipeline(g.pipeline);
		g4.setFloat(FADE_TO_WHITELocation, 0.5 + Math.cos(frameCounter.value / 4) / 2);
		g.pipeline = null;

		particleManager.renderBackground(g, alpha);
		boardManager.render(g, g4, alpha);
		particleManager.renderForeground(g, alpha);
	}
}
