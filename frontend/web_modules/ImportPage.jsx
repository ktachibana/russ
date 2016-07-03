import React from 'react';
import { withRouter } from 'react-router';
import api from 'Api';

class ImportPage extends React.Component {
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

    this.setState({processing: true});
    api.importOPML(this.file).then(
      () => {
        this.props.router.push('/feeds/');
      },
      (errorMessage) => {
        alert(errorMessage);
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

export default withRouter(ImportPage);
