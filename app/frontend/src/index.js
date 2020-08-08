import React from 'react';
import ReactDOM from 'react-dom';

class Root extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: null
    };
  }

  componentDidMount() {
    fetch('/api/load')
      .then(response => response.json())
      .then(data => this.setState({
        data: data
      }));
  }

  render() {
    var body;
    if(this.state.data)
      body = <p>Data: {this.state.data.state}</p>;
    else
      body = <p>Waiting for data</p>;

    return body;
  }
};

ReactDOM.render(
  <Root />,
  document.getElementById('root')
);