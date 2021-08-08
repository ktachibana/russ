import React from 'react';
import Pagination from './Pagination';

export default function WithPagination({pagination, currentPage, onPageChange, children}) {
  return (
    pagination ?
      <div>
        <Pagination pagination={pagination} currentPage={currentPage} onPageChange={onPageChange}/>
        {children}
        <Pagination pagination={pagination} currentPage={currentPage} onPageChange={onPageChange}/>
      </div>
      :
      <div>{children}</div>
  );
}
