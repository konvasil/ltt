const reverbMaster = new Tone.Reverb(0.15).toDestination()
const pitchShift = new Tone.PitchShift(40, 0.25, 0.7, 120).connect(reverbMaster)
//const filter = new Tone.Filter().connect(reverbMaster);
const feedbackDelay = new Tone.FeedbackDelay(0.9, 0.9).connect(pitchShift);
const distortion = new Tone.Distortion(0.25).connect(reverbMaster);
const fb = new Tone.FeedbackCombFilter(0.1, 0.5).connect(pitchShift);

pitchShift.numberOfOutputs = 2;

const synth = new Tone.AMSynth({
  oscillator : {
    volume: 5,
    count: 3,
    spread: 40,
    type : "sine",
    modulationType: "sawtooth",
    harmonicity: 3.4,
    partials: 4
  },
  envelope : {
    attack : 0.1,
    release : 0.75
  }
})

/*filter.set({
  frequency: "1500",
  type: "highpass"
});*/

//synth.connect(filter)

startAudio = function(){
  Tone.start()
  console.log("audio started")
  document.getElementById("sound-mute").innerHTML = "Sound: Started"
}

synth.connect(pitchShift);
synth.connect(feedbackDelay);
synth.connect(distortion)
synth.connect(fb)
synth.connect(reverbMaster)

var updateHarmonics = function () {
  let pars = synth.oscillator.partials = new Array(4).fill(0).map(() => Math.random())
  for(var i = 0; i < pars.length; i++){
    synth.oscillator.phase = (pars[i] * Math.floor(Math.random() * (Math.PI - 0.1 + 0.25) + 0.1))
  }
  document.getElementById("update-harmx").innerHTML = "Harmonics: " + pars.map((p) => p.toFixed(2), undefined, 2) //round function in decimals
}

var playDrone = function () {
  const now = Tone.now()
  if(Tone.Transport.state == 'started')
  {
    console.log("a pattern is playing", "wait");
  } else {
    synth.triggerAttackRelease(parseFloat(msg.freq.toFixed(2)), 3, now)
  }
}

/*var playPattern = function (note_list) {
  note_list = Object.values(msg);
  midi_list = note_list.map(x => Math.round(x).toFixed(2));
  last_note = midi_list.length;
  count = 0;
  const now = Tone.now()
  var pattern = new Tone.Pattern(function(time, note){
    triggerNote(note, 0.25, now);
    count = count + 1;
    if (count === last_note) {
      pattern.stop();
      Tone.Transport.stop();
      console.log("finished!", midi_list);
    }
  }, midi_list);
  pattern.start(0).loop = true;
  pattern.interval = "16n";
  Tone.Transport.bpm.value = Math.floor(Math.random() * (220 - 120 + 1) + 60)
  //console.log(Tone.Transport);
  // begin at the beginning
  Tone.Transport.start();
}*/

tempoChange = function(tempo){
  Tone.Transport.bpm.value = tempo
    //Math.floor(Math.random() * (120 - 4 + 1) + 60)
}

triggerNote = function(note, dur) {
  var now = Tone.now();
  synth.triggerAttackRelease(note, dur, now)
}

function playPattern (note_list, hidePlay, id, sound) {

  note_list = Object.values(msg)
  
  midi_list = note_list.map(notes => Math.abs(Tone.Frequency(notes).toMidi()));
  document.getElementById("play-pat").innerHTML = "notes: " + JSON.stringify(midi_list);
  last_note = midi_list.length;
  count = 0;

  var pattern = new Tone.Sequence(function(time, note) {

    triggerNote(note, 0.25);
    count = count + 1;

    if (count === last_note) {
      console.log("finished!");
      pattern.stop();
      Tone.Transport.stop();
    }

  }, midi_list);

  pattern.start(0).loop = false;

  console.log(midi_list);
  Tone.Transport.start();
}
