// =====================================================================
// SuperCollider Workspace
// =====================================================================

SynthDef(\klang, {| freq = 1, out = 0, amp = 0.99 |
	var signal, numOsc = 8, modulo, env, pan;
	modulo = LFNoise1.kr(0.1).range(0.1, 1.0);
	pan = LFNoise1.kr(1).range(-1, 1);
	signal = Klang.ar(`[ Array.rand(numOsc, 120, 1220.0), nil, nil ], 1, 0 );
	env = EnvGen.kr(Env.perc(0.1, 2.0), doneAction: 2);
	signal = {signal}!2;
	signal = signal / numOsc * amp * modulo;
	signal = LeakDC.ar(signal*env);
	Out.ar(out, Splay.ar(Pan2.ar(signal, pan, amp)))
}).add;

SynthDef.new(\sines, {
	arg freq = 66, amp = 0.99, out = 0;
	var signal, filter, env;
	var pan = LFNoise1.kr(1).range(-1, 1);
	env = EnvGen.kr(Env.perc(0.1, 2.0), doneAction: 2);
	signal = SinOsc.ar(freq: freq, phase: pi*1.0.rand, mul: env);
	signal = signal.dup * 0.5;
	Out.ar(out, Pan2.ar(signal, pan, amp));
}).add;

SynthDef(\grains, {|freq = 66, amp = 0.99, out = 0|
	var env = EnvGen.kr(Env([0, 1, 0, 1, 0], [0.5, 0.25, 0.5, 0.1]), doneAction: 2);
	var signal = LFSaw.ar(freq, 0.0, amp) * env;
	Out.ar(out, signal.dup * amp);
}).add;

SynthDef(\vos, {|freq = 66, rel = 4.0, amp = 0.99, out = 0|
	var env = EnvGen.kr(Env.sine(rel), doneAction: 2);
	var timb = LFNoise1.kr(0.3,0.5,0.5);
	var pan = LFNoise1.kr(1).range(-1, 1);
    var color = LFNoise1.kr(0.3,0.5,0.5);
	var signal = MiBraids.ar(freq, timb, color, 21) * env;
	Out.ar(out, Pan2.ar(signal, pan, amp));
}).add;

SynthDef(\scan, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0|
	var envLength = sustain*(end-begin)/speed;
    var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
    var env = Env.asr;
    var volume = IEnvGen.ar(env, line);
	var color = LFNoise1.kr(0.3,0.5,0.5);
	var model = LFNoise0.kr(1).range(0, 47);
	var timb = LFNoise1.kr(0.3,0.5,0.5);
    var signal = MiBraids.ar(freq, timb, color, model, mul: 0.2) * env;
	Out.ar(out, DirtPan.ar(signal * volume, ~dirt.numChannels, pan));
}).add;
