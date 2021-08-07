import React, {useRef} from 'react';
import {withRouter} from 'react-router-dom';
import api from 'Api';

function ImportPage({history}) {
  const fileRef = useRef(null);

  const submitForm = e => {
    e.preventDefault();

    const file = fileRef.current ? fileRef.current.files[0] : null;

    if (!file) {
      return;
    }

    api.importOPML(file).then(
      () => {
        history.push('/feeds/1/');
      },
      (errorMessage) => {
        alert(errorMessage);
      }
    );
  }

  return (
    <div className='well'>
      <form className="form" onSubmit={submitForm}>
        <p className='lead'>OPMLファイルからフィードを一括登録します。</p>
        <input type="file" name="file" ref={fileRef}/>
        <input type="submit" name="commit" value="Upload OPML" className="btn btn-primary"/>
      </form>
    </div>
  );
}

export default withRouter(ImportPage);
