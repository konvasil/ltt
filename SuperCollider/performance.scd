~interface = "ltt_osc_interface_3.scd".loadRelative;
Server.default.options.outDevice_("Stream");
s.reboot
~synths = "Synthdefs.scd".loadRelative;
~play = NodeProxy.audio(s, 2);
~play = ~lick;
~play.play;

~lick[1] = Pbind(\dur, 4, \instrument, \vos, 'midinote', Pxrand([ 6.61, 7.13, 5.41, 7.13, 7.13, 6.61, 6.61, 7.13 ], inf));

~lick[2] = Pbind(\dur, 0.5, \instrument, \scan, 'midinote', Pxrand([ 6.61, 7.13, 5.41, 7.13, 7.13, 6.61, 6.61, 7.13 ], inf));

~play[10] = {Stutter.ar(~lick.ar, 0, 0.5)}

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