


export default {
  
  data() {
    return {
      title: "🐸 LICK THE TOAD 🐸",
      user_id: "",
      connected_users: 0,
      osc_config: 'undefined', //{address:"127.0.0.1", port:8081},
      osc_msg: "",
      wave_form: {sine:'sine', triangle:'triangle', sawtooth:'sawtooth', square:'square'},
      osc_incoming: "",
      synth_picked: '',
      droneNotes: 'notes',
      markovState: 'false',
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
    startAudio() {
      Tone.start();
      console.log("audio started")
    },
    osc_out () {
      if(this.markovState !== 'false'){
      var osc = Object.fromEntries(Object.entries(this.markov_notes()).map(([key, value]) => [key, value.toFixed(2)]))
      oscPort.send({
        address: '/lick',
        args: [
          this.user_id,
          JSON.stringify(osc)
        ]
      });
      this.osc_msg = osc;
      } else {
        console.log("train markov", 'first')
      }
    },
    switch_synth(synth_id) {
      synth.set({oscillator: {type: this.wave_form[synth_id]}});
      console.log(synth.options.oscillator.type)
    },
    markov_notes () {
      if(this.markovState !== 'false') {
      var notes = this.markov.generateRandom(3);
      playPattern(notes)
      this.markov_state = notes.map(n => Tone.Frequency(n, "midi").toNote());
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
      this.markov.addStates({state: msg.freq, predictions: Object.values(msg)})
      this.markov.train()
      this.markovState = 'true';
      this.markov_state = 'Trained!: ' + JSON.stringify(this.markov.getStates()[0].predictions.map(notes => Tone.Frequency(notes, 'midi').toNote()));
    },
    osc_trigger() {
      setTimeout(() => {
        this.osc_out()
      }, "750")
    },
    playDrone () {
      console.log(this.markovState)
      if(this.markovState !== 'false'){
      var notes = this.markov.generateRandom(3);
      trigDrone(notes)
      this.droneNotes = notes.map(n => Tone.Frequency(n, "midi").toNote());
      } else {
        console.log("train markov", "first");
      }
    }
  },
  created() {
    socket.on('newclientconnect', (data) => {
      this.connected_users = data.guests
    });
    oscPort.on('message', (oscMsg) => {
      if(oscMsg.args == 'osc_trigger') {
        this.osc_trigger();
      } else if (oscMsg.args == 'markov_train') {
        this.markov_train();
      } else {
        this.osc_incoming = oscMsg;
      }
    });
    //this.markov.addStates({state: msg.freq, predictions: Object.values(msg)})
  },
  updated() {
    this.user_id = socket.id
  }
}
