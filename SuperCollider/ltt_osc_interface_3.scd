(
var menu, button, userData, snd, text;
~dict = ();
~date = Date.getDate;
~updateSliders = [0, 1, 2, 3, 4, 5, 6, 7];
OSCdef(\lickin, {|...args|
	var userID = args[0][1].asString.asSymbol;
	var keys_2_symbols = {|v, i| (i % 2 == 0).if(v.asSymbol, v)};
	var oscArray = args[0][2].asString.parseJSON.asPairs.collect(keys_2_symbols).asEvent; // make keys symbols and then event - not necessary, but nice
	var checkBadVals = oscArray.collect(_.notNil).reject(_.isNil) != false;
	var time = args[1];
	if(checkBadVals) {
		"User with ID: % sent message % at time %\n".postf(userID, oscArray, ~date.localtime);
		~dict[userID] = oscArray;
		{
			menu.items_(~dict.keys.asArray);
			userData = ~dict.values.asArray;
		}.defer;
		oscArray.keysValuesDo({|index, value|
			{
				\notifier.changed(~keyIndex[index.interpretVal], userID, value.interpretVal, time);
			}.defer;
		});
	};
}, '/lick');

~selectWindow = Window("Capture Patterns")
.front.view.layout = VLayout (
	* ([menu = PopUpMenu(), text = TextView().focus(true);])
);

~button = Button(~selectWindow, Rect(110, 10, 180, 20))
.states_([["generate", Color.black, Color.green]])
.mouseDownAction_({
	snd = userData.at(menu.value);
})
.action_({|butt, mod|
	var array = snd.values.collect{arg v; v.interpretVal / 10.0};
		text.string = snd.asString;
	~funcDict[\default].value(menu.item, array);
});

~sliderWindow = Window("LTT Streams")
.front.view.layout = HLayout(
	* ( ~sliders = {Slider() } !6) );

~updateSliders.collect({|index| \listener.addNotifier(\notifier, index, {|key, val, notifier, time|
	var usr = "/%".format(key);
	~sliders[index].value = val / 1000.0;
}); index});

~funcDict = IdentityDictionary();

~funcDict[\default] = {|id, data|
	Pdef(id.asSymbol, Pbind(
		\instrument, \sinegrain,
		\amp, -1.25.dbamp.round(0.01),
		\midinote, Pseq(data + 10, 1),
		\octave, 1,
		\dur, 0.1, \legato, 3).trace
	).play;
};

~selectWindow.onClose_({
	"OSC terminated".postln;
	~dict.clear;
	Pdef.clear;
	OSCdef(\lickin).free;
	[\listener, \notifier].do({_.objectClosed});
});

CmdPeriod.add( OSCdef(\lickin)  )
)

//server/client comms
n=NetAddr("localhost", 57122);
n.sendMsg('/kv', "markov_train");
n.sendMsg('/kv', "osc_trigger");