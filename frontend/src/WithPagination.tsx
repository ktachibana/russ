import React from 'react';
import Pagination from './Pagination';
import {PaginationValue} from './types';

interface Props {
  pagination?: PaginationValue
  currentPage: number
  onPageChange: (newPage: number) => void
  children: React.ReactNode
}

export default function WithPagination({pagination, currentPage, onPageChange, children}: Props) {
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
