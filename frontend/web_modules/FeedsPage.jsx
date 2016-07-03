import React from 'react';
import { Link, withRouter } from 'react-router';
import TagButtons from 'TagButtons';
import WithPagination from 'WithPagination';
import api from 'Api';

class SubscriptionRow extends React.Component {
  get href() {
    return `/subscriptions/1/${this.props.subscription.id}`;
  }

  render() {
    return (
      <ul className='list-group'>
        <li className='list-group-item'>
          <div className='list-group-item-heading'>
            <Link to={this.href}>
              <b>{this.props.subscription.userTitle}</b>
            </Link>

            {this.props.subscription.tags.map(tag =>
              <span key={tag.id} className='label label-default' style={{margin: '2px'}}>
                {tag.name}
              </span>
            )}
          </div>

          <div className='list-group-item-text'>
            {this.props.subscription.feed.latestItem ?
              <Link to={this.href}>
                <i>{this.props.subscription.feed.latestItem.title}</i>
              </Link>
              : 'No Item'
            }
          </div>
        </li>
      </ul>
    )
  }
}

class FeedsPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      subscriptions: [],
      pagination: null
    };
  }

  get currentTags() {
    return this.selectTags(this.props.currentTagNames);
  }

  selectTags(tagNames) {
    return this.props.tags.filter(tag => tagNames.includes(tag.name));
  }

  updateFeeds(props) {
    var query = {
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
    this.updateFeeds(this.props);
  }

  componentWillReceiveProps(nextProps) {
    this.updateFeeds(nextProps);
  }

  changeUrl({page = this.props.page, currentTagNames = this.props.currentTagNames}) {
    const tagParam = currentTagNames.map(tag => encodeURIComponent(tag)).join(',');
    this.props.router.push(`/feeds/${page}/${tagParam}`);
  }

  pagenationChanged(newPage) {
    this.changeUrl({page: newPage});
  }

  tagButtonsChanged(newTags) {
    this.changeUrl({currentTagNames: newTags.map(tag => tag.name)});
  }

  render() {
    return (
      <div>
        <TagButtons tags={this.props.tags} currentTags={this.currentTags} onChange={this.tagButtonsChanged.bind(this)}/>
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
