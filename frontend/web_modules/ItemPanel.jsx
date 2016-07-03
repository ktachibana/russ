import React from 'react';
import { Link } from 'react-router';
import moment from 'moment';
import classNames from 'classnames';

class ItemPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {shorten: true};
    this.hideFeed = props.hideFeed;
  }

  get subscriptionPath() {
    return `/subscriptions/1/${this.props.item.feed.usersSubscription.id}`;
  }

  get publishedAtString() {
    return this.props.item.publishedAt ? moment(this.props.item.publishedAt).format('YYYY/M/D(ddd) HH:mm') : '-';
  }

  showAll() {
    return this.setState({shorten: false});
  }

  render() {
    return (
      <div className='panel panel-default item'>
        <div className='panel-heading'>
          <a target='_blank' href={this.props.item.link}>
            {this.props.item.title}
          </a>
          {(() => {
            if (!this.hideFeed) {
              return (
                <div className='pull-right'>
                  <small>
                    <Link to={this.subscriptionPath}>
                      {this.props.item.feed.usersSubscription.userTitle}
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
          <div className={classNames('description', {shorten: this.state.shorten})}
               dangerouslySetInnerHTML={{__html: this.props.item.description}}/>
          {(() => {
            if (this.state.shorten) {
              return (
                <a href='javascript:void(0)' onClick={this.showAll.bind(this)}>
                  すべて表示
                </a>
              );
            }
          })()}
          <small className='published-at pull-right'>
            <span className='glyphicon glyphicon-upload'/>
            {this.publishedAtString}
          </small>
        </div>
      </div>
    );
  }
}

module.exports = ItemPanel;
