import React, {useState} from 'react';
import api from './Api';

interface Props {
  onLogin: (initialState: any) => void
  onLoginFailure: (errorMessage: string) => void
}

interface FormValue {
  email: string
  password: string
  rememberMe: boolean
}

export default function LoginFilter({onLogin, onLoginFailure}: Props): JSX.Element {
  const [form, setForm] = useState({
    email: '',
    password: '',
    rememberMe: true
  } as FormValue)

  function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();

    const params = {
      email: form.email,
      password: form.password,
      remember_me: form.rememberMe ? '1' : '0'
    };

    api.login(params).then((initialState) => {
      onLogin(initialState);
    }, (errorMessage) => {
      onLoginFailure(errorMessage);
    });
  }

  function updateForm(name: string, value: string | boolean) {
    setForm({...form, [name]: value});
  }

  return (
    <div>
      <h2 className="page-header">Sign in</h2>

      <div className="jumbotron">
        <form onSubmit={(e) => submit(e)} method="post">
          <div className="form-group">
            <label htmlFor="user_email">Email<br/></label>
            <input
              id="user_email"
              type="email"
              className="form-control"
              autoFocus={true}
              onChange={(e) => updateForm("email", e.target.value)}
            />
          </div>

          <div className="form-group">
            <label htmlFor="user_password">Password<br/></label>
            <input
              id="user_password"
              type="password"
              className="form-control"
              onChange={(e) => updateForm("password", e.target.value)}
            />
          </div>

          <div className="form-group">
            <label htmlFor="user_remember_me">
              <input
                id="user_remember_me"
                type="checkbox"
                checked={form.rememberMe}
                onChange={(e) => updateForm("rememberMe", e.target.checked)}
              />
              Remember me
            </label>
          </div>

          <div><input type="submit" name="commit" value="Sign in" className="btn btn-default"/></div>
        </form>
      </div>
    </div>
  );
}