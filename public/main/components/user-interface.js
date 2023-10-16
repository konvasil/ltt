export default {
  
  data() {
    return {
      title: "LICK THE TOAD",
      user_id: "",
      connected_users: undefined,
      tempo: undefined,
      oscPort: new osc.WebSocketPort({url: "ws://localhost:8081"}),
      osc_config: 'undefined', //{address:"127.0.0.1", port:8081},
      osc_msg: "",
      pattSync: "Pattern Play",
      synth_picked: undefined,
      disclaimer: "Best uses: modern web browsers on iPhone iOS and Android and typewriters for the best experience, mind device’s volume and use AYOR",
      osc_incoming: "",
      droneNotes: 'notes',
      markovState: 'false',
      isHidden: true,
      markov: new Markov('numeric'),
      markov_state: 'untrained',
      form: {
        ip: "127.0.0.1",
        port: 57120 //or undfined
      }
    }
  },
  methods: {
    showID()  {
      return this.user_id = socket.id
    },
    submit(address, port) {
      this.form.ip = address;
      this.form.port = port;
      this.osc_config = {address: this.form.ip, port: this.form.port};
      console.log('Submitted: ', this.form);
    },
    checkPatternIsPlaying() {
      if(seqIsPlaying == 'false') {
        this.pattSync = `I can play this pattern: ${this.markov_notes()}`
        console.log('playing')
      } else if(seqIsPlaying == 'playing') {
        this.pattSync = "a pattern is already playing, rejected, try after finishes!";
      }
    },
    submit(address, port) {
      this.form.ip = address;
      this.form.port = port;
      this.osc_config = {address: this.form.ip, port: this.form.port};
      console.log('Submitted: ', this.form);
    },
    osc_out () {
      if(seqIsPlaying == 'false') {
        this.pattSync = "Pattern is playing and OSC sent."
        if(this.markovState !== 'false') {
          var oscNotes = Object.fromEntries(Object.entries(this.markov_notes()).map(([key, value]) => [key, value.toFixed(2)]));
          this.oscPort.send({
            address: '/lick',
            args: [
              {
                type: "s",
                value: this.user_id
              },
              {
                type: "s",
                value: JSON.stringify(oscNotes, null, 4)
              }
            ]
          });
          this.osc_msg = Object.values(oscNotes)
        } else {
          console.log("train markov", 'first')
        }
      } else if(seqIsPlaying == 'playing') {
        this.pattSync = "patience, another pattern is playing!"
      }
    },
    switch_synth(synth_id) {
      synth.set({oscillator: {type: synth_id}});
      console.log(synth.options.oscillator.type);
    },
    markov_notes () {
      if(this.markovState !== 'false') {
        var notes = this.markov.generateRandom(8);
        playPattern(notes)
        this.markov_state = notes.map(n => Tone.Frequency(n / 10.0, "midi").toNote());
        return notes
      } else {
        console.log("train markov", "first");
      }
    },
    markov_states(v) {
      if(this.markovState != 'false') {
        this.markovState = true;
        console.log("markov trained", this.markovState)
      } else {
        this.markovState = false;
      };
      return v
    },
    markov_train() {
      this.markov_state = 'waiting new predictions'
      this.markov.clearChain();
      if(Number(prediction.freq) !== NaN){
      setTimeout(() => {
        this.markov.addStates({state: prediction.freq, predictions: [prediction.unNormalizedValue * 1000.00, prediction.value / 2]});
        this.markov.train();
        this.markovState = 'true'
        this.markov_state = JSON.stringify(this.markov.getStates())
      }, "750")
      } else {
        this.osc_msg = "First Train";
      }
    },
    osc_trigger() {
      setTimeout(() => {
        this.osc_out()
      }, "750")
    },
    playDrone () {
      console.log(this.markovState)
      if(this.markovState !== 'false'){
        var notes = this.markov.generateRandom(2);
        trigDrone(notes)
        this.droneNotes = notes.map(n => Tone.Frequency(n / 10.0, "midi").toNote());
      } else {
        console.log("train markov", "first")
      }
    },
    setTempo(tempo) {
      var limitTempo = limitNumberWithinRange(tempo)
      Tone.Transport.bpm.rampTo(limitTempo, 0.1)
      this.tempo = limitTempo //80min - 200max
    }
  },
  created() {
    this.oscPort.open();
    //this.markov_train();

    socket.on('newclientconnect', (data) => {
      if(data.guests !== NaN){
      this.connected_users = data.guests
        this.setTempo(Tone.Transport.bpm.value + data.guests)
      }
    });

    this.oscPort.on('message', (oscMsg) => {
      if(oscMsg.args == 'osc_trigger') {
        this.osc_trigger();
      } else if (oscMsg.args == 'markov_train') {
        this.markov_train();
      } else {
        this.osc_incoming = oscMsg;
      }
    });
  },
  mounted(){
    this.synth_picked = "Sine"
    this.switch_synth('sine')
  },
  updated() {
    this.user_id = socket.id
  }
}
