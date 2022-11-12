// =====================================================================
// SuperCollider Workspace
// =====================================================================

OSCFunc.trace(false)
s.boot
NetAddr.langPort


//Live Ambisonics => Binaural Morning Fun
//Stochastic Synthesis
//use headphones for true binaural experience
///This is Lick The Toad Ambisonics and Binaural Version
////////////////////////////

(
s.options.outDevice_("JackBridge");
s.reboot;
s.scope
//s.makeWindow;
//OSCFunc.trace(false)
)


//Record controls:

(
b = Buffer.alloc(s, s.sampleRate / Server.default.options.blockSize*2);
p = BuffPlot(b, updateRate:20).play;
)
p.free
b.free
//{RecordBuf.kr(LFNoise1.kr(10, 120), b)}.play;

Spec.add(\freq, [-1, 0.99]);

Ndef.clear




Ndef(\playbuf)[1] = \filter -> {|in| Shaper.ar(b, in) + in };
Ndef(\playbuf)[2] = \filter -> {|in| LeakDC.ar(in)};

(
Ndef(\looper, {
	Looper.ar(
		\in.ar([0,0])*0.25, 2,
		b.duration,
		\recRate.kr(1, 3),
		\recScale.kr(1, 3),
		\recDur.kr(0.25, 3),
		\playStart.kr(0.1, 3) * BufFrames.ir(b),
		\playRate.kr(1, 3),
		\playScale.kr(1, 3),
		\playDur.kr(0.1, 3)
	)
}).play(0, 2);
)

s.scope


Ndef(\instr, {Instruction.ar(b.bufnum)}).play;

Ndef(\looper)[1] = \filter -> {|in| Shaper.ar(b, in) + in };
Ndef(\looper)[2] = \filter -> {|in| LeakDC.ar(in) + in };
Ndef(\looper)[3] = \filter -> {|in| Resonz.ar(in) + in };
Ndef(\looper)[4] = \filter -> {|in| FreeVerb.ar(in)*0.5 + in};
Ndef(\looper)[5] = \filter -> {|in| GVerb.ar(in)*0.2 + in };
Ndef(\looper)[6] = \filter -> {|in| Ringz.ar(in*0.07, decay:30, mul:0.1) };
Ndef(\looper)[6] = \filter -> {|in| PitchShift.ar(in, 0.2, 30, 1.1) };

NdefMixer(s)

Ndef(\rec).gui

Ndef(\looper)[1] = \filter -> {|in| Shaper.ar(b, in, add:in) };


Spec.add(\freq, [0.1, 1.0]);
Spec.add(\recRate, [0.1, 1.0]);
Spec.add(\recScale, [0.1, 1]);

(
OSCdef(\rgrsn, {|msg|
	msg.postln;
	Ndef(\rec).set(\freq, \freq.asSpec.map(msg[1] / 1000));
}, '/neural/net/regression');
);

(
OSCdef(\crsX, {|msg|
	msg.postln;
	Ndef(\looper).set(\recRate, \recRate.asSpec.map(msg[1].round(0.01) / 1000.0));
},  '/neural/net/cursor/x');
);


(
OSCdef(\crsY, {|msg|
	msg.postln;
		Ndef(\looper).set(\recScale, \recScale.asSpec.map(msg[1].round(0.01) / 1000.0));
}, '/neural/net/cursor/y');
);



Ndef(\looper).vol_(0.25);
Ndef(\looper)[1] = \filter -> {|in| Shaper.ar(b, in) ** in };
Ndef(\looper)[2] = \filter -> {|in| LeakDC.ar(in) ** in };


Ndef.clear

NdefMixer(s);
)
//tester
n = NetAddr("127.0.0.1", 57120).sendMsg('/right/open/posx', 0.2);
//NetAddr.langPort
//
