//const reverbMaster = new Tone.Reverb(0.15).toDestination()
//const pitchShift = new Tone.PitchShift(4, 0.25, 0.7, 12).toDestination();
//const filter = new Tone.Filter().toDestination();
//const feedbackDelay = new Tone.FeedbackDelay(Math.random(), 0.5).toDestination()
//const distortion = new Tone.Distortion(0.25).connect(reverbMaster);
//const fb = new Tone.FeedbackCombFilter(0.1, 0.5).connect(pitchShift);
//pitchShift.numberOfOutputs = 2;

/*const voices = {
  synth_fm: ,
  synth_am: 'amsynth'
}
*/

//const synth = new Tone.PolySynth(Tone.FMSynth,  12).toDestination();


Volume = new Tone.Volume(-12)
synth = new Tone.PolySynth(Tone.Synth).chain(Volume, Tone.Destination);

synth.set({
  envelope: {
    attack: 0.099,
    decay: 1,
    release: 0.25
  }
});

/*Tone.Synth({
    oscillator : {
      volume: 5,
      count: 3,
      spread: 40,
      type : "sine",
      modulationType: "sawtooth",
      harmonicity: Math.floor(Math.random() * 2) + 10,
      partials: 4
    },
    envelope : {
      attack : 0.1
    }
  })*/

/*filter.set({
  frequency: "1500",
  type: "highpass"
});*/

//synth.connect(filter)

startAudio = function(){
  Tone.start()
  console.log("audio started")
}


//synth.connect(pitchShift);
//synth.connect(feedbackDelay);
//synth.connect(distortion)
//synth.connect(fb)
//synth.connect(reverbMaster)
//synth.connect(filter)

var updateHarmonics = function () {
  array = new Array(3).fill(0).map(() => Math.random());

  let pars = synth.options.oscillator.partials = array;
  
  for(var i = 0; i < pars.length; i++){
    synth.phase = (pars[i] * Math.floor(Math.random() * (Math.PI - 0.1 + 0.25) + 0.1))
  }
  document.getElementById("update-harmx").innerHTML = "Harmonics: " + pars.map((p) => p.toFixed(2), undefined, 2) //round function in decimals
}

var playDrone = function () {
  notes = Object.values(msg).map(p => Tone.Frequency(p).toMidi())
  if(Tone.Transport.state == 'started')
  {
    console.log("a pattern is playing", "wait");
  } else {
    synth.triggerAttackRelease(notes, 3);
    document.getElementById("pause-play").innerHTML = "Drone: " + Tone.Frequency(msg.freq, "midi").toNote();
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


function playPattern (notes) {
  let note_list = notes //genMarkov() //Object.values(msg)
  let midi_list = note_list.map(notes => Math.abs(Tone.Frequency(notes, "midi").toMidi()));
  let last_note = midi_list.length;
  count = 0;

  const seq = new Tone.Sequence((time, note) => {
    synth.triggerAttackRelease(note, 0.3, time)

    count = count + 1;

    if (count === last_note) {
      console.log("finished!");
      seq.stop(0);
      Tone.Transport.stop();
      try {
      } finally {
        console.log(synth.releaseAll(), 'synth released')
      }
    }

  }, midi_list).start(0);

  console.log(midi_list);
  Tone.Transport.start();
}
