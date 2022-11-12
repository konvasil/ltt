// =====================================================================
// SuperCollider Workspace
// =====================================================================

o = Server.default.options;
o.numOutputBusChannels.postln;
o.device ="JackBridge";     // use a specific soundcard
Server.default.reboot

s.boot;

o.sampleRate = "44100.00"

(
b = Buffer.alloc(s, s.sampleRate / Server.default.options.blockSize*2);
p = BuffPlot(b, updateRate:20).play;
)

d = ();

(
n = NetAddr("127.0.0.1", 57121);

~setter = {
	|state = 0|
	Tdef(\oscToJS, {
		loop{
			0.25.wait;
			if(state == 1){
				n.sendMsg('/osc-to-browser', state, "high", rrand(10.0, 1439.0), rrand(0.1, 230.0));
				n.sendMsg('/osc-to-browser', state, "mid", rrand(10.0, 1439.0), rrand(230, 430.0));
				n.sendMsg('/osc-to-browser', state, "low", rrand(10.0, 1439.0), rrand(430.0, 726.0));
				"% state was changed to trigger %".format(state).postln;
			} {
				n.sendMsg('/osc-to-browser', " ");
			}
		}
	});
}
)

~setter.value(0)

Tdef(\oscToJS).play;
Tdef(\oscToJS).stop;

(
var oldUserID,  oldData;
OSCdef(\x, {arg ...args;
	var userID = args[0][1].asString.drop(1).drop(-1).asSymbol;
	var data = args[0][2];
	if(oldUserID !== userID && oldData !== data){
		data = data.asString.parseYAML.collect({|item| item.interpret.max(0.01) });
		d.add(userID -> data);
	};
	oldUserID = userID; oldData = data;
},  '/lick-the-toad/osc-data/to-sc')
)

//access the data as an array:
d.asArray

(
SynthDef(\sinegrain,
	{ arg out=0, freq=440, sustain=0.05, amp=0.99;
		var env, pan = LFNoise1.kr(1).range(-1, 1);
		env = EnvGen.kr(Env.perc(0.01, sustain*Rand(0.5, 1), 0.5), doneAction:2);
		Out.ar(out, Pan2.ar(SinOsc.ar(freq, 0.5pi, env), pan, amp*0.5) * LFPar.kr(LFNoise1.kr(1)).range(0.1, 1.0))
	}).add;

Pbindef('x',
	\instrument, \sinegrain,
	\dur, 0.15,
	\sustain, Pwhite(0.1, Pkey(\dur)/2, inf),
	\amp, Pwhite(0.1, 1.0, inf),
	\freq, Pfunc{ Pxrand(d.asArray[0].values, inf, 0.1).asStream.next });
Pbindef(\x).play(quant:(phase:4.0.rand));

Pbindef('y',
	\instrument, \sinegrain,
	\dur, 0.15,
	\sustain, Pwhite(0.1, Pkey(\dur)/2, inf),
	\amp, Pwhite(0.1, 1.0, inf),
	\freq, Pfunc{ Pxrand(d.asArray[1].values*2, inf, 0.1).asStream.next });
Pbindef(\y).play(quant:(phase:4.0.rand));

Pbindef('z',
	\instrument, \sinegrain,
	\dur, 0.15,
	\sustain, Pwhite(0.1, Pkey(\dur)/2, inf),
	\amp, Pwhite(0.1, 1.0, inf),
	\freq, Pfunc{ Pseq(d.asArray[2].values*4, inf, 1).asStream.next });
Pbindef(\z).play(quant:(phase:4.0.rand));
)

(
SynthDef(\recordbuf, {
		RecordBuf.kr(\freq.kr(0.5, 0.3), b)
}).add;

Pbindef('f',
	\instrument, \recordbuf,
	\dur, b.duration + 10.rand,
	\freq, Pfunc{
		v = d.asArray[1].values.collect({|items| items / 1400.0 });
		Pxrand(v, inf).asStream.next
	});
Pbindef(\f).play(quant:(phase:1.0.rand));
)

Ndef(\playbuf, {SinOsc.ar(PlayBuf.kr(1, b, loop: 1).range(40, 120) * LFPar.kr(LFNoise1.kr(0.1)).range(0.1,1), 0, 0.1).dup }).play(0, 2);

Ndef(\playbuf)[1] = nil

//Using Winston's (Winston Tsun Yeung) Looper Ugen.
(
Ndef(\looper, {
	Pan2.ar(
		Looper.ar(
		Ndef(\playbuf).ar,
		2,
		b.duration,
		\recRate.kr(1, 3),
		\recScale.kr(1, 3),
		\recDur.kr(0.25, 3),
		\playStart.kr(0.1, 3) * BufFrames.ir(b),
		\playRate.kr(1, 3),
		\playScale.kr(1, 3),
		\playDur.kr(0.1, 3)
		).sum * EnvGen.kr(Env.sine(6), doneAction:2),
		LFNoise1.kr(1).range(-1, 1))
}).play(0, 2);

Ndef(\looper)[8] = \xset ->
Pbind(\dur, 0.25,
		\recRate, Pwhite(0.1, 1.0, inf),
		\recScale, Pwhite(0.1, 1.0, inf),
		\recDur, Pwhite(0.1, 1.0, inf),
		\playStart, Pwhite(0.1, 1.0, inf),
		\playRate, Pwhite(0.1, 1.0, inf),
		\playScale, Pwhite(0.1, 1.0, inf),
		\playDur, Pwhite(0.1, 1.0, inf)
);
)

Ndef.clear

s.meter


NdefMixer(s)

s.meter

Ndef.clear