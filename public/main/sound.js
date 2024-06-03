
const rverb = new Tone.JCReverb(0.75).toDestination();
const filter = new Tone.Filter(120, "highpass").toDestination();

Volume = new Tone.Volume(-12);

const panner = new Tone.Panner(1).toDestination();
panner.pan.rampTo(-1, 0.5);

var ampEnv = new Tone.AmplitudeEnvelope({
	"attack": 0.3,
	"decay": 0.8,
	"sustain": 0.85,
	"release": 0.25
}).toDestination();

synth = new Tone.PolySynth(Tone.FMSynth).toDestination();
synth.chain(Volume, rverb, filter, ampEnv, Tone.Master);
synth.connect(panner);
synth.polyphony = 8;

synth.set({
  "envelope" : {
    attack: 0.03,
    decay: 0.5,
    sustain: 1,
    release: 1,
  }
});

var trigDrone = function (notes) {
  notes = Object.values(notes).map(p => Tone.Frequency(p, "midi").toMidi())
  if(Tone.Transport.state == 'started')
  {
    console.log("a pattern is playing", "wait");
  } else {
    synth.triggerAttackRelease(notes, 1)
    synth.volume.value -24
   // ampEnv.triggerAttackRelease("8t");

  }
}

function limitNumberWithinRange(num, tempoMin, tempoMax){
  const MIN = tempoMin || 10
  const MAX = tempoMax || 200
  const parsed = parseInt(num)
  return Math.min(Math.max(parsed, MIN), MAX)
}

let seqIsPlaying = 'false'

function playPattern (notes) {
  notes = notes.map(notes => Math.abs(notes / 127 * 17.32)); //MIDI range vals
  let midi_list = notes.map((n) => Tone.Frequency(n, "midi").toNote() ) //Notes.map(notes => Math.abs(Tone.Frequency(notes, "midi").toMidi() ));
  let last_note = midi_list.length;
  console.log(`midi: ${midi_list}`);

  count = 0;

  seqIsPlaying = 'playing'

  const seq = new Tone.Sequence((time, note) => {
    synth.triggerAttackRelease(note, "18n", '+0.05');
    console.log(note);
    count = count + 1;
    if (count === last_note) {
      seq.stop();
      Tone.Transport.stop();
      seqIsPlaying = 'false'
      console.log("finished!", `Pattern is playing: ${seqIsPlaying}`);
    }
  }, midi_list).start(0)

  Tone.Transport.start("+0.1")

  return midi_list


}
