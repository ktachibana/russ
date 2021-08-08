import React, {useState} from 'react';
import {Link} from 'react-router-dom';
import moment from 'moment';
import classNames from 'classnames';
import {Item} from "./types";

interface Props {
  hideFeed: boolean
  item: Item
}

export default function ItemPanel({hideFeed, item}: Props) {
  const [shorten, setShorten] = useState(true);

  const publishedAtString = item.publishedAt ? moment(item.publishedAt).format('YYYY/M/D(ddd) HH:mm') : '-';

  return (
    <div className='panel panel-default item'>
      <div className='panel-heading'>
        <a target='_blank' href={item.link}>
          {item.title}
        </a>
        {(() => {
          if (!hideFeed) {
            const subscriptionPath = `/subscriptions/1/${item.feed.usersSubscription.id}`;

            return (
              <div className='pull-right'>
                <small>
                  <Link to={subscriptionPath}>
                    {item.feed.usersSubscription.userTitle}
                  </Link>
                </small>
              </div>
            );
          }
        })()}
        <div className='clearfix'/>
      </div>
      <div className='panel-body'>
        {/* TODO: dangerousなのなんとかする */}
        <div className={classNames('description', {shorten: shorten})}
             dangerouslySetInnerHTML={{__html: item.description}}/>
        {(() => {
          if (shorten) {
            return (
              <a href='javascript:void(0)' onClick={() => setShorten(false)}>
                すべて表示
              </a>
            );
          }
        })()}
        <small className='published-at pull-right'>
          <span className='glyphicon glyphicon-upload'/>
          {publishedAtString}
        </small>
      </div>
    </div>
  );
}
