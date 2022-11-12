(
Ndef(\bufgrains, { |amp = 0.15, pan = 0 |
	var snd, trate, dur, rate;
	trate = LFNoise2.ar(0.5, 50, 2).abs;
	dur = 7 / trate;
	rate = Drand([-12, -7, 5, -24, -8, 11, 12, 24].midiratio, inf);
	snd = Mix(TGrains.ar(2, Impulse.ar(trate), b, 220 / rate, LFNoise2.ar(0.1,BufDur.kr(b)), dur, 0, SinOsc.ar(0.1), 2)) * amp;
});

Ndef('instruction', {Instruction.ar(b.bufnum)});

Ndef(\bufgrains).vol = 0.0001;

Ndef(\grainsPitch, {
	PitchShift.ar(
		\in1.ar([0,0]),
		\grainDur.kr(0.2, 0.3),
		\pitch.kr(2, 1),
		\pitchDisp.kr(0.2, 3),
		\timeDispv.kr(0.25, 0.4)
	)
});

Ndef(\grainsPitch).vol = 0.0001;

Ndef(\grainsDelay, {
	CombC.ar(
		\in1.ar([0,0]),
		\maxDel.kr(2, 1),
		mul:0.5
	)
});

Ndef(\grainsDelay).vol = 0.0001;


Ndef(\grainsDistort, { | smooth = 0.1, amp = 0.6 |
	var snd;
	snd = Ringz.ar(CrossoverDistortion.ar(\in1.ar([0,0]), 0.35, XLine.ar(1, 0.01, 60, doneAction:2), LFNoise2.ar(0.15) ), 660, 0.35) * amp;
	//snd = CrossoverDistortion.ar(InFeedback.ar(0), 0.35, smooth, LFNoise2.ar(0.15)) * amp
	//snd = PitchShift.ar(snd, 0.2, 1.5, 0.01, 0.05);
});

Ndef(\grainsDistort).vol = 0.0001;
Ndef('looper').clear(30)

NdefMixer(s);
)

(
~mainFX = MainFX.new(server: s,
    numChannels: 1,
    slotNames: [\dcdrs, \leakDC],
    busIndex: ~bus
);

ProxyChain.add3(\dcdrs,  \filter -> { |in, vol = 1.0| in * vol },
	1,
	(\vol:[0.1, 0.999, \lin])
);

ProxyChain.add3(
    \leakDC,  \filter -> { |in, leak=0.99| LeakDC.ar(in, leak) },
    1,
    (\leak: [0.5, 0.999, \exp])
);


g = ~mainFX.gui;
)

MainFX.clear('localhost')