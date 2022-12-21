(
~list = [];
Tdef(\x, {
	var data;
	loop{
		0.15.wait;
		{data = ~sliders.collect(_.value)}.defer;
		if(data.notNil == true){
			~list = data;
			//Ndef(\rec).set(\freq, p.next.postln);
		}
	}
}).play;
)

b = Buffer.alloc(s,300);
b = Buffer.alloc(s, s.sampleRate / Server.default.options.blockSize*2);

Spec.add(\freq, [0.001, 1.0]);

Tdef(\x,
	{
		loop{
			4.wait;

		}
}).play;


~recbuf = Ndef(\rec, {RecordBuf.kr( \freq.kr(10, 0.3), b.bufnum)});
~recbuf[1] = \xset -> Pbind(\dur, 0.1, \freq, Pfunc{Pseq(~list.linlin(0, 1, 0.01, 1.0), inf).asStream.next});

~s = Ndef(\sieve, { Sieve1.ar(b.bufnum, \gap.kr(100), 0).dup*0.08}).play;

~inst = Ndef(\inst, {Pan2.ar(0.5*FreeVerb.ar(Resonz.ar(Instruction.ar(b.bufnum), \resFreq.kr(1000, 0.6), \bwr.kr(0.1, 0.6))))});
~s.fadeTime = 0.03;
~s[1] = \xset -> Pbind(\dur, 0.1, \gap, Pfunc{Pxrand(~list.linexp(0, 1, 2, 10), inf).asStream.next});

~s[2] = \filter -> {|in| PitchShift.ar(in, 0.2, 1.5, 0.25, 0.25)}
~s[3] = \filter -> {|in| GVerb.ar(in, add: in)* 0.35}

Ndef(\sieve).stop(20)
NdefMixer(s)