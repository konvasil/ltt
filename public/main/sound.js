const rverb = new Tone.Reverb(0.1).toDestination();
const pan = new Tone.AutoPanner().toDestination();
Tone.Transport.bpm.value = 40;
var shift = new Tone.PitchShift(12).toDestination();
var filter = new Tone.Filter(200, "highpass");
shift.feedback = 0.5;

var lfo = new Tone.LFO();

lfo.start();

Volume = new Tone.Volume(0)
synth = new Tone.PolySynth(Tone.MonoSynth).chain(Volume, rverb, shift, filter, pan, Tone.Destination);

synth.set({
  envelope: {
    attack: 0.05,
    release: 3.0
  }
})

startAudio = function(){
  Tone.start()
  console.log("audio started")
}

var trigDrone = function (notes) {
  notes = Object.values(notes).map(p => Tone.Frequency(p, "midi").toMidi())
  if(Tone.Transport.state == 'started')
  {
    console.log("a pattern is playing", "wait");
  } else {
    synth.triggerAttackRelease(notes, 3)
  }
}

function limitNumberWithinRange(num, tempoMin, tempoMax){
  const MIN = tempoMin || 80
  const MAX = tempoMax || 200
  const parsed = parseInt(num)
  return Math.min(Math.max(parsed, MIN), MAX)
}

let seqIsPlaying = 'false'

function playPattern (notes) {
  let note_list = notes

  lfo.set({frequency: notes[0]/1000.0, min:notes[1]/1000.0, max:notes[2]/1000.0});

  let midi_list = note_list.map(notes => Math.abs(Tone.Frequency(notes, "midi").toMidi() ));
  let last_note = midi_list.length;

  count = 0;

  seqIsPlaying = 'playing'

  const seq = new Tone.Sequence((time, note) => {
    synth.triggerAttackRelease(note, 2.8, time)

    count = count + 1;

    if (count === last_note) {
      seq.stop();
      Tone.Transport.stop();
      seqIsPlaying = 'false'
      console.log("finished!", `Pattern is playing: ${seqIsPlaying}`);
    }
  }, midi_list).start(0)

  Tone.Transport.start()
}
