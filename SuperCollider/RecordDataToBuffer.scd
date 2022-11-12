// =====================================================================
// SuperCollider Workspace
// =====================================================================
(
s.options.outDevice_("JackBridge");
s.options.numInputBusChannels_(1);
s.options.numOutputBusChannels_(2);
s.reboot;
OSCFunc.trace(false)
)

//test audio if jacktrip
play{WhiteNoise.ar(0.02)}
s.scope
//Record controls:

(
b = Buffer.alloc(s, s.sampleRate / Server.default.options.blockSize*2);

//{RecordBuf.kr(LFNoise1.kr(10, 120), b)}.play;

BuffPlot(b);
~loopBus.scope

Ndef(\rec, {RecordBuf.kr( \freq.kr(10, 0.3), b)});

Ndef(\inst, {Pan2.ar(0.5*FreeVerb.ar(Resonz.ar(Instruction.ar(b.bufnum), \resFreq.kr(1000, 0.6), \bwr.kr(0.1, 0.6))))});

Ndef(\in, {SinOsc.ar(PlayBuf.kr(1, b, loop: 1).range(100, 500), 0, 0.1).dup});

~loopBus.scope
b.plot
Ndef(\in)[1] = \filter -> {|in| Shaper.ar(b, in) };
Ndef(\in)[2] = \filter -> {|in| LeakDC.ar(in) };

Ndef(\looper)[1] = \filter -> {|in| Shaper.ar(b, in) };

Spec.add(\freq, [0.001, 1.0]);
Spec.add(\recRate, [0.1, 100]);
Spec.add(\recScale, [0.1, 100]);
Spec.add(\mod, [0.5, 4]);

OSCdef(\rgrsn, {|msg|
	msg.postln;
	Ndef(\rec).set(\freq, \freq.asSpec.map(msg[1] / 1000));
	Ndef(\fftbuf).set(\freq, \freq.asSpec.map(msg[1] / 1000));
	Ndef(\fftbuf).set(\mod, \mod.asSpec.map(msg[1] / 1000));
}, '/neural/net/regression');

OSCdef(\crsX, {|msg|
	msg.postln;

	Ndef(\looper).set(\recRate, \recRate.asSpec.map(msg[1].round(1.0)/ 1000));
}, '/neural/net/cursor/x');

OSCdef(\crsY, {|msg|
	msg.postln;

	Ndef(\looper).set(\recScale, \recScale.asSpec.map(msg[1].round(0.01) / 1000))
}, '/neural/net/cursor/y');

Ndef(\looper, {Looper.ar(Ndef.ar(\in)*0.5, 2, LFNoise0.kr(1).range(0.1, 1.75), \recRate.kr(1, 9), \recScale.kr(1, 9) )}).play(0, 2);
Ndef(\looper).vol_(0.25);
Ndef(\looper)[1] = \filter -> {|in| FreeVerb.ar( GVerb.ar(in) ) * 0.25 +in };
Ndef(\looper)[2] = \filter -> {|in| Resonz.ar(in, {ExpRand(120, 220)}!4, 1.0.rand) +in };
Ndef(\looper)[3] = \filter -> {|in| Ringz.ar(in, {ExpRand(120, 220)}!4, 1.0.rand) +in };
Ndef(\looper)[4] = \filter -> {|in| CombC.ar(CombC.ar(CombC.ar(in)), \mxdelay.kr(0.2, 2), \delay.kr(0.01, 2), 0.1, 0.6) ** in };

NdefMixer(s);
s.scope;
)
//tester
n = NetAddr("127.0.0.1", 57120);

Tdef(\ctrlr, {
	loop{
		0.4.wait;
		~val = rrand(0.1, 1000);
		n.sendMsg('/neural/net/regression', ~val);
		n.sendMsg('/neural/net/cursor/x', ~val);
		n.sendMsg('/neural/net/cursor/y', ~val);
	}
}).play;

NetAddr.langPort;