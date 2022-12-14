s.options.outDevice_("BlackHole 2ch");
s.reboot;

(
~dict = ();
OSCdef(\lickin, {|...args|
	var userID = args[0][1].asString.asSymbol;
	var keys_2_symbols = {|v, i| (i % 2 == 0).if(v.asSymbol, v)};
	var oscArray = args[0][2].asString.parseJSON.asPairs.collect(keys_2_symbols).asEvent; // make keys symbols and then event - not necessary, but nice
	var checkBadVals = oscArray.collect(_.notNil).reject(_.isNil) != false;
	if(checkBadVals) {
		"User with ID: % sent message % at time %\n".postf(userID, oscArray, args[1]);
		~dict[userID] = oscArray;
		oscArray.keysValuesDo({|index, value|
			{ \notifier.changed(index.asSymbol, userID, value.interpret) }.defer;
		});
	};
}, '/lick');

~window = Window("LTT Streams").front.view.layout = HLayout (
	* (~sliders = {Slider()} !3));
\listener.addNotifier(\notifier, \0, { |key, val, notifier|
	var usr = "/%".format(key);
	(usr.drop(1) ++ " User moved Slider:" ++ notifier.message ++ " " ++ val).postln;
	(~sliders[0].value = val / 1000.0);
});
\listener.addNotifier(\notifier, \1, { |key, val, notifier|
	var usr = "/%".format(key);
	(usr.drop(1) ++ " User moved Slider:" ++ notifier.message ++ " " ++ val).postln;
	(~sliders[1].value = val / 1000.0);
});
\listener.addNotifier(\notifier, \2, { |key, val, notifier|
	var usr = "/%".format(key);
	(usr.drop(1) ++ " User moved Slider:" ++ notifier.message ++ " " ++ val).postln;
	(~sliders[2].value = val / 1000.0);
});

~window.onClose_({"OSC terminated".postln; \listener.objectClosed; \notifier.objectClosed; thisProcess.removeOSCRecvFunc(~listener)});
)

n = NetAddr("localhost", 57122);
n.sendMsg('/kv', "markov_train");
n.sendMsg('/kv', "osc_trigger");
