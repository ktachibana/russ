import React, {useEffect, useState} from 'react';
import {withRouter} from 'react-router-dom';
import ItemPanel from 'ItemPanel';
import SubscriptionPanel from 'SubscriptionPanel';
import WithPagination from 'WithPagination';
import api from 'Api';

function SubscriptionPage({id, page, encodedUrl, history}) {
  const [tags, setTags] = useState([]);
  const [subscription, setSubscription] = useState(null);
  const [items, setItems] = useState([]);
  const [pagination, setPagination] = useState(null);

  useEffect(() => {
    api.loadInitial().then(({tags}) => {
      setTags(tags);
    });

    if (encodedUrl) {
      const url = decodeURIComponent(encodedUrl);
      api.fetchFeed(url).then(feed => {
        if (feed.id) {
          history.push(`/subscriptions/1/${feed.id}`);
        } else {
          setSubscription({feed});
          setItems(feed.items);
          setPagination(null);
        }
      }, (xhr) => {
        if (xhr.responseJSON.type === 'feedNotFound') {
          history.push('/items/1/');
        }
      });
    } else {
      api.loadSubscription({id, page}).then(subscription => {
        setSubscription(subscription);
        setItems(subscription.feed.items);
        setPagination(subscription.pagination);
      });
    }
  }, []);

  const goToSavedSubScription = id => {
    history.push(`/subscriptions/1/${id}`);
  }

  const pagenationChanged = newPage => {
    history.push(`/subscriptions/${newPage}/${id}`)
  }

  if (!subscription) {
    return (
      <div>Loading</div>
    );
  }

  return (
    <div>
      <SubscriptionPanel subscription={subscription} tags={tags} onSave={goToSavedSubScription}/>

      <WithPagination
        pagination={pagination}
        currentPage={page}
        onPageChange={pagenationChanged}
      >
        <div className='items'>
          {items.map(item =>
            <ItemPanel key={item.id || item.link} item={item} hideFeed={true}/>
          )}
        </div>
      </WithPagination>
    </div>
  );
}

export default withRouter(SubscriptionPage);
