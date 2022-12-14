(
~list = [];
Tdef(\x, {
	var data;
	loop{
		0.08.wait;
		{data = ~sliders.collect(_.value)}.defer;
		if(data.notNil == true){
			~list = data;
			//~list.postln;
		}
	}
}).play;
)

(
SynthDef(\sinegrain,
	{ arg out=0, freq=440, ata=0.01, sustain=0.05, fb=0.75, vol=0.099;
		var env, pan = LFNoise1.kr(1).range(-1, 1);
		env = EnvGen.kr(Env.perc(ata, sustain*Rand(0.1, 1.0), vol), doneAction:2);
		Out.ar(out, Pan2.ar(SinOscFB.ar([freq, freq*Rand(0.1, 0.25)], fb, env).sum, pan))
}).add;

Pdef(\x, Pbind(\instrument, \sinegrain, \dur, 0.1, \fb, Pwhite(), \ata, Pwhite(0.01, 0.05), \freq, Pfunc{ Pxrand(~list.linexp(0, 1, 120.0, 1600.0), inf).asStream.next}));
Pdef(\y, Pbind(\instrument, \sinegrain, \dur, 0.2, \fb, Pwhite(), \ata, Pwhite(0.01, 0.05), \freq, Pfunc{ Pxrand(~list.linexp(0, 1, 420.0, 1220.0), inf).asStream.next}));
Pdef(\z, Pbind(\instrument, \sinegrain, \dur, 0.1, \fb, Pwhite(), \ata, Pwhite(0.01, 0.05), \freq, Pfunc{ Pxrand(~list.linexp(0, 1, 680.0, 2220.0), inf).asStream.next}));

Pdef(\drones, Pbind(\instrument, \sinegrain, \dur, 3 + rrand(0.1, 1.5), \vol, 0.03, \fb, Pwhite(), \ata, 2, \rel, Pkey(\dur, inf), \freq, Pfunc{ ~list.linexp(0, 1, 1220.0, 2220.0) }));

Pdef(\x).play(quant:(time:2, quant:2, phase:1.rand));
Pdef(\y).play(quant:(time:2, quant:2, phase:1.rand));
Pdef(\z).play(quant:(time:2, quant:2, phase:1.rand));
Pdef(\drones).play(quant:(time:2, quant:2, phase:1.rand));
)

PdefAllGui()
TdefGui(Tdef(\x))


Pdef(\x).stop;
Pdef(\x).clear

Pdef.clear




