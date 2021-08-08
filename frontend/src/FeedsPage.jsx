import React, {useEffect, useState} from 'react';
import {withRouter} from 'react-router-dom';
import TagButtons from './TagButtons.tsx';
import WithPagination from './WithPagination.tsx';
import {SubscriptionRow} from './SubscriptionRow'
import api from './Api';

export default withRouter(FeedsPage);

function FeedsPage({page, currentTagNames, history}) {
  const [tags, setTags] = useState([]);
  const [subscriptions, setSubscriptions] = useState([]);
  const [pagination, setPagination] = useState(null)

  const currentTags = tags.filter(tag => currentTagNames.includes(tag.name));

  function updateFeeds() {
    api.loadFeeds({
      page: page,
      tag: currentTagNames
    }).then(({subscriptions, pagination}) => {
      setSubscriptions(subscriptions);
      setPagination(pagination);
    });
  }

  useEffect(() => {
    api.loadInitial().then(({tags}) => {
      setTags(tags);
    });
  }, []);

  useEffect(() => {
    updateFeeds();
  }, [page, currentTagNames]);

  const changeUrl = ({newPage = page, newTagNames = currentTagNames}) => {
    const tagParam = newTagNames.map(tag => encodeURIComponent(tag)).join(',');
    history.push(`/feeds/${newPage}/${tagParam}`);
  }

  const pagenationChanged = newPage => {
    changeUrl({newPage: newPage});
  }

  const tagButtonsChanged = newTags => {
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
