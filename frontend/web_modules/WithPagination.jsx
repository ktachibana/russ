import React from 'react';
import Pagination from 'Pagination';

export default class WithPagination extends React.Component {
  render() {
    const pagination = this.props.pagination;
    const currentPage = this.props.currentPage;
    const onPageChange = this.props.onPageChange;

    return (
      pagination ?
        <div>
          <Pagination pagination={pagination} currentPage={currentPage} onPageChange={onPageChange}/>
          {this.props.children}
          <Pagination pagination={pagination} currentPage={currentPage} onPageChange={onPageChange}/>
        </div>
        :
        <div>{this.props.children}</div>
    );
  }
}
