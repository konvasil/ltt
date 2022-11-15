const filter = new Tone.Filter().toDestination();
const pitchShift = new Tone.PitchShift(0.15).connect(filter);
const feedbackDelay = new Tone.FeedbackDelay(0.125, 0.5).connect(filter);
const distortion = new Tone.Distortion(0.25).connect(filter);
const reverb = new Tone.Reverb(0.15).connect(filter);

const synth = new Tone.Synth({
  oscillator : {
    volume: 5,
    count: 3,
    spread: 40,
    type : "sine",
    modulationType: "sawtooth",
    harmonicity: 3.4,
    partials: 8
  },
  envelope : {
    attack : 0.025
  }
});

filter.set({
  frequency: "1500",
  type: "highpass"
});

synth.connect(filter)

startAudio = function(){
  Tone.start()
  console.log("audio started")
  document.getElementById("sound-mute").innerHTML = "Sound: Started"
}

synth.connect(pitchShift);
synth.connect(feedbackDelay);
synth.connect(distortion)
synth.connect(reverb)


var updateHarmonics = function () {
  let pars = synth.oscillator.partials = new Array(8).fill(0).map(() => Math.random())
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
  midi_list = note_list.map(x => Math.round(x).toFixed(2))
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
  }, midi_list)
  pattern.start(0).loop = true;
  pattern.interval = "16n";
  Tone.Transport.bpm.value = Math.floor(Math.random() * (220 - 120 + 1) + 60)
  //console.log(Tone.Transport);
  // begin at the beginning
  Tone.Transport.start();
}*/

var triggerNote = function (note, dur, time){
  synth.triggerAttackRelease(note, dur, time);
}

var playPattern = function () {
  note_list = Object.values(msg);
  midi_list = note_list.map(x => Math.round(x).toFixed(2))
  count = 0;
  var pattern = new Tone.Pattern(function(time, note){
    now = Tone.now()
    triggerNote(note, 0.25, now);
    count = count + 1;
  }, midi_list)
  if (Tone.Transport.state === 'stopped')
  {
    Tone.Transport.start()
    pattern.start()
    console.log(Tone.Transport.state)
    Tone.Transport.bpm.value =  Math.floor(Math.random() * (220 - 160 + 1) + 60)
  } else if (Tone.Transport.state === 'started')
  {
    Tone.Transport.stop()
    pattern.stop()
    console.log(Tone.Transport.state)
  }
  pattern.humanize = "8n";
  pattern.pattern = "upDown";
}
