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

  get maxPage() {
    return Math.ceil(this.props.pagination.totalCount / this.props.pagination.perPage);
  }

  nextPageClicked() {
    if (this.hasNextPage) {
      this.props.onPageChange(this.props.currentPage + 1);
    }
  }

  get hasNextPage() {
    return this.props.currentPage < this.maxPage;
  }

  prevPageClicked() {
    if (this.hasPrevPage) {
      this.props.onPageChange(this.props.currentPage - 1);
    }
  }

  get hasPrevPage() {
    return 1 < this.props.currentPage;
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
    return typeof(value) === 'number' && 1 <= value && value <= this.maxPage;
  }

  render() {
    return (
      <div className='text-center form-inline'>
        <div className="form-group">
          {this.hasPrevPage ?
            <button className="btn btn-primary btn-sm" onClick={this.prevPageClicked.bind(this)}>
              <span className="glyphicon glyphicon-arrow-left"/>
            </button>
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
                   max={this.maxPage}/>
            <div className="input-group-addon">1 - {this.maxPage} ({this.props.pagination.totalCount})</div>
          </div>
          {this.hasNextPage ?
            <button className="btn btn-primary btn-sm" onClick={this.nextPageClicked.bind(this)}>
              <span className="glyphicon glyphicon-arrow-right"/>
            </button>
            : null
          }
        </div>
      </div>
    );
  }
}
