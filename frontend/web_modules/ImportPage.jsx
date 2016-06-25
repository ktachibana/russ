import React from 'react';
import ApiRoutes from 'app/ApiRoutes';
import $ from 'jquery';

export default class ImportPage extends React.Component {
  constructor(props) {
    super(props);
  }

  get file() {
    return this.refs.file.files[0];
  }

  submitted(e) {
    e.preventDefault();

    if (!this.file) {
      return;
    }

    let data = new FormData();
    data.append('file', this.file);
    this.setState({processing: true});
    $.ajax(ApiRoutes.importSubscriptionsPath(), {
      type: 'post',
      dataType: 'json',
      data: data,
      processData: false,
      contentType: false
    }).then(
      (result) => {
        location.href = '#/items/';
      },
      (xhr, type, errorThrown) => {
        if (xhr.responseJSON && xhr.responseJSON.error) {
          alert(xhr.responseJSON.error);
        } else {
          alert(`${type}: ${errorThrown}`);
        }
      }
    );
  }

  render() {
    return (
      <div className='well'>
        <form className="form" onSubmit={this.submitted.bind(this)}>
          <p className='lead'>OPMLファイルからフィードを一括登録します。</p>
          <input type="file" name="file" ref="file" />
          <input type="submit" name="commit" value="Upload OPML" className="btn btn-primary" />
        </form>
      </div>
    );
  }
}
