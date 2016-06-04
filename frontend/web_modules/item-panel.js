import React from 'react';
import moment from 'moment';
import classNames from 'classnames';

class ItemPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {shorten: true};
    this.hideFeed = props.hideFeed;
  }

  get subscriptionPath() {
    return `#/subscriptions/${this.props.item.feed.usersSubscription.id}`;
  }

  get publishedAtMoment() {
    return moment(this.props.item.publishedAt);
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
                    <a href={this.subscriptionPath}>
                      {this.props.item.feed.usersSubscription.userTitle}
                    </a>
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
            {this.publishedAtMoment.format('YYYY/M/D(ddd) HH:mm')}
          </small>
        </div>
      </div>
    );
  }
}

module.exports = ItemPanel;
