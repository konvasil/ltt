// =====================================================================
// SuperCollider Workspace
// =====================================================================

(
//s.options.outDevice = "JackBridge";
s.reboot;
s.doWhenBooted({


	var oldMsg;
	~dict = IdentityDictionary.new;

	OSCdef(\onlyIfChanged, { arg ...msg;

		var array = msg[0].drop(1).postln;

		if(oldMsg != array, {
			//"no dups found: %".format(array).postln;
			~oscDict.value(array)
		});

		oldMsg = array
	}, '/lick');

	~oscDict = {|array|
		[\rgrsn, \xpos, \ypos].do({|item, i|
			~dict.add(item -> array[i])
		});

		~offsetVals = ~dict.values.array.round(0.1) / 1860.0 * 100;
	};

	//test SynthDef

	SynthDef(\sinegrain,
		{ arg out=0, freq=440, sustain=0.05;
			var env, pan = LFNoise1.kr(1).range(-1, 1);
			env = EnvGen.kr(Env.perc(0.01, sustain*Rand(0.1, 1.0), 0.099), doneAction:2);
			Out.ar(out, Pan2.ar(SinOsc.ar(freq, 0.5pi, env), pan))
		}).add;


	Pbindef('x',
		\instrument, \sinegrain,
		\dur, 0.12,
		\sustain, Pwhite(0.1, Pkey(\dur), inf),
		\note, Pfunc{ Pxrand(~offsetVals, inf, 0.1).asStream.next }
	);

	Pbindef(\x).play(quant:(time:2, quant:2, phase:1.rand));

	Tdef(\y, {
		loop{
			12.wait;
			~dict.postln
		};
	}).stop;

});


b = Buffer.alloc(s, s.sampleRate / Server.default.options.blockSize*2);
p = BuffPlot(b, updateRate:20).play;
)


(
//tester
Spec.add(\freq, [-1, 0.99]);
Ndef(\rec, {RecordBuf.kr( \freq.kr(0.0, 0.01), b)}).play;
Ndef(\playbuf, {LFPar.ar(PlayBuf.kr(1, b, loop: 1).range(100, 500), 0, 0.1).dup}).play(0, 1);
NdefMixer(s);
Ndef(\playbuf)[1] = \xset -> Pbind(\dur, 0.5, \freq, Pfunc{ Pxrand(~offsetVals / 100, inf) } ).trace
)

)

s.boot


////
(
var oldUserID,  oldData, d = ();
OSCdef(\x, {arg ...args;
	var userID = args[0][1].asString.drop(1).drop(-1).asSymbol;
	var data = args[0][2];
	if(oldUserID !== userID && oldData !== data){
		data = data.asString.parseYAML.collect({|item| item /*interpret.max(0.01)*/ });
		d.add(userID -> data);
		[userID, data].postln
	};
	oldUserID = userID;
	oldData = data;
	//[userID, data].postln
},  '/lick')
)