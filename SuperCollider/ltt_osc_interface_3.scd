Server.default.options.outDevice_("Stream");
s.reboot;
s.waitForBoot({

(
var menu, button, snd, events;
~dict = ();
~date = Date.getDate;
Pdef(\licks, Pbind(\dur, 0.25));
~lick = NodeProxy.audio(s, 2);
~updateSliders = [0, 1, 2, 3, 4, 5, 6, 7];
OSCdef(\lickin, {|...args|
	var userID = args[0][1].asString.asSymbol;
	var keys_2_symbols = {|v, i| (i % 2 == 0).if(v.asSymbol, v)};
	var oscArray = args[0][2].asString.parseJSON.asPairs.collect(keys_2_symbols).asEvent; // make keys symbols and then event - not necessary, but nice
	var checkBadVals = oscArray.collect(_.notNil).reject(_.isNil) != false;
	if(checkBadVals) {
		"ID: % data % at %\n".postf(userID, oscArray, ~date.localtime);
		~dict[userID] = oscArray;
		{
			menu.items_(~dict.keys.asArray);
			events = ~dict.values.asArray;
		}.defer;
		oscArray.keysValuesDo({|index, value|
			{
				\notifier.changed(~updateSliders[index.interpretVal], userID, value.interpretVal, ~date.localtime);
			}.defer;
			});
	}
}, '/lick');

~selectWindow = Window("Capture Patterns")
.front.view.layout = VLayout (
	* ([menu = PopUpMenu(), ~text = TextView().focus(true);])
);

~button = Button(~selectWindow, Rect(110, 10, 180, 20))
.states_([["generate", Color.black, Color.green]])
.mouseDownAction_({
		snd = events.at(menu.value);
})
.action_({|butt, mod|
	~funcDict[\pattern].value(menu.item, snd);

});

~sliderWindow = Window("LTT Streams")
.front.view.layout = HLayout(
	* ( ~sliders = {Slider() } !8) );

~funcDict = IdentityDictionary();

~funcDict[\pattern] = {|id, data|
	var def, pat = data.values.asArray.collect({|val| val.interpretVal.max(80) });
	~def = Pbindef(\licks, \freq, Pseq(pat, inf));
	~lick.source = Pdef(id.asSymbol, Pbind(\freq, Pseq(pat.asInteger, inf), \legato, 0.2, \stretch, 1, \sustain, 0.5));
	~text.setString("\n" + ~lick.source.asCode.asString + "\n");
};

~selectWindow.onClose_({
	"OSC terminated".postln;
	~dict.clear;
	Pdef.clear;
	OSCdef(\lickin).free;
	~funcDict.clear;
	[\listener, \notifier].do({_.objectClosed});
});

~updateSliders.collect({|index|
	\listener.addNotifier(\notifier, index, {|key, val, notifier, time|
	var usr = "/%".format(key);
	~sliders[index].value = val / 1000.0;
		}); index});

)




/*
~funcDict[\lickrand] = {|data, rep|
	var pat;
	~licks.source =
pat = Pbind(
		\dur, 0.1,
		\instrument, \who,
		\freq, Pxrand(data, rep)
	);
	text.setString(pat.asCode.asString + "\n");
};

~funcDict[\lickseq] = {|data, rep|
	var pat;
	~licks.source =
	pat = Pbind(
			\instrument, \who,
			\amp, -2.25.dbamp.round(0.01),
			\freq, Pseq(data, rep),
			\dur, 0.25,
			\legato, 3
		);
	text.setString(pat.asCode.asString + "\n");
};



~nodes = NodeProxy.audio(s, 2).fadeTime_(1.5);
~licks = NodeProxy.audio(s, 2).fadeTime_(1.5);
~tempo = TempoClock.new();
~tempo.tempo = 1;
~nodes.source = ~licks;

CmdPeriod.add(
	OSCdef(\lickin);
);


//server/client comms
n=NetAddr("localhost", 57122);
n.sendMsg('/kv', "markov_train");
n.sendMsg('/kv', "osc_trigger");
	});*/