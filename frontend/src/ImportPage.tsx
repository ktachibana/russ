import React, {useRef} from 'react';
import {RouteComponentProps, withRouter} from 'react-router-dom';
import api from './Api';

export default withRouter(ImportPage);

function ImportPage({history}: RouteComponentProps): JSX.Element {
  const fileRef = useRef<HTMLInputElement>(null);

  async function submitForm(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();

    const file = fileRef.current?.files ? fileRef.current.files[0] : null;

    if (!file) {
      return;
    }

    try {
      await api.importOPML(file)
      history.push('/feeds/1/');
    } catch (e) {
      alert((e?.error) || e.toString());
    }
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
