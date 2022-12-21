s.options.outDevice_("BlackHole 2ch");
s.reboot;

(
~dict = ();
~keyIndex = [\0, \1, \2];
OSCdef(\lickin, {|...args|
	var userID = args[0][1].asString.asSymbol;
	var keys_2_symbols = {|v, i| (i % 2 == 0).if(v.asSymbol, v)};
	var oscArray = args[0][2].asString.parseJSON.asPairs.collect(keys_2_symbols).asEvent; // make keys symbols and then event - not necessary, but nice
	var checkBadVals = oscArray.collect(_.notNil).reject(_.isNil) != false;
	var time = args[1];
	if(checkBadVals) {
		//"User with ID: % sent message % at time %\n".postf(userID, oscArray, args[1]);
		~dict[userID] = oscArray;
		oscArray.keysValuesDo({|index, value|
			{ \notifier.changed(~keyIndex[index.interpretVal], userID, value.interpretVal, time) }.defer;
		});
	};
}, '/lick');


~window = Window("LTT Streams").front.view.layout = HLayout (
	* ( ~sliders = {Slider() } !3) );

~keyIndex.collect({|index| \listener.addNotifier(\notifier, index, {|key, val, time, notifier|
	var usr = "/%".format(key);
	(usr.drop(1) ++ " User moved Slider:" ++ notifier.message ++ " " ++ val ++ " @ " ++ time).postln;
	(~sliders[index.interpretVal].value = val / 1000.0);
}); index});

~window.onClose_({"OSC terminated".postln; [\listener, \notifier].do({_.objectClosed})});
)

n = NetAddr("localhost", 57122);
n.sendMsg('/kv', "markov_train");
n.sendMsg('/kv', "osc_trigger");

BuffPlot.new(b, 44100)