Tone.Transport.bpm.value = 10;
const rverb = new Tone.JCReverb(0.1).toDestination();
var shift = new Tone.PitchShift(12).toDestination();
var filter = new Tone.Filter(200, "highpass");
shift.feedback = 0.1;

Volume = new Tone.Volume(-24)

/*var ampEnv = new Tone.AmplitudeEnvelope({
	"attack": 0.3,
	"decay": 0.8,
	"sustain": 0.85,
	"release": 0.25
}).toMaster();*/

synth = new Tone.PolySynth(Tone.AMSynth).chain(Volume, shift, filter, rverb, Tone.Destination);

var trigDrone = function (notes) {
  notes = Object.values(notes).map(p => Tone.Frequency(p, "midi").toMidi())
  if(Tone.Transport.state == 'started')
  {
    console.log("a pattern is playing", "wait");
  } else {
    synth.triggerAttackRelease(notes, 3);
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
  console.log(`midi: ${midi_list}`)

  count = 0;

  seqIsPlaying = 'playing'

  const seq = new Tone.Sequence((time, note) => {
    const now = Tone.now()
    synth.triggerAttackRelease(note, "2n", now + 1.0);
    console.log(note);
    //ampEnv.triggerAttackRelease("8t");
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
