const filter = new Tone.Filter().toDestination();
const pitchShift = new Tone.PitchShift(1.75).connect(filter);
//const feedbackDelay = new Tone.FeedbackDelay(0.125, 0.5).connect(filter);
const distortion = new Tone.Distortion(0.25).connect(filter);
const reverb = new Tone.Reverb(0.35).connect(filter);

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
    attack : 0.3
  }
}).connect(filter);

filter.set({
  frequency: "C6",
  type: "highpass"
});


startAudio = function(){
  Tone.start()
  console.log("audio started")
  document.getElementById("sound-mute").innerHTML = "Sound: Started"
}

synth.connect(pitchShift);
//synth.connect(feedbackDelay);
synth.connect(distortion)
synth.connect(reverb)

var updateHarmonics = function () {
  let pars = synth.oscillator.partials = new Array(8).fill(0).map(() => Math.random())
  for(var i = 0; i < pars.length; i++){
    console.log(synth.oscillator.phase = (pars[i] * Math.floor(Math.random() * (Math.PI - 0.1 + 0.25) + 0.1)))
  }
  document.getElementById("update-harmx").innerHTML = "Harmonics: " + pars.map((p) => parseFloat(p).toFixed(2), undefined, 2) //round function in decimals
}

var playDrone = function () {
  const now = Tone.now()
  synth.triggerAttackRelease(parseFloat(msg.freq.toFixed(2)), 3, now)
}

const now = Tone.now()
const pat = new Tone.Loop(time => {
  synth.triggerAttackRelease(msg.freq, now, time);
}, "4n")

var playPattern = function () {
  if (Tone.Transport.state == 'stopped')
  {
    Tone.Transport.start()
    pat.start(0)
    Tone.Transport.bpm.value = Math.floor(Math.random() * (220 - 120 + 1) + 60)
  } else if (Tone.Transport.state == 'started')
  {
    Tone.Transport.stop(0)
    pat.stop(0)
  }
}
