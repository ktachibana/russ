import React from 'react';
import api from 'Api';

export default class LoginFilter extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      error: null
    };
  }

  submit(e) {
    e.preventDefault();

    var user = {
      email: this.email.value,
      password: this.password.value,
      remember_me: this.rememberMe.checked ? '1' : '0'
    };

    api.login(user).then((initialState) => {
      this.props.onLogin(initialState);
    }, (errorMessage) => {
      this.props.onLoginFailure(errorMessage);
    });
  }

  render() {
    return (
      <div>
        <h2 className="page-header">Sign in</h2>

        <div className="jumbotron">
          <form onSubmit={this.submit.bind(this)} method="post">
            <div className="form-group">
              <label for="user_email">Email</label><br />
              <input ref={(c) => { this.email = c; }} autofocus="autofocus" className="form-control" type="email" name="user[email]" />
            </div>

            <div className="form-group">
              <label for="user_password">Password</label><br />
              <input ref={(c) => { this.password = c; }} className="form-control" type="password" name="user[password]" id="user_password" />
            </div>

            <div className="form-group">
              <label for="user_remember_me">
                <input name="user[remember_me]" type="hidden" value="0" />
                <input ref={(c) => { this.rememberMe = c; }} type="checkbox" value="1" name="user[remember_me]" id="user_remember_me" />
                Remember me
              </label>
            </div>

            <div><input type="submit" name="commit" value="Sign in" className="btn btn-default" /></div>
          </form>
        </div>
      </div>
    );
  }
}
