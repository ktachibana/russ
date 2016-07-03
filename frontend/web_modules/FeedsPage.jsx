import React from 'react';
import { Link, withRouter } from 'react-router';
import $ from 'jquery';
import ApiRoutes from 'app/ApiRoutes';
import TagButtons from 'TagButtons';
import Pagination from 'Pagination';

class SubscriptionRow extends React.Component {
  get href() {
    return `/subscriptions/${this.props.subscription.id}`;
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
      page: 1,
      pagination: null
    };
  }

  get currentTags() {
    return this.selectTags(this.props.params.tags);
  }

  selectTags(tagsParam) {
    const tagNames = (tagsParam || '').split(',');
    return this.props.tags.filter(tag => tagNames.includes(tag.name));
  }

  updateFeeds({page = this.state.page, tagParam = this.props.params.tags}) {
    const url = ApiRoutes.feedsPath({tag: tagParam ? tagParam.split(',') : [], page: page});
    $.getJSON(url).then((data) => {
      this.setState({
        subscriptions: data.subscriptions,
        page: page,
        pagination: data.pagination
      });
    });
  }

  tagButtonsChanged(newTags) {
    const tagNames = newTags.map(tag => encodeURIComponent(tag.name));
    this.props.router.push(`/feeds/${tagNames.join(',')}`);
  }

  componentDidMount() {
    this.updateFeeds({});
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.tags != this.props.params.tags) {
      this.updateFeeds({tagParam: nextProps.params.tags || null, page: 1});
    }
  }

  pagenationChanged(newPage) {
    this.updateFeeds({page: newPage});
  }

  render() {
    return (
      <div>
        <TagButtons tags={this.props.tags} currentTags={this.currentTags} onChange={this.tagButtonsChanged.bind(this)}/>
        <hr/>

        {this.state.pagination ?
          <Pagination pagination={this.state.pagination}
                      currentPage={this.state.page}
                      onPageChange={this.pagenationChanged.bind(this)}/>
          : null
        }

        <div className='feeds'>
          {this.state.subscriptions.map(subscription =>
            <div key={subscription.id}>
              <SubscriptionRow subscription={subscription}/>
            </div>
          )}
        </div>

        {this.state.pagination ?
          <Pagination pagination={this.state.pagination}
                      currentPage={this.state.page}
                      onPageChange={this.pagenationChanged.bind(this)}/>
          : null
        }
      </div>
    );
  }
}

export default withRouter(FeedsPage);
