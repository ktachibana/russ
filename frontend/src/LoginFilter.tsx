import React, {useState} from 'react';
import api from './Api';
import {InitialState} from "./types";

interface Props {
  onLogin: (initialState: InitialState) => void
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

  async function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();

    const params = {
      email: form.email,
      password: form.password,
      remember_me: form.rememberMe ? '1' : '0'
    };

    try {
      const initialState = await api.signIn(params)
      onLogin(initialState);
    } catch (e) {
      onLoginFailure((e?.error || e) .toString());
    }
  }

  function updateForm(name: string, value: string | boolean) {
    setForm({...form, [name]: value});
  }

  return (
    <div>
      <h2>Sign in</h2>
      <hr/>

      <div className="bg-light p-5 rounded">
        <form onSubmit={(e) => submit(e)} method="post">
          <div className="my-2">
            <label className="form-label" htmlFor="user_email">Email<br/></label>
            <input
              id="user_email"
              type="email"
              className="form-control"
              autoComplete="username"
              autoFocus={true}
              onChange={(e) => updateForm("email", e.target.value)}
            />
          </div>

          <div className="my-2">
            <label className="form-label" htmlFor="user_password">Password<br/></label>
            <input
              id="user_password"
              type="password"
              className="form-control"
              autoComplete="current-password"
              onChange={(e) => updateForm("password", e.target.value)}
            />
          </div>

          <div className="my-2">
            <label className="form-label" htmlFor="user_remember_me">
              <input
                id="user_remember_me"
                type="checkbox"
                checked={form.rememberMe}
                onChange={(e) => updateForm("rememberMe", e.target.checked)}
              /> Remember me
            </label>
          </div>

          <div><input type="submit" name="commit" value="Sign in" className="btn btn-primary"/></div>
        </form>
      </div>
    </div>
  );
}
