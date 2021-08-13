import React from 'react';
import FlashMessage from "./FlashMessage";
import {Message} from "./types";

interface Props {
  messages: Message[]
  onClose: (messageId: string) => void
}

export default function FlashMessages({messages, onClose}: Props): JSX.Element {
  return (
    <div className="fixed-alerts">
      {messages.map(message =>
        <FlashMessage key={message.id} message={message} onClose={onClose}/>
      )}
    </div>
  );
}
