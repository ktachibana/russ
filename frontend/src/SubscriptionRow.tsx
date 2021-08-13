import React from 'react'
import {Link} from 'react-router-dom'
import {Subscription} from "./types";

interface Props {
  subscription: Subscription
}

export function SubscriptionRow({subscription}: Props): JSX.Element {
  const href = `/subscriptions/1/${subscription.id}`;

  return (
    <div className='card my-2'>
      <div className='card-header'>
        <Link to={href}>
          <b>{subscription.userTitle}</b>
        </Link>

        {subscription.tags.map(tag => {
            return (
              <Link key={tag.id} to={`/items/1/${tag.name}`} className='badge bg-secondary mx-1'>
                {tag.name}
              </Link>)
          }
        )}
      </div>

      <div className='card-body'>
        {subscription.feed.latestItem ?
          <Link to={href}>
            <i>{subscription.feed.latestItem.title}</i>
          </Link>
          : 'No Item'
        }
      </div>
    </div>
  );
}
