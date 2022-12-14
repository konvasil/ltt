


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
    osc_out () {
      var osc = Object.fromEntries(Object.entries(this.markov_notes()).map(([key, value]) => [key, value.toFixed(2)]))
      oscPort.send({
        address: '/lick',
        args: [
          this.user_id,
          JSON.stringify(osc)
        ]
      });
      this.osc_msg = osc;
    },
    switch_synth(synth_id) {
      synth.set({oscillator: {type: this.wave_form[synth_id]}});
      console.log(synth.options.oscillator.type)
    },
    markov_notes () {
      var notes = this.markov.generateRandom(3);
      playPattern(notes)
      this.markov_state = notes.map(n => Tone.Frequency(n, "midi").toNote());
      return notes
    },
    markov_train() {
      this.markov.addStates({state: msg.freq, predictions: Object.values(msg)})
      this.markov.train()
      this.markov_state = 'Trained!: ' + JSON.stringify(this.markov.getStates()[0].predictions.map(notes => Tone.Frequency(notes, 'midi').toNote()));
    },
    osc_trigger() {
      setTimeout(() => {
        this.osc_out()
      }, "750")
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
    //this.showID();
    this.user_id = socket.id
    //this.markov_train();
  }
}
