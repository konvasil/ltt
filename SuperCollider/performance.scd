~interface = "ltt_osc_interface_3.scd".loadRelative;

(
// must have 'out' or 'i_out' argument to work properly
SynthDef("who", { arg freq, gate=1, out=0, ffreq=800, amp=0.1;
    var env;
    env = Env.asr(0.01, amp, 0.5);
    Out.ar(out, Pan2.ar(
        Formant.ar(freq, ffreq, 300, EnvGen.kr(env, gate, doneAction: Done.freeSelf)), Rand(-1.0, 1.0))
    )
}).add;

SynthDef(\sinegrain, { arg out=0, freq=440, sustain=0.05, amp=0.1;
	var env;
	env = EnvGen.kr(Env.perc(0.01, sustain, amp, 0.1), doneAction:2);
	Out.ar(out, Splay.ar(SinOsc.ar([freq, freq * 0.5], 0, env)))
}).add;
)

~nodes.play;



~nodes.source = { ~licks.ar * SinOsc.ar(SinOsc.kr(8, 300, 330)) }
~nodes.source = { ~licks.ar * Pan2.ar(LFCub.ar([2, 4], add: -0.5), pan: LFNoise1.kr(0.1).range(-1, 1)) };

~nodes[1] = \filterIn -> {|in| FreeVerb.ar(in, 10)};
~nodes[2] = \filterIn -> {|in| CombC.ar(in, 0.03, 0.02, add:in)};
~nodes[3] = \filterIn -> {|in| MoogLadder.ar(in, ExpRand(120.0, 1220.0), 0.0, 0.5)}

n=NetAddr("localhost", 57122);
n.sendMsg('/kv', "markov_train");
n.sendMsg('/kv', "osc_trigger");

(
Pbindf(~licks[0], \sustain, Pseq((0.1..1.0), inf), \instrument, 'who').play;
Pbindf(~licks[0], \detune, Prand((0.1..1.0), inf), \instrument, 'who').play;
)

~pat = Pbind(\instrument, 'who', \detune, Pseq((0.1..1.0), inf));

~playPat = Pbind(\detune, Pxrand([-30, 0, [0, 40]], inf), \dur, 0.1);

~chainPat = ~playPat <> ~licks.source;
~chainPat.stop;

~funcDict[\lickseq].value(\rep, 1);
~funcDict[\lickrand].value((120..140), 1)

~chainPat.play;
~nodes.gui;

~nodes.stop(3);