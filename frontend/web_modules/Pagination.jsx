import React from 'react';

export default class Pagination extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      inputValue: props.currentPage
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.currentPage != this.props.currentPage) {
      this.setState({inputValue: nextProps.currentPage});
    }
  }

  get lastPage() {
    return Math.ceil(this.props.pagination.totalCount / this.props.pagination.perPage);
  }

  firstPageClicked() {
    this.props.onPageChange(1);
  }

  prevPageClicked() {
    this.props.onPageChange(this.props.currentPage - 1);
  }

  get hasPrevPage() {
    return 1 < this.props.currentPage;
  }

  nextPageClicked() {
    this.props.onPageChange(this.props.currentPage + 1);
  }

  lastPageClicked() {
    this.props.onPageChange(this.lastPage);
  }

  get hasNextPage() {
    return this.props.currentPage < this.lastPage;
  }

  inputValueChanged(e) {
    this.setState({inputValue: parseInt(e.target.value)});
  }

  inputBlurred() {
    this.requirePageChange();
  }

  inputKeyPressed(e) {
    if(e.key === 'Enter') {
      e.target.blur();
    }
  }

  requirePageChange() {
    if (this.state.inputValue === this.props.currentPage) {
      return;
    }

    if (!this.isInputValueValid()) {
      this.setState({inputValue: this.props.currentPage});
      return;
    }

    this.props.onPageChange(this.state.inputValue);
  }

  isInputValueValid() {
    const value = this.state.inputValue;
    return typeof(value) === 'number' && 1 <= value && value <= this.lastPage;
  }

  render() {
    return (
      <div className='text-center form-inline'>
        <div className="form-group">
          {this.hasPrevPage ?
            [
              <button className="btn btn-primary btn-sm" onClick={this.firstPageClicked.bind(this)}>
                <span className="glyphicon glyphicon-fast-backward"/>
              </button>,
              <button className="btn btn-primary btn-sm" onClick={this.prevPageClicked.bind(this)}>
                <span className="glyphicon glyphicon-chevron-left"/>
              </button>
            ]
            : null
          }
          <div className="input-group">
            <div className="input-group-addon">Page</div>
            <input type="number"
                   className="form-control"
                   value={this.state.inputValue}
                   onChange={this.inputValueChanged.bind(this)}
                   onBlur={this.inputBlurred.bind(this)}
                   onKeyPress={this.inputKeyPressed.bind(this)}
                   min="1"
                   max={this.lastPage}/>
            <div className="input-group-addon">1 - {this.lastPage} ({this.props.pagination.totalCount})</div>
          </div>
          {this.hasNextPage ?
            [
              <button className="btn btn-primary btn-sm" onClick={this.nextPageClicked.bind(this)}>
                <span className="glyphicon glyphicon-chevron-right"/>
              </button>,
              <button className="btn btn-primary btn-sm" onClick={this.lastPageClicked.bind(this)}>
                <span className="glyphicon glyphicon-fast-forward"/>
              </button>
            ]
            : null
          }
        </div>
      </div>
    );
  }
}
