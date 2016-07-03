import React from 'react';
import { withRouter } from 'react-router';
import ItemPanel from 'ItemPanel';
import TagButtons from 'TagButtons';
import WithPagination from 'WithPagination';
import api from 'Api';

class ItemsPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      page: 1,
      items: [],
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

  updateItems({page = this.state.page, tagParam = this.props.params.tags}) {
    var tag = tagParam ? tagParam.split(',') : [];
    api.loadItems({tag, page}).then(({items, pagination}) => {
      this.setState({
        page: page,
        items: items,
        pagination: pagination
      });
    });
  }

  tagButtonsChanged(newTags) {
    const tagNames = newTags.map(tag => encodeURIComponent(tag.name));
    this.props.router.push(`/items/${tagNames.join(',')}`);
  }

  componentDidMount() {
    this.updateItems({});
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.tags != this.props.params.tags) {
      this.updateItems({tagParam: nextProps.params.tags || null, page: 1});
    }
  }

  pagenationChanged(newPage) {
    this.updateItems({page: newPage});
  }

  render() {
    return (
      <div>
        <TagButtons tags={this.props.tags} currentTags={this.currentTags} onChange={this.tagButtonsChanged.bind(this)}/>
        <hr/>

        <WithPagination pagination={this.state.pagination}
                        currentPage={this.state.page}
                        onPageChange={this.pagenationChanged.bind(this)}>
          <div className='items'>
            {this.state.items.map(item =>
              <ItemPanel key={item.id} item={item}/>
            )}
          </div>
        </WithPagination>
      </div>
    );
  }
}

export default withRouter(ItemsPage);
