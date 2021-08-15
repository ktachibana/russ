import React, {useState} from 'react';
import {Link} from 'react-router-dom';
import {parseJSON, format} from 'date-fns';
import classNames from 'classnames';
import {Item} from "./types";

interface Props {
  item: Item
}

export default function ItemPanel({item}: Props): JSX.Element {
  const [shorten, setShorten] = useState(true);

  const publishedAtString = item.publishedAt ? format(parseJSON(item.publishedAt), 'yyyy/M/d(EEE) HH:mm') : '-';

  return (
    <div className='card my-2 item'>
      <div className='card-header clearfix'>
        <a target='_blank' href={item.link}>
          {item.title}
        </a>
        {(() => {
          if (item.feed) {
            const subscriptionPath = `/subscriptions/1/${item.feed.usersSubscription.id}`;

            return (
              <div className='float-end'>
                <small>
                  <Link to={subscriptionPath}>
                    {item.feed.usersSubscription.userTitle}
                  </Link>
                </small>
              </div>
            );
          }
        })()}
      </div>

      <div className='card-body clearfix'>
        {/* TODO: dangerousなのなんとかする */}
        <div className={classNames('description card-text', {shorten: shorten})}
             dangerouslySetInnerHTML={{__html: item.description}}/>
        {(() => {
          if (shorten) {
            return (
              <a href='#' onClick={(e) => { e.preventDefault(); setShorten(false); }}>
                すべて表示
              </a>
            );
          }
        })()}
        <small className='float-end'>
          🆙
          <span className="published-at">{publishedAtString}</span>
        </small>
      </div>
    </div>
  );
}
