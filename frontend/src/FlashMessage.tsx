import React from 'react';
import classNames from 'classnames';
import {Message} from "./types";

interface Props {
  message: Message
  onClose: (messageId: string) => void
}

export default function FlashMessage({message, onClose}: Props) {
  function closeClicked(e: React.MouseEvent<HTMLButtonElement, MouseEvent>) {
    e.preventDefault();
    onClose(message.id);
  }

  const flashToAlertTypes: { [key: string]: string } = {notice: 'success', alert: 'danger'};
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
