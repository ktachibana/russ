import React, {useRef} from 'react';
import {RouteComponentProps, withRouter} from 'react-router-dom';
import api from './Api';

export default withRouter(ImportPage);

function ImportPage({history}: RouteComponentProps) {
  const fileRef = useRef<HTMLInputElement>(null);

  const submitForm = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    const file = fileRef.current?.files ? fileRef.current.files[0] : null;

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
    <div className='card my-3'>
      <form className="card-body" onSubmit={submitForm}>
        <div className="my-2">
          <p className='lead'>OPMLファイルからフィードを一括登録します。</p>
        </div>
        <div className="my-2">
          <input type="file" className="form-control" name="file" ref={fileRef}/>
        </div>
        <div className="my-2">
          <input type="submit" name="commit" value="Upload OPML" className="btn btn-primary"/>
        </div>
      </form>
    </div>
  );
}
