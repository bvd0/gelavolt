package game.actionbuffers;

class NullActionBuffer implements IActionBuffer {
	public static var instance(get, null): NullActionBuffer;

	static function get_instance() {
		if (instance == null)
			instance = new NullActionBuffer();

		return instance;
	}

	final nullAction: ActionSnapshot;

	function new() {
		nullAction = ActionSnapshot.fromBitField(0);
	}

	public function copy() {
		return instance;
	}

	public function update() {
		return nullAction;
	}

	public function activate() {}

	public function deactivate() {}

	public function exportReplayData() {
		return new ReplayData();
	}
}
