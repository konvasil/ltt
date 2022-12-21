const rverb = new Tone.Reverb(0.1).toDestination();
const fb = new Tone.FeedbackCombFilter(0.1, 0.6).toDestination();

var shift = new Tone.PitchShift(-12).toDestination()
shift.numberOfOutputs = 2;

var lfo = new Tone.LFO();

lfo.connect(fb.delayTime);
lfo.connect(shift.delayTime);
lfo.connect(shift.feedback);

lfo.start();

Volume = new Tone.Volume(-1)
synth = new Tone.PolySynth(Tone.Synth).chain(Volume, rverb, shift, fb,  Tone.Destination);

synth.set({
  envelope: {
    attack: 0.25
  }
})

startAudio = function(){
  Tone.start()
  console.log("audio started")
}

var trigDrone = function (notes) {
  notes = Object.values(notes).map(p => Tone.Frequency(p*10).toMidi())
  if(Tone.Transport.state == 'started')
  {
    console.log("a pattern is playing", "wait");
  } else {
    synth.triggerAttackRelease(notes, 3)
  }
}

tempoChange = function(tempo){
  Tone.Transport.bpm.value = tempo
    //Math.floor(Math.random() * (120 - 4 + 1) + 60)
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
    synth.triggerAttackRelease(note, 0.3, time)

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
