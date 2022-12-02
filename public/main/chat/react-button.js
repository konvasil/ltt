'use strict';

const e = React.createElement;

class ChatButton extends React.Component {

  constructor(props) {
    super(props);
    this.state = { transfer: false };
  }

  routeChat = () => {
    "http://127.0.0.1:8000/main/chat"
  }

  render() {
    if (this.state.transfer) {
      return 'Transfered to Chat page.';
    }

    return e(
      'button',
      { onClick: () => this.routeChat()},
      'GotoChat'
    );
  }
}

const domContainer = document.querySelector('#send_message_container');
const root = ReactDOM.createRoot(domContainer);
root.render(e(ChatButton));
