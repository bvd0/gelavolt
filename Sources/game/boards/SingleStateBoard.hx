package game.boards;

import input.IInputDevice;
import game.mediators.PauseMediator;
import game.boardstates.IBoardState;
import kha.graphics2.Graphics;

@:structInit
@:build(game.Macros.buildOptionsClass(SingleStateBoard))
class SingleStateBoardOptions {}

class SingleStateBoard implements IBoard {
	@inject final pauseMediator: PauseMediator;
	@inject final inputDevice: IInputDevice;

	@:s @inject var state: IBoardState;

	public function new(opts: SingleStateBoardOptions) {
		game.Macros.initFromOpts();
	}

	public function update() {
		if (inputDevice.getAction(PAUSE)) {
			pauseMediator.pause(inputDevice);
		}

		state.update();
	}

	public function renderScissored(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		state.renderScissored(g, g4, alpha);
	}

	public function renderFloating(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		state.renderFloating(g, g4, alpha);
	}
}
