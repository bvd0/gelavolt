package game.net;

enum abstract PacketType(Int) from Int {
	final SYNC_REQ;
	final SYNC_RESP;
	final INPUT;
	final INPUT_ACK;
	final BEGIN_REQ;
	final BEGIN_RESP;
}
