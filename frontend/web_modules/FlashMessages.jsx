import React from 'react';
import classNames from 'classnames';

function FlashMessage({message, onClose}) {
  function closeClicked(e) {
    e.preventDefault();
    onClose(message.id);
  }

  const flashToAlertTypes = {notice: 'success', alert: 'danger'};
  const alertType = flashToAlertTypes[message.type];

  return (
    <div className={classNames("alert", "alert-dismissable", `alert-${alertType}`)}>
      <button className="close" area-hidden="true" onClick={(e) => {
        closeClicked(e)
      }}> &times;{' '}</button>
      {message.text}
    </div>
  );
}

export default function FlashMessages({messages, onClose}) {
  return (
    <div className="fixed-alerts">
      {messages.map(message =>
        <FlashMessage key={message.id} message={message} onClose={onClose}/>
      )}
    </div>
  );
}
