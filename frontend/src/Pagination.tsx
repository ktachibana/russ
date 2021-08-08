import React, {useState} from 'react';
import {PaginationValue} from './types';

interface Props {
  currentPage: number
  pagination: PaginationValue
  onPageChange: (newPage :number) => void
}

export default function Pagination({currentPage, pagination, onPageChange}: Props) {
  const [inputValue, setInputValue] = useState(currentPage);

  const lastPage = Math.ceil(pagination.totalCount / pagination.perPage);
  const hasPrevPage = 1 < currentPage;
  const hasNextPage = currentPage < lastPage;

  function changePage(newPage: number) {
    setInputValue(newPage);
    requirePageChange(newPage);
  }

  function firstPageClicked() {
    changePage(1);
  }

  function prevPageClicked() {
    changePage(currentPage - 1);
  }

  function nextPageClicked() {
    changePage(currentPage + 1);
  }

  function lastPageClicked() {
    changePage(lastPage);
  }

  function inputValueChanged(e: React.ChangeEvent<HTMLInputElement>) {
    setInputValue(parseInt(e.target.value));
  }

  function inputBlurred() {
    requirePageChange(inputValue);
  }

  function inputKeyPressed(e: React.KeyboardEvent<HTMLInputElement>) {
    if(e.key === 'Enter') {
      // TODO: ok?
      (e.target as HTMLInputElement).blur();
    }
  }

  function requirePageChange(newPage: number) {
    if (newPage === currentPage) {
      return;
    }

    if (!isInputValueValid(newPage)) {
      setInputValue(currentPage);
      return;
    }

    onPageChange(newPage);
  }

  function isInputValueValid(newPage: number): boolean {
    return (!Number.isNaN(newPage)) && (1 <= newPage && newPage <= lastPage);
  }

  return (
    <div className='text-center form-inline'>
      <div className="form-group">
        <div className="input-group">
          <span className="input-group-btn">
            <button className="btn btn-default" onClick={() => firstPageClicked} disabled={!hasPrevPage}>
              <span className="glyphicon glyphicon-fast-backward"/>
            </button>
            <button className="btn btn-default" onClick={() => prevPageClicked()} disabled={!hasPrevPage}>
              <span className="glyphicon glyphicon-chevron-left"/>
            </button>
          </span>
          <input
            type="number"
            className="form-control"
            value={inputValue || ''}
            onChange={(e) => inputValueChanged(e)}
            onBlur={() => inputBlurred()}
            onKeyPress={(e) => inputKeyPressed(e)}
            min="1"
            max={lastPage}
          />
          <div className="input-group-addon">/ {lastPage}</div>
          <span className="input-group-btn">
            <button className="btn btn-default" onClick={() => nextPageClicked()} disabled={!hasNextPage}>
              <span className="glyphicon glyphicon-chevron-right"/>
            </button>
            <button className="btn btn-default" onClick={() => lastPageClicked()} disabled={!hasNextPage}>
              <span className="glyphicon glyphicon-fast-forward"/>
            </button>
          </span>
        </div>
      </div>
    </div>
  );
}