package game.ui;

import ui.InputLimitedListPage;
import ui.IListWidget;

class ControlsPage extends InputLimitedListPage {
	public function new(opts: ControlsPageOptions) {
		super({
			header: opts.header,
			widgetBuilder: (menu) -> opts.actions.map((action) -> (new InputWidget(action) : IListWidget)),
			inputDevice: opts.inputDevice
		});

		controlDisplays = [
			{actions: [UP, DOWN], description: "Select List Entry"},
			{actions: [BACK], description: "Back"},
			{actions: [CONFIRM], description: "Rebind"}
		];
	}
}
