import React from 'react';
import classNames from 'classnames';

class FlashMessage extends React.Component {
  closeClicked(e) {
    e.preventDefault();
    this.props.onClose(this.props.message.id);
  }

  render() {
    const flashToAlertTypes = {notice: 'success', alert: 'danger'};
    const alertType = flashToAlertTypes[this.props.message.type];

    // TODO: closable
    return (
      <div className={classNames("alert", "alert-dismissable", `alert-${alertType}`)}>
        <button className="close" area-hidden="true" onClick={this.closeClicked.bind(this)}> &times;{' '}</button>
        {this.props.message.text}
      </div>
    );
  }
}

export default class FlashMessages extends React.Component {
  closeClicked(e) {
    e.preventDefault();
    this.props.onClose(this.props.message.id);
  }

  render() {
    return (
      <div>
        {this.props.messages.map(message =>
          <FlashMessage key={message.id} message={message} onClose={this.props.onClose}/>
        )}
      </div>
    );
  }
}
