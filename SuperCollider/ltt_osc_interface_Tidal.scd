//Server.default.options.outDevice_("Stream").reboot;

(
var menu, button, snd, events;
~dict = ();
~date = Date.getDate;
Pdef(\licks).fadeTime=1.0;
~lick = NodeProxy.audio(s, 2);
~lick.fadeTime = 2;
~funcDict = IdentityDictionary();
~keyIndex = [0, 1, 2, 3, 4, 5, 6, 7];
~tidal = NetAddr("localhost", 6010);
v = s.volume;
v.gui;

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
				[index, userID, value].postln;
				\notifier.changed(~keyIndex[index.asInteger], userID, value, ~date.localtime);
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

~numberBox = NumberBox();
~numberBox.value = 0;
~numberBox.step_(1);

~funcDict[\pattern] = {|id, data|
	var def, pat = data.values.asArray.collect({|val| (val.asInteger.cpsmidi.round(0.1) / 10.0).abs });
	//~def = Pbindef(id.asSymbol, \freq, Pseq(pat, inf));
	~midi = ((0..7)).collect({|i, item| (~sliders[item].value.midicps) });
	~text.setString("\n" ++ "Pdef(\\" ++
		id.asString ++ "," ++
		"Pbind(\\dur, 1, \\instrument, \\default, \\degree, Pseq(" ++ pat.asCompileString ++ ", 1))).play; " + "\n");
	//~lick[0 + ~numberBox.increment.value.asInteger] = ~text.string;
	~lick.sources.do(_.postcs);

	//Forward the message to other apps like Tidal and Utopia if running;
	if( ~dirt.notNil ){
		~tidal.sendMsg('/ctrl', 'speed', *~midi.cpsmidi.round(0.1).asString.postln);
		if(~addrBook.notNil) {
		~addrBook.sendAll('/lick/utopia', *~midi);
		}
	} {
		"no tidal connection is found".warn;

	};
};

~selectWindow.onClose_({
	"OSC terminated".postln;
	~dict.clear;
	Pdef.clear;
	OSCdef(\lickin).free;
	~funcDict.clear;
	~lick.clear;
	[\listener, \notifier].do({_.objectClosed});
});

~keyIndex.collect({|index|
	\listener.addNotifier(\notifier, index, {|user_id, val, notifier, time|
	//var usr = "/%".format(key);
	~sliders[index].value = val.asFloat / 1000.0;
		~sliderWindow.name = "User " + user_id;
	});
	index
});
)

