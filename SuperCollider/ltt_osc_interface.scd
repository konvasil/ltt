(
var oldUserID,  oldData, usr = [];
~listener = { |msg, time, replyAddr, recvPort|
	var oscArray, checkBadVals, userID, address;
	if(msg[0] != '/status.reply') {
		//"At time %s received message % from % on port%\n".postf( time, msg, replyAddr, recvPort );
		msg.postln;
		userID = msg[0].asString.drop(1);
		oscArray = msg[1].asString.parseJSON;
		checkBadVals = oscArray.collect(_.notNil).reject(_.isNil);
		if(checkBadVals != false && oldUserID != userID && oldData != oscArray) { //proceed on assigning values after check for nils in osc array.
			"User with ID: % sent message % at time %\n".postf(userID, oscArray, time);
			oscArray = oscArray.keysValuesDo({|index, value|
				value = value.interpret;
				usr = [];
				{\notifier.changed(index.asSymbol, userID, value.max(0.01))}.defer;
				usr.push([userID] ++ index ++ value);
			});
		};
		oldUserID = userID;
		oldData = oscArray;
	}
};

thisProcess.addOSCRecvFunc(~listener);

~window = Window("LTT Streams").front.view.layout = HLayout (
	* (~sliders = {Slider()} !3));
\listener.addNotifier(\notifier, \0, { |key, val|
	(~sliders[0].value = val / 1000.0);
});
\listener.addNotifier(\notifier, \1, { |key, val|
	(~sliders[1].value = val / 1000.0);
});
\listener.addNotifier(\notifier, \2, { |key, val|
	(~sliders[2].value = val / 1000.0);
});

~window.onClose_({"OSC terminated".postln; thisProcess.removeOSCRecvFunc(~listener)});
)