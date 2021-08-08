import React, {useEffect, useState} from 'react';
import {withRouter} from 'react-router-dom';
import TagButtons from './TagButtons';
import WithPagination from './WithPagination';
import {SubscriptionRow} from './SubscriptionRow'
import api from './Api';
import {History} from "history";
import {PaginationValue, Subscription, Tag} from "./types";

export default withRouter(FeedsPage);

interface Props {
  page: number
  currentTagNames: string[],
  history: History
}

function FeedsPage({page, currentTagNames, history}: Props) {
  const [tags, setTags] = useState<Tag[]>([]);
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
  const [pagination, setPagination] = useState<PaginationValue>()

  const currentTags = tags.filter(tag => currentTagNames.includes(tag.name));

  function updateFeeds() {
    api.loadFeeds({
      page: page,
      tag: currentTagNames
    }).then(({subscriptions, pagination}: { subscriptions: Subscription[], pagination: PaginationValue }) => {
      setSubscriptions(subscriptions);
      setPagination(pagination);
    });
  }

  useEffect(() => {
    api.loadInitial().then(({tags}: { tags: Tag[] }) => {
      setTags(tags);
    });
  }, []);

  useEffect(() => {
    updateFeeds();
  }, [page, currentTagNames]);

  const changeUrl = ({newPage = page, newTagNames = currentTagNames}: { newPage: number, newTagNames?: string[] }) => {
    const tagParam = newTagNames.map(tag => encodeURIComponent(tag)).join(',');
    history.push(`/feeds/${newPage}/${tagParam}`);
  }

  const pagenationChanged = (newPage: number) => {
    changeUrl({newPage: newPage});
  }

  const tagButtonsChanged = (newTags: Tag[]) => {
    changeUrl({newPage: 1, newTagNames: newTags.map(tag => tag.name)});
  }

  return (
    <div>
      <TagButtons tags={tags} currentTags={currentTags} onChange={tagButtonsChanged}/>
      <hr/>

      <WithPagination
        pagination={pagination}
        currentPage={page}
        onPageChange={pagenationChanged}
      >
        <div className='feeds'>
          {subscriptions.map(subscription =>
            <div key={subscription.id}>
              <SubscriptionRow subscription={subscription}/>
            </div>
          )}
        </div>
      </WithPagination>
    </div>
  );
}
