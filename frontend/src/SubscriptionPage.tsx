import React, {useEffect, useState} from 'react';
import {RouteComponentProps, withRouter} from 'react-router-dom';
import ItemPanel from './ItemPanel';
import SubscriptionPanel from './SubscriptionPanel';
import WithPagination from './WithPagination';
import api from './Api';
import {Feed, Subscription, Item, PaginationValue, Tag} from "./types";

export default withRouter(SubscriptionPage);

interface Props {
  id?: number,
  page?: number
  encodedUrl?: string
}

function SubscriptionPage({id, page, encodedUrl, history}: Props & RouteComponentProps): JSX.Element {
  const [tags, setTags] = useState<Tag[]>([]);
  const [subscription, setSubscription] = useState<Subscription>();
  const [items, setItems] = useState<Item[]>([]);
  const [pagination, setPagination] = useState<PaginationValue>();

  async function updateTags() {
    const tags = await api.loadTags();
    setTags(tags);
  }

  useEffect(() => {
    updateTags();

    if (encodedUrl) {
      const url = decodeURIComponent(encodedUrl);
      api.fetchFeed(url).then((feed: Feed) => {
        if (feed.id) {
          history.push(`/subscriptions/1/${feed.id}`);
        } else {
          setSubscription({feed} as Subscription);
          setItems(feed.items);
          setPagination(undefined);
        }
      }, (xhr) => {
        if (xhr.responseJSON.type === 'feedNotFound') {
          history.push('/items/1/');
        }
      });
    } else if (id && page) {
      api.loadSubscription(id, {page}).then((subscription: Subscription) => {
        setSubscription(subscription);
        setItems(subscription.feed.items);
        setPagination(subscription.pagination);
      });
    }
  }, []);

  const goToSavedSubScription = (id: number) => {
    history.push(`/subscriptions/1/${id}`);
  }

  const pagenationChanged = (newPage: number) => {
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
        currentPage={page || 1 /* TODO: || 1 の意味がないので別の書き方したい */ }
        onPageChange={pagenationChanged}
      >
        <div className='items'>
          {items.map(item =>
            <ItemPanel key={item.id || item.link} item={item}/>
          )}
        </div>
      </WithPagination>
    </div>
  );
}
