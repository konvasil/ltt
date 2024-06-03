~interface = "ltt_osc_interface_Tidal.scd".loadRelative;
Server.default.options.outDevice_("Stream");
s.reboot;
~synths = "Synthdefs.scd".loadRelative;
~play = NodeProxy.audio(s, 2);
~play = ~lick;
~play.play;

(
Pdef(\a, Pbind(\dur, 2.5, \instrument, \vos, \amp, Pwhite(0.1, 0.99), 'midinote', Pseq([ 6.61, 7.13, 5.41, 7.13, 7.13, 6.61, 6.61, 7.13 ], inf)));

Pdef(\b, Pbind(\dur, 0.22, \instrument, \scan, \amp, Pwhite(0.1, 0.99), 'midinote', Pseq([ 6.61, 7.13, 5.41, 7.13, 7.13, 6.61, 6.61, 7.13 ], inf)));

Pdef(\c, Pbind(\dur, 0.2, \instrument, \klang, \amp, Pwhite(0.1, 0.99), 'midinote', Pxrand([ 6.61, 7.13, 5.41, 7.13, 7.13, 6.61, 6.61, 7.13 ], inf)));

Psym(
    Prewrite(\a, // start with pattern \a
        (
            \a: #[\a, \b],
            \b: #[\c, \a],
            \c: #[\a, \b]
    ), 4).trace
).play
)


~play[10] = {Stutter.ar(~lick.ar, 0, 0.5)}
~play[20] = {HPF.ar(~lick.ar, 200)}

~r = {54};

(
~lick[4] = {arg mult = 1; DFM1.ar(SawDPW.ar([~r,~r*1.1]*mult,0,0.1),(~r*2)*mult,SinOsc.kr(0.05).range(0.9,1.1),1,0,0.0003,0.5)};
~lick[5] = {arg mult = 2; DFM1.ar(SawDPW.ar([~r,~r*1.1]*mult,0,0.1),(~r*2)*mult,SinOsc.kr(0.06).range(0.9,1.1),1,0,0.0003,0.5)};
~lick[6] = {arg mult = 3; DFM1.ar(SinOsc.ar([~r,~r*1.1]*mult,0,0.1),(~r*2)*mult,SinOsc.kr(0.056).range(0.9,1.1),1,0,0.0003,0.5)};
~lick[7] = {arg mult = 4; DFM1.ar(SinOsc.ar([~r,~r*1.1]*mult,0,0.1),(~r*2)*mult,SinOsc.kr(0.07).range(0.9,1.1),1,0,0.0003,0.5)};
)

~play[30] = \filter -> {|in| FreeVerb.ar(in, 10, 20)};
~play[40] = \filter -> {|in| PitchShift.ar(in, 0.25, 10.5, 1.4, 1.5)};
~play[70] = \filter -> {|in| HPF.ar(in, 200)};
~play[50] = \filter -> {|in| Splay.ar(Ringz.ar(in* 0.2, {ExpRand(120.0, 1220.0)}!8, 1.0.rand.max(0.01), 0.2, 0.01))};

~play.clear(8);


n = NetAddr("localhost", 57122);
n.sendMsg('/kv', "markov_train");
n.sendMsg('/kv', "osc_markov_trigger");















(
var clutch, pat, decision;
decision = Pseq([Pn(true,10), Prand([true, false], 10)], inf).asStream;
clutch = StreamClutch(~lick[1], decision);
clutch.asEventStreamPlayer.play;
)