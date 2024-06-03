/*
A general use default setup for using Utopia.
Utopia enables the sharing of code between all players in a LAN.


Installation

1. You need to install this to run the present file:
https://github.com/muellmusik/Utopia

2. Erase unit_tests from the source folder before recompiling the library.

Wed, May 28 2014, 17:29 EEST
*/

(
/*s.options.numBuffers = 8192;
s.options.numPrivateAudioBusChannels = 8192;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 1;
// use Jack if it's running
//s.options.inDevice = "JackRouter";
//s.options.outDevice = "JackRouter";
s.reboot;
*/

// fix bad values

/*~bvFunc = {
	{var in;

		in = In.ar(0, s.options.numOutputBusChannels);
		in.do({|chan, i|
			var bad;
			bad = CheckBadValues.ar(chan);
			//ReplaceOut.ar(i, if(bad < 1) * chan);
			ReplaceOut.ar(i, Select.ar(bad.clip(0, 1), [chan, Silent.ar]) );
		});

	}.play(RootNode(r.myServer), addAction: \addToTail);
};
ServerTree.add(~bvFunc);
~bvFunc.value;*/


// discover others
~win = Window("Utopia").front;
~history = History.start; //History starting here.
~win.bounds = ~win.bounds.moveTo(0, 600);
~win.layout = VLayout.new.add(~listView = ListView.new);

~addrBook = AddrBook.new;
// to get updates, just add a dependant
~addrBook.addDependant({|addrBook, what, who|
	{~listView.items = addrBook.peers.collectAs({|peer|
		peer.name ++ " | " ++ peer.addr.ip ++ " | " ++ if(peer.online, "online", "offline");
	}, Array)}.defer;
});

~addrBook.addMe; // will automatically add you using your user name
//~addrBook.addMe(Peer('CnR', NetAddr.localAddr)); // use this to override name

~hail = Hail(~addrBook);

// Chat
~chatter = Chatter(~addrBook);

~win.layout.add(VLayout(StaticText().string_("Chatter"), ~textField = TextField(), ~textView = TextView()));
~textField.action_({|v| ~chatter.send(v.string); v.string = "" });
// to get updates, just add a dependant
~chatter.addDependant({|chatter, what, who, chat|
	chat = chat.asString;
	{ ~textView.string_(who ++ ": " ++ chat ++ "\n" ++ ~textView.string) }.defer;
	// Shout
	if (chat.beginsWith(NMLShout.tag)) {
		defer {
			NMLShout((chat.drop(NMLShout.tag.size).reject(_ == $\n) + ("/" ++ who)));
			{~win.front;}.defer(0.1);
		}
	};
});

~sharedData = OSCDataSpace(~addrBook);

//broadcasting OSC to peers in Utopia.
~objSpace = OSCObjectSpace(~addrBook, oscPath:'/someObjs');

//Run this only on the master computer.
//Run this first to receive Tidal events.
OSCdef(\data, { |msg, time, addr, recvPort|
	~objSpace[\tidalEvent] = msg;
	//[msg, time, addr, recvPort].postln;
	~event = ~objSpace[\tidalEvent];
	~event = ~event.asString.drop(2).drop(-2).split($,).drop(1).clump(2).flatten;
}, '/dirt/play');

OSCdef(\d, {|...msg|
	msg.postln;
	~objSpace[\lickEvent] = msg;
},'/lick/utopia');

// Code Relay
~codeRelay = CodeRelay(~addrBook);
~historyGUI = ~history.makeWin;
~codeRelay.addDependant({|chatter, what, who, code|
	if(who != ~addrBook.me.name, {
		~history.enter(code.asString, who);
		{~historyGUI.updateLines;}.defer;
	});
});

)
