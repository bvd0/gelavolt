package game.boards;

import game.boardstates.EndlessBoardState;

@:structInit
@:build(game.Macros.buildOptionsClass(EndlessBoard, SingleStateBoard))
class EndlessBoardOptions {}

class EndlessBoard extends SingleStateBoard {
	@inject @copy final endlessState: EndlessBoardState;

	public function new(opts: EndlessBoardOptions) {
		super({
			pauseMediator: opts.pauseMediator,
			inputDevice: opts.inputDevice,
			playActionBuffer: opts.playActionBuffer,
			state: opts.endlessState
		});

		endlessState = opts.endlessState;
	}

	override function update() {
		if (inputDevice.getAction(QUICK_RESTART)) {
			endlessState.onLose();
		}

		super.update();
	}
}
