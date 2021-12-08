import React, {useEffect, useState} from 'react';
import {RouteComponentProps, withRouter} from 'react-router-dom';
import TagButtons from './TagButtons';
import WithPagination from './WithPagination';
import {SubscriptionRow} from './SubscriptionRow'
import api from './Api';
import {SubscriptionsResponse, PaginationValue, ShowSubscriptionResponse, Tag} from "./types";

export default withRouter(FeedsPage);

interface Props {
  page: number
  currentTagNames: string[]
}

function FeedsPage({page, currentTagNames, history}: Props & RouteComponentProps): JSX.Element {
  const [tags, setTags] = useState<Tag[]>([]);
  const [subscriptions, setSubscriptions] = useState<ShowSubscriptionResponse[]>([]);
  const [pagination, setPagination] = useState<PaginationValue>()

  const currentTags = tags.filter(tag => currentTagNames.includes(tag.name));

  async function loadSubscriptions() {
    const {subscriptions, pagination} = await api.loadSubscriptions({
      page: page,
      tag: currentTagNames
    });
    setSubscriptions(subscriptions);
    setPagination(pagination);
  }

  async function loadTags() {
    const tags = await api.loadTags();
    setTags(tags);
  }

  useEffect(() => {
    loadTags();
  }, []);

  useEffect(() => {
    loadSubscriptions();
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
        <div className='my-3'>
          {subscriptions.map(subscription =>
            <SubscriptionRow key={subscription.id} subscription={subscription}/>
          )}
        </div>
      </WithPagination>
    </div>
  );
}
