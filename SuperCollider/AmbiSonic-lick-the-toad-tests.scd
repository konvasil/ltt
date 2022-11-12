
//Stream Settings
(
s.options.outDevice_("JackBridge");
s.options.numInputBusChannels_(1);
s.options.numOutputBusChannels_(2);
s.reboot;
MasterEQ(2, s);
s.meter;
)

//Writing incoming data to buffer
(
b = Buffer.alloc(s, s.sampleRate / Server.default.options.blockSize*2);
~bus = Bus.audio(s, 1);

BuffPlot(b);

// add recording to Ndef
Ndef(\rec, {RecordBuf.kr( \freq.kr(0.0, 0.3), b)});
Ndef(\rec).gui;

//add custom rangspecs
Spec.add(\freq, [-1, 1.0]);
Spec.add(\recRate, [0.1, 10]);
Spec.add(\recScale, [0.1, 1]);
Spec.add(\rate, [0.1, 1]);
)

//MasterFX.clear('localhost');

// SynthDefs
(
~order = 3; // set this to the order you want
~numChannels = ((~order + 1)**2).asInteger;

// binaural decoder (~numChannels -> 2) - reads from 'bus' and sums into 'out'
SynthDef.new(\binauralDecoder, {arg bus, out = 0;
    Out.ar(out, VSTPlugin.ar(In.ar(bus, ~numChannels), 2));
}).add;

// stereo encoder (2 -> ~numChannels) - replaces stereo signal with ambisonics signal
SynthDef.new(\stereoEncoder, {arg bus = 0;
    ReplaceOut.ar(bus, VSTPlugin.ar(In.ar(bus, 2), ~numChannels));
}).add;

// ambisonics insert FX (replaces input with output)
SynthDef.new(\ambiFX, {arg bus = 0, bypass;
    ReplaceOut.ar(bus, VSTPlugin.ar(In.ar(bus, 2), ~numChannels, bypass));
}).add;

// helper Synth (throws audio from ambi bus to ambi master bus)
SynthDef.new(\ambiThrow, {arg from, to;
    Out.ar(to, In.ar(from, ~numChannels));
}).add;

// load sound file (replace with your test sound file)
//~buf = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

SynthDef(\readBus, {arg out = 0, in, vol = 1.0;
      var sig = In.ar(in, 1);
      Out.ar(out, sig * vol);
}).add;

// play a sound file (in different rates)
SynthDef(\looper, { arg out = 0, in, vol = 1.0, rate = 1;

	var phasor, sig;

	phasor = Phasor.ar(0, BufRateScale.kr(b) * rate);

		sig = Mix.ar(
		LFSaw.ar(BufRd.ar(1, b, phasor, 0, BufFrames.kr(b)), 0, vol),
			Instruction.ar(b.bufnum)
		);

		n = 4;

		Out.ar(out,
			Ringz.ar(
				Looper.ar(
					sig,
					2,
					LFNoise0.kr(1).range(0.1, 1.75),
					\recRate.kr(1, 9),
					\recScale.kr(1, 9)
				),
				freq: {ExpRand(120, 1220.0)}!n,
			decaytime: 0.35.rand2
		).sum / n
	)
}).add;

// search for plugins
VSTPlugin.search(verbose: false);
)

// create ambisonic master section
(
{
    // bus + group
    ~ambiMasterBus = Bus.audio(s, ~numChannels);
    ~ambiMasterGroup = Group.new;
    s.sync;
    // binaural decoder (writes to master output)
    ~decoder = VSTPluginController(Synth(\binauralDecoder, [\bus, ~ambiMasterBus, \out, 0],
        target: ~ambiMasterGroup, addAction: \addToTail)).open("BinauralDecoder");
    s.sync;
    // a group for ambisonic master effects
    ~ambiMasterFXGroup = Group.before(~decoder.synth);
}.fork;
)

// create ambisonic busses
(
// N ambisonic busses (3rd order) with stereo encoder. add ambi groups *before* master group!
~numBus = 4; // change this if you want
~ambiBus = Array.newClear(~numBus);
~ambiGroup = Array.newClear(~numBus);
~encoder = Array.newClear(~numBus);
~numBus.do { arg i;
    {
        ~ambiBus[i] = Bus.audio(s, ~numChannels);
        ~ambiGroup[i] = Group.before(~ambiMasterGroup);
        s.sync;
        // sound source (head)
        //~loopSynth = Synth.new(\looper, [\out, ~ambiBus[i], \vol, 1.0 / ~numBus], ~ambiGroup[i], addAction: \addToHead);

		Synth(\readBus, [\in, ~bus.index, \out, ~ambiBus[i], \vol, 1.0 / ~numBus], ~ambiGroup[i], addAction: \addToHead);

        // encoder (after sound source)
        ~encoder[i] = VSTPluginController(Synth(\stereoEncoder, [\bus, ~ambiBus[i], \out, ~ambiMasterBus],
            target: ~ambiGroup[i], addAction: \addToTail));
        // open plugin and randomize azimuth
        ~encoder[i].open("StereoEncoder", action: { arg self; self.set(6, rand(1.0)) }); // 6 -> azimuth

        // throw to master section (after encoder)
        Synth(\ambiThrow, [\from, ~ambiBus[i], \to, ~ambiMasterBus], target: ~ambiGroup[i], addAction: \addToTail);

        // you can add more sound sources to the head of the group, stereo FX *before* the encoder and ambi FX *after* the encoder:
        // sound source, [sound source] ..., [stereo FX], [stereo FX], ..., ENCODER, [ambi FX], [ambi FX], ..., THROW
    }.fork;
}
)

s.queryAllNodes;
s.scope
// randomize source positions
~encoder.do(_.set(6, rand(1.0))) // 6 -> azimuth

// move around manually with the GUI:
~encoder.do(_.gui);

// modulate azimuth values with random LFOs:
(
~lfoGroup = Group.new;
~lfoBus = { Bus.control } ! ~numBus;
~lfo = { arg i; { arg rate = 0.5; LFNoise1.kr(rate, 0.5, 0.5) }.play(~lfoGroup, ~lfoBus[i]) } ! ~numBus;
~encoder.do { arg enc, i; enc.map(6, ~lfoBus[i]) }; // map azimuth parameter (nr. 6) to control bus
)

~lfoGroup.set(\rate, exprand(0.1, 4.0));  // change LFO rates
~encoder.do(_.unmap(6)); // unmap

// add an ambisonic master FX
(
~ambiReverb = VSTPluginController(Synth(\ambiFX, [\bus, ~ambiMasterBus, \out, 0],
    target: ~ambiMasterFXGroup)).open("FdnReverb");
)

~ambiReverb.set(0, rand(1.0)); // vary room size
~ambiReverb.set(1, rand(1.0)); // vary reverb time
// bypass it:
~ambiReverb.synth.set(\bypass, 1); // bypass
~ambiReverb.synth.set(\bypass, 0); // process

//Start OSC Control inputs
(
OSCdef(\rgrsn, {|msg|
	msg.postln;
	//Ndef(\rec).set(\freq, \freq.asSpec.map(msg[1] / 1000));
}, '/neural/net/regression');

OSCdef(\crsX, {|msg|
	msg.postln;
	//~loopSynth.set(\recRate, \recRate.asSpec.map(msg[1].round(0.01) / 1000));
	//~loopSynth.set(\rate, \rate.asSpec.map(msg[1].round(0.01) / 1000));
	//Ndef(\inst).set(\resFreq, \resFreq.asSpec.map(msg[1].round(1.0)/ 1000));
}, '/neural/net/cursor/x');

OSCdef(\crsY, {|msg|
	msg.postln;
	//~loopSynth.set(\recScale, \recScale.asSpec.map(msg[1].round(0.01) / 1000));
	//Ndef(\inst).set(\bwr, \bwr.asSpec.map(msg[1].round(0.01) / 1000))
}, '/neural/net/cursor/y');
)

n = NetAddr("127.0.0.1", 57121); //Sending to NodeJS OSC Port

n.sendMsg("/message", "hello NodeJS, SC here!"); //trigger a message like this.

// Recording
(
// When recording ambisonics, we usually don't want the decoded output.
// Instead, we want the signal while it's still in the ambisonic domain
// (so that we can use it with any kind of decoder in the future), i.e. just before the decoder.
var path = "~/Music/ambisonic-piece-%_o%_%chan.wav".format(Date.getDate.stamp, ~order, ~numChannels).standardizePath;
r = Recorder(s);
// Put the recorder after the master FX group (before the decoder)
r.record(path, ~ambiMasterBus, ~numChannels, ~ambiMasterFXGroup);
)
r.stopRecording;