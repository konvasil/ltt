~interface = "ltt_osc_interface_3.scd".loadRelative;
Server.default.options.outDevice_("Stream");
s.meter;s.reboot;

~play = NodeProxy.audio(s, 2);
~play = ~lick;

~play.play;


~lick[1] =  Pbind(\dur, 0.1, \instrument, \who, 'degree', Pseq([ 5.34, 6.54, 6.54, 5.34, 5.34, 6.54, 5.34, 6.54 ] /3, inf))



~lick[1] = Pbind(\dur, 0.1, \octave, 2, \instrument, \additive_klang, 'degree', Pseq([ 6.79, 5.59, 6.79, 6.79, 7.37, 5.59, 7.37, 5.59 ] / 2, inf));

~lick[2] = Pbind(\dur, 0.1, \instrument, \fm, 'degree', Pxrand([ 4.94, 6.14, 6.14, 6.14, 6.14, 6.14, 4.94, 6.14 ] / 2, inf));

~lick[1] = nil

~play[10] = {Stutter.ar(~lick.ar, 0, 0.5)}
~play[20] = {Looper.ar(~lick.ar, 1, 1, 2)}

~play[30] = \filter -> {|in| FreeVerb.ar(in, 10, 20)};
~play[40] = \filter -> {|in| PitchShift.ar(in, 0.25, 1.5, 0.4, 0.5)};
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