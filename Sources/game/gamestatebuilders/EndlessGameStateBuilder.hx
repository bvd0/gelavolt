package game.gamestatebuilders;

import input.IInputDevice;
import game.ui.PauseMenu;
import game.ui.ReplayPauseMenu;
import game.mediators.TransformationMediator;
import game.mediators.FrameCounter;
import save_data.Profile;
import game.actionbuffers.ReplayActionBuffer;
import game.actionbuffers.LocalActionBuffer;
import game.gamemodes.EndlessGameMode;
import game.actionbuffers.IActionBuffer;
import game.ui.EndlessPauseMenu;
import game.boardstates.EndlessBoardState;
import game.boardmanagers.SingleBoardManager;
import game.previews.VerticalPreview;
import game.garbage.NullGarbageManager;
import game.simulation.LinkInfoBuilder;
import game.garbage.trays.GarbageTray;
import game.simulation.NullLinkInfoBuilder;
import game.geometries.BoardGeometries;
import game.boards.SingleStateBoard;
import game.all_clear.AllClearManager;
import game.gelogroups.GeloGroup;
import game.fields.Field;
import game.simulation.ChainSimulator;
import game.score.ScoreManager;
import game.mediators.BorderColorMediator;
import game.mediators.PauseMediator;
import game.rules.MarginTimeManager;
import game.particles.ParticleManager;
import game.randomizers.Randomizer;
import kha.math.Random;
import game.states.GameState;

class EndlessGameStateBuilder {
	final gameMode: EndlessGameMode;
	final transformMediator: TransformationMediator;
	final inputDevice: IInputDevice;

	var rng: Random;
	var randomizer: Randomizer;

	var particleManager: ParticleManager;
	var marginManager: MarginTimeManager;
	var frameCounter: FrameCounter;

	var pauseMediator: PauseMediator;
	var borderColorMediator: BorderColorMediator;

	var scoreManager: ScoreManager;
	var chainSim: ChainSimulator;
	var chainCounter: ChainCounter;
	var field: Field;
	var queue: Queue;
	var actionBuffer: IActionBuffer;
	var geloGroup: GeloGroup;
	var allClearManager: AllClearManager;

	var boardState: EndlessBoardState;

	var board: SingleStateBoard;

	var pauseMenu: PauseMenu;

	var gameState: GameState;

	public function new(opts: EndlessGameStateBuilderOptions) {
		gameMode = opts.gameMode;
		transformMediator = opts.transformMediator;
		inputDevice = opts.inputDevice;
	}

	inline function buildRNG() {
		rng = new Random(gameMode.rngSeed);
	}

	inline function buildRandomizer() {
		randomizer = new Randomizer({
			rng: rng,
			prefsSettings: Profile.primary.prefsSettings
		});

		randomizer.currentPool = FOUR_COLOR;
		randomizer.generatePools(TSU);
	}

	inline function buildParticleManager() {
		particleManager = new ParticleManager();
	}

	inline function buildMarginManager() {
		marginManager = new MarginTimeManager(gameMode.rule);
	}

	inline function buildFrameCounter() {
		frameCounter = new FrameCounter();
	}

	inline function buildPauseMediator() {
		pauseMediator = new PauseMediator();
	}

	inline function buildBorderColorMediator() {
		borderColorMediator = new BorderColorMediator();
	}

	inline function buildScoreManager() {
		scoreManager = new ScoreManager({
			rule: gameMode.rule,
			orientation: LEFT
		});
	}

	inline function buildChainSim() {
		chainSim = new ChainSimulator({
			rule: gameMode.rule,
			linkBuilder: new LinkInfoBuilder({
				rule: gameMode.rule,
				marginManager: marginManager
			}),
			garbageDisplay: GarbageTray.create(Profile.primary.prefsSettings),
			accumulatedDisplay: GarbageTray.create(Profile.primary.prefsSettings)
		});
	}

	inline function buildChainCounter() {
		chainCounter = new ChainCounter();
	}

	inline function buildField() {
		field = Field.create({
			prefsSettings: Profile.primary.prefsSettings,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildQueue() {
		queue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildActionBuffer() {
		if (gameMode.replayData == null) {
			actionBuffer = new LocalActionBuffer({
				frameCounter: frameCounter,
				inputDevice: inputDevice
			});

			return;
		}

		actionBuffer = new ReplayActionBuffer({
			frameCounter: frameCounter,
			inputDevice: inputDevice,
			replayData: gameMode.replayData
		});
	}

	inline function buildGeloGroup() {
		final prefsSettings = Profile.primary.prefsSettings;

		geloGroup = new GeloGroup({
			field: field,
			rule: gameMode.rule,
			prefsSettings: prefsSettings,
			scoreManager: scoreManager,
			chainSim: new ChainSimulator({
				rule: gameMode.rule,
				linkBuilder: NullLinkInfoBuilder.instance,
				garbageDisplay: GarbageTray.create(prefsSettings),
				accumulatedDisplay: GarbageTray.create(prefsSettings)
			})
		});
	}

	inline function buildAllClearManager() {
		allClearManager = new AllClearManager({
			rng: rng,
			particleManager: particleManager,
			geometries: BoardGeometries.CENTERED,
			borderColorMediator: borderColorMediator
		});
	}

	inline function buildBoardState() {
		boardState = new EndlessBoardState({
			rule: gameMode.rule,
			prefsSettings: Profile.primary.prefsSettings,
			transformMediator: transformMediator,
			rng: rng,
			geometries: BoardGeometries.CENTERED,
			particleManager: particleManager,
			geloGroup: geloGroup,
			field: field,
			garbageManager: NullGarbageManager.instance,
			queue: queue,
			preview: new VerticalPreview(queue),
			allClearManager: allClearManager,
			scoreManager: scoreManager,
			actionBuffer: actionBuffer,
			chainCounter: chainCounter,
			chainSim: chainSim,
			trainingSettings: Profile.primary.trainingSettings,
			randomizer: randomizer
		});
	}

	inline function buildBoard() {
		board = new SingleStateBoard({
			actionBuffer: actionBuffer,
			pauseMediator: pauseMediator,
			inputDevice: inputDevice,
			state: boardState
		});
	}

	inline function buildPauseMenu() {
		if (gameMode.replayData == null) {
			pauseMenu = new EndlessPauseMenu({
				pauseMediator: pauseMediator,
				prefsSettings: Profile.primary.prefsSettings,
				trainingSettings: Profile.primary.trainingSettings,
				actionBuffer: actionBuffer,
				gameMode: gameMode
			});

			return;
		}

		pauseMenu = new ReplayPauseMenu({
			pauseMediator: pauseMediator,
			prefsSettings: Profile.primary.prefsSettings,
			actionBuffer: cast(actionBuffer, ReplayActionBuffer),
		});
	}

	inline function buildGameState() {
		gameState = new GameState({
			particleManager: particleManager,
			marginManager: marginManager,
			boardManager: new SingleBoardManager({
				transformMediator: transformMediator,
				geometries: BoardGeometries.CENTERED,
				board: board
			}),
			pauseMenu: pauseMenu,
			frameCounter: frameCounter
		});
	}

	inline function wireMediators() {
		pauseMediator.gameState = gameState;
		borderColorMediator.boardState = boardState;
	}

	public function build() {
		buildRNG();
		buildRandomizer();

		buildParticleManager();
		buildMarginManager();
		buildFrameCounter();

		buildPauseMediator();
		buildBorderColorMediator();

		buildScoreManager();
		buildChainSim();
		buildChainCounter();
		buildField();
		buildQueue();
		buildActionBuffer();
		buildGeloGroup();
		buildAllClearManager();

		buildBoardState();

		buildBoard();

		buildPauseMenu();

		buildGameState();

		wireMediators();

		return gameState;
	}
}
