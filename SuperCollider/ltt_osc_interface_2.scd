(
~dict = ();

~listener = { |msg, time, replyAddr, recvPort|
	if(msg[0] != '/status.reply') {
		var userID = msg[0].asString.drop(1).asSymbol;
		var keys_2_symbols = {|v, i| (i % 2 == 0).if(v.asSymbol, v)};
		var oscArray = msg[1].asString.parseJSON.asPairs.collect(keys_2_symbols).asEvent; // make keys symbols and then event - not necessary, but nice
		var checkBadVals = oscArray.collect(_.notNil).reject(_.isNil) != false;
		if(checkBadVals) {
			"User with ID: % sent message % at time %\n".postf(userID, oscArray, time);
			~dict[userID] = oscArray;
			oscArray.keysValuesDo({|index, value|
				{\notifier.changed(index.asSymbol, userID, value)}.defer;
			});
		};
	}
};

thisProcess.addOSCRecvFunc(~listener);

~window = Window("LTT Streams").front.view.layout = HLayout (
	* (~sliders = {Slider()} !3));
\listener.addNotifier(\notifier, \0, { |key, val, notifier|
	var usr = "/%".format(key);
	(usr.drop(1) ++ " User moved Slider " ++ notifier.message ++ "_" ++ val.interpret).postln;
	(~sliders[0].value = val.interpret / 1000.0);
});
\listener.addNotifier(\notifier, \1, { |key, val, notifier|
	var usr = "/%".format(key);
	(usr.drop(1) ++ " User moved Slider " ++ notifier.message ++ "_" ++ val.interpret).postln;
	(~sliders[1].value = val.interpret / 1000.0);
});
\listener.addNotifier(\notifier, \2, { |key, val, notifier|
	var usr = "/%".format(key);
	(usr.drop(1) ++ " User moved Slider " ++ notifier.message ++ "_" ++ val.interpret).postln;
	(~sliders[2].value = val.interpret / 1000.0);
});

~window.onClose_({"OSC terminated".postln; \listener.objectClosed; \notifier.objectClosed; ~usersData = nil; thisProcess.removeOSCRecvFunc(~listener)});
)

n = NetAddr("127.0.0.1", 57120);
n.sendMsg("/addr", "{\"k1\": 10, \"key2\": \"foo\"}");



~dict[\addr][\key2]
~dict[\addr][\k1]
~dict[\addr]