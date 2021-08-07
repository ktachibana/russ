import React from 'react';
import {withRouter} from 'react-router-dom';
import TagButtons from 'TagButtons';
import WithPagination from 'WithPagination';
import api from 'Api';
import {SubscriptionRow} from './SubscriptionRow'

class FeedsPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      tags: [],
      subscriptions: [],
      pagination: null
    };
  }

  get currentTags() {
    return this.selectTags(this.props.currentTagNames);
  }

  selectTags(tagNames) {
    return this.state.tags.filter(tag => tagNames.includes(tag.name));
  }

  updateFeeds(props) {
    const query = {
      page: props.page,
      tag: props.currentTagNames
    };
    api.loadFeeds(query).then(({subscriptions, pagination}) => {
      this.setState({
        subscriptions: subscriptions,
        pagination: pagination
      });
    });
  }

  componentDidMount() {
    api.loadInitial().then((data) => {
      this.setState({tags: data.tags});
    });
    this.updateFeeds(this.props);
  }

  componentWillReceiveProps(nextProps) {
    this.updateFeeds(nextProps);
  }

  changeUrl({page = this.props.page, currentTagNames = this.props.currentTagNames}) {
    const tagParam = currentTagNames.map(tag => encodeURIComponent(tag)).join(',');
    this.props.history.push(`/feeds/${page}/${tagParam}`);
  }

  pagenationChanged(newPage) {
    this.changeUrl({page: newPage});
  }

  tagButtonsChanged(newTags) {
    this.changeUrl({page: 1, currentTagNames: newTags.map(tag => tag.name)});
  }

  render() {
    return (
      <div>
        <TagButtons tags={this.state.tags} currentTags={this.currentTags} onChange={this.tagButtonsChanged.bind(this)}/>
        <hr/>

        <WithPagination pagination={this.state.pagination}
                        currentPage={this.props.page}
                        onPageChange={this.pagenationChanged.bind(this)}>
          <div className='feeds'>
            {this.state.subscriptions.map(subscription =>
              <div key={subscription.id}>
                <SubscriptionRow subscription={subscription}/>
              </div>
            )}
          </div>
        </WithPagination>
      </div>
    );
  }
}

export default withRouter(FeedsPage);
