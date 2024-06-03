export default {

  data() {
    return {
      title: "LickTheToad",
      user_id: "",
      connected_users: undefined,
      tempo: undefined,
      oscWebSocket: new osc.WebSocketPort({url: "ws://10.12.74.108:8081", metadata:true}),
      osc_config: 'undefined', //{address:"127.0.0.1", port:8081},
      osc_msg: "",
      pattSync: "Pattern Play",
      synth_picked: undefined,
      audio: "audio Off",
      vol: -12,
      disclaimer: "Best uses: modern web browsers on iPhone iOS and Android and typewriters for the best experience, mind device’s volume and use AYOR",
      osc_incoming: "",
      droneNotes: 'notes',
      markovState: 'false',
      isHidden: true,
      markov: new Markov('numeric'),
      markov_state: 'untrained',
      trainingDataString: "waiting to fetch data",
      form: {
        ip: "127.0.0.1",
        port: 57120 //or undfined
      },
      users: "none"
    }
  },
  methods: {
    async showID()  {
      const username = await socket.id
      this.user_id = username
    },
    fetchDataTrain() {
      const fetchURL = 'https://raw.githubusercontent.com/konvasil/ltt/main/public/main/data.json'
      const fetchPromise = fetch(fetchURL)

      fetchPromise
        .then(response => {
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          return response.json();
        })
        .then((json) =>
          json.data.map((data) => {
            brain.addData(data.xs, data.ys)
            this.trainingDataString = "Data was fetched from: " + fetchURL
          })).then((data) => dataLoaded() )
        .catch(error => this.trainingDataString = error)
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
    osc_out () {
      if(seqIsPlaying == 'false') {
        this.pattSync = "Pattern is playing and OSC sent."
        if(this.markovState !== 'false') {
          var oscNotes = Object.fromEntries(Object.entries(this.osc_msg).map(([key, value]) => [key, value.toFixed(2)]));
          this.oscWebSocket.send({
            address: '/lick', //sc
            //address: '/ctrl', //tidal
            args: [
              //send to sc the pattern structure and user id for allocation in sc.
              {
                type: "s",
                value: this.user_id
              },
              {
                type: "s",
                value: JSON.stringify(oscNotes, null, 4)
              }
            ]
          })
        } else {
          console.log("train markov", 'first')
        }
      } else if(seqIsPlaying == 'playing') {
        this.pattSync = "patience, another pattern is playing!"
      }
    },
    switch_synth(synth_id) {
      synth.set({oscillator: {type: synth_id}});
      //    console.log(synth.options.oscillator.type);
    },
    markov_notes () {
      if(this.markovState !== 'false') {
        var markov_notes = this.markov.generateRandom(4); //amount of notes will be produced.
        let filterNotes = new Array();

        markov_notes.filter(function(note) {
          if(note > 100.0) {
            filterNotes.push(note)
          } else {
            console.log(`Value exceeds range: ${note}`)
            console.log(`Added:, ${note = note + 100}`)
            filterNotes.push(note)
          }});

        this.markov_state = playPattern(filterNotes)
        this.osc_msg = filterNotes
        console.log(this.osc_msg);


        return filterNotes
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
      if(isNaN(prediction.freq)) {
        this.osc_msg = "First Train"
        this.markovState = false
      } else {
        this.markov_state = 'waiting new predictions'
        this.markov.clearChain();
        setTimeout(() => {
          this.markov.addStates({state: prediction.freq, predictions: [prediction.unNormalizedValue * 1000.00, prediction.value / 2]});
          this.markov.train();
          this.markovState = true
          this.markov_state =  this.markov.getPossibilities()//JSON.stringify(this.markov.getStates())
        }, "100")
        //console.log(this.markovState)
        console.log(this.markov_state)
      }
    },
    osc_trigger() {
      if(typeof this.markovState === 'boolean' && this.markovState === false) {
        console.log("No Values", "Train Mark")
      } else if (typeof this.markovState === 'boolean' && this.markovState === true){
        setTimeout(() => {
          this.osc_out()
        }, Math.random() * (750 - 100) + 100) //max - min + min
        console.log("Values Found Sending OSC", this.osc_msg)
      }
    },
    playDrone () {
      console.log(this.markovState)
      if(this.markovState !== 'false'){
        var notes = this.markov.generateRandom(4);
        trigDrone(notes)
        this.droneNotes = notes;
      } else {
        console.log("train markov", "first")
      }
    },
    scaleAmplitudeValue(value, from, to) {
      let scale = (to[1] - to[0]) / (from[1] - from[0]);
      let capped = Math.min(from[1], Math.max(from[0], value)) - from[0];
      return (capped * scale + to[0]);
    },
    set_volume(sliderVal) {
      if(sliderVal < 0.15) {
        Tone.Master.mute = true;
      } else {
        Tone.Master.mute = false;
      }
      synth.volume.value = this.scaleAmplitudeValue(sliderVal, [0, 1], [-60, +1.00]);
    },
    setTempo(tempo) {
      var limitTempo = limitNumberWithinRange(tempo)
      Tone.Transport.bpm.rampTo(limitTempo, 0.1)
      this.tempo = limitTempo //80min - 200max
    },
    async startAudio () {
	    await Tone.start()
      console.log('audio is ready')
      this.audio = "Audio On"
    }
  },
    created() {
      this.oscWebSocket.open()
      this.oscWebSocket.on('message', (oscMsg) => {
        if(oscMsg.args[0].value == 'osc_markov_trigger') {
          this.markov_notes()
          this.osc_trigger()
        } else if (oscMsg.args[0].value == 'markov_train') {
          this.markov_train()
        }
        this.osc_incoming = JSON.stringify(oscMsg.args[0])
      })
      socket.on('newclientconnect', (data) => {
        if(data.guests !== NaN){
          this.connected_users = data.guests
          this.setTempo(Tone.Transport.bpm.value + data.guests)
        }
      })
    },
    mounted(){
      this.synth_picked = "Sine"
      this.switch_synth('sine')
      Tone.Transport.bpm.value = 140;
    },
    updated() {
      this.user_id = socket.id
    }
  }
