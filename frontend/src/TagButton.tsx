import React from 'react';
import classNames from 'classnames';
import {Tag} from "./types";

interface Props {
  tag: Tag
  active: boolean
  onSelect: () => void
  onToggle: () => void
}

export default function TagButton({tag, active, onSelect, onToggle}: Props) {
  const classes = classNames('btn', `btn-${active ? 'info' : 'light'}`, {active: active});

  return (
    <span className='btn-group btn-group-sm tag-button'>
      <a className={classes} onClick={() => { onSelect(); }}>
        🔖 {tag.name} ({tag.count})
      </a>
      <a className={classes} onClick={() => { onToggle(); }}>
        {active ? '-' : '+'}
      </a>
    </span>
  );
}
