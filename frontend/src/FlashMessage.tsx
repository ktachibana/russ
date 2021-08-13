import React from 'react';
import classNames from 'classnames';
import {Message} from "./types";

interface Props {
  message: Message
  onClose: (messageId: string) => void
}

export default function FlashMessage({message, onClose}: Props): JSX.Element {
  const flashToAlertTypes: { [key: string]: string } = {notice: 'success', alert: 'danger'};
  const alertType = flashToAlertTypes[message.type];

  return (
    <div className={classNames("alert", "alert-dismissable", `alert-${alertType}`)}>
      <button className="btn-close" area-hidden="true" onClick={() => { onClose(message.id) }}/>
      {message.text}
    </div>
  );
}
