package game.ui;

import game.rules.Rule;
import game.rules.MarginTimeManager;
import game.boardstates.TrainingInfoBoardState;
import game.garbage.GarbageManager;
import save_data.TrainingSettings;
import game.simulation.ChainSimulator;
import game.boards.TrainingBoard;
import game.all_clear.AllClearManager;
import game.boardstates.TrainingBoardState;
import game.Queue;
import game.randomizers.Randomizer;

@:structInit
class TrainingPauseMenuOptions extends PauseMenuOptions {
	public final rule: Rule;
	public final randomizer: Randomizer;
	public final queue: Queue;
	public final playState: TrainingBoardState;
	public final infoState: TrainingInfoBoardState;
	public final trainingBoard: TrainingBoard;
	public final allClearManager: AllClearManager;
	public final chainSim: ChainSimulator;
	public final marginManager: MarginTimeManager;
	public final trainingSettings: TrainingSettings;
	public final playerGarbageManager: GarbageManager;
	public final infoGarbageManager: GarbageManager;
}
