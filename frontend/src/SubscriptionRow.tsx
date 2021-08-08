import React from 'react'
import {Link} from 'react-router-dom'
import {Subscription} from "./types";

interface Props {
  subscription: Subscription
}

export function SubscriptionRow({subscription}: Props) {
  const href = `/subscriptions/1/${subscription.id}`;

  return (
    <ul className='list-group'>
      <li className='list-group-item'>
        <div className='list-group-item-heading'>
          <Link to={href}>
            <b>{subscription.userTitle}</b>
          </Link>

          {subscription.tags.map(tag =>
            <span key={tag.id} className='label label-default' style={{margin: '2px'}}>
              {tag.name}
            </span>
          )}
        </div>

        <div className='list-group-item-text'>
          {subscription.feed.latestItem ?
            <Link to={href}>
              <i>{subscription.feed.latestItem.title}</i>
            </Link>
            : 'No Item'
          }
        </div>
      </li>
    </ul>
  );
}
