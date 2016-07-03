import React from 'react';
import $ from 'jquery';
import { withRouter } from 'react-router';
import ApiRoutes from 'app/ApiRoutes';
import ItemPanel from 'ItemPanel';
import TagButtons from 'TagButtons';
import Pagination from 'Pagination';

class ItemsPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      items: [],
      page: 1,
      lastPage: true,
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
    const url = ApiRoutes.itemsPath({tag: tagParam ? tagParam.split(',') : [], page: page});
    $.getJSON(url).then((data) => {
      this.setState({
        items: data.items,
        page: page,
        lastPage: data.lastPage,
        pagination: data.pagination
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

        {this.state.pagination ?
          <Pagination pagination={this.state.pagination}
                      currentPage={this.state.page}
                      onPageChange={this.pagenationChanged.bind(this)}/>
          : null
        }

        <div className='items'>
          {this.state.items.map(item =>
            <ItemPanel key={item.id} item={item}/>
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

export default withRouter(ItemsPage);
