// =====================================================================
// SuperCollider Workspace
// =====================================================================

(
SynthDef(\additive_klang, {| freq = 1, out = 0, amp = 0.5 |
	var signal, numOsc = 8, modulo;
	modulo = LFNoise1.kr(0.1).range(0.1, 1.0);
	signal = Klang.ar(`[ Array.rand(numOsc, 120, 1220.0), nil, nil ], 1, 0 );
	signal = {signal}!2;
	signal = signal / numOsc * amp * modulo;
	signal = LeakDC.ar(signal);
	ReplaceOut.ar(out, Splay.ar(signal))
}).add;

SynthDef.new(\sines, {
	arg freq = 120.0, amp = 0.5, out = 0;
	var signal, filter, env;
	env = EnvGen.kr(Env.perc(0.1, 2.0), doneAction: 2);
	signal = SinOsc.ar(freq: freq, phase: pi*1.0.rand, mul: env);
	signal = signal * 0.5;
	Out.ar(out, signal);
}).add;
)
