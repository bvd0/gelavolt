package game.fields;

import game.copying.ConstantCopyableMap;
import game.copying.ConstantCopyableArray;
import game.copying.ICopy;
import game.gelos.GeloPoint;
import game.gelos.GeloColor;

class FieldPopInfo implements ICopy {
	@copy public final beginners: ConstantCopyableArray<GeloPoint>;
	@copy public final clears: ConstantCopyableArray<GeloPoint>;
	@copy public final clearsByColor: ConstantCopyableMap<GeloColor, Int>;

	@copy public var hasPops: Bool;

	public function new() {
		beginners = new ConstantCopyableArray([]);
		clears = new ConstantCopyableArray([]);
		clearsByColor = new ConstantCopyableMap([COLOR1 => 0, COLOR2 => 0, COLOR3 => 0, COLOR4 => 0, COLOR5 => 0]);
	}

	public function copy() {
		return new FieldPopInfo().copyFrom(this);
	}

	public function addClear(color: GeloColor, x: Int, y: Int) {
		clears.data.push({color: color, x: x, y: y});
		if (color.isColored())
			clearsByColor.data[color]++;
	}
}
