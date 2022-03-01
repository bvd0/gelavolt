package main_menu;

import save_data.Profile;
import input.InputDeviceManager;
import main_menu.ui.MainMenuPage;
import ui.Menu;
import kha.graphics2.Graphics;
import Screen.IScreen;
import kha.graphics4.Graphics as Graphics4;

class MainMenuScreen implements IScreen {
	final menu: Menu;

	public function new() {
		menu = new Menu(new MainMenuPage(Profile.primary.prefsSettings));
		menu.onShow(InputDeviceManager.any);
	}

	public function update() {
		menu.update();
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		menu.render(g, alpha);
	}
}
