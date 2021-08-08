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
  return (
    <span className='btn-group btn-group-sm tag-button'>
      <a className={classNames('btn', `btn-${active ? 'info' : 'default'}`, {active: active})}
         onClick={() => { onSelect(); }}>
        <span className='glyphicon glyphicon-tag'/>
        {tag.name} ({tag.count})
      </a>
      <a className='btn btn-default' onClick={() => { onToggle(); }}>
        <span className={classNames('glyphicon', `glyphicon-${active ? 'minus' : 'plus'}`)}/>
      </a>
    </span>
  );
}
