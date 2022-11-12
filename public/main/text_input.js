'use strict';

const e = React.createElement;

class NameForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {value: ''};
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {    this.setState({value: event.target.value});  }
  handleSubmit(event) {
    alert('A name was submitted: ' + this.state.value);
    event.preventDefault();
  }

  render() {
     return (
        <input
            type="text"
            value={this.state.value}
            onChange={this.handleChange}
         />
     );
 }
}

const domContainer = document.querySelector('#text_input_container');
ReactDOM.render(e(NameForm), domContainer);
